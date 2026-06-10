import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../data/models/category.dart' as model;

class ShopCategoriesScreen extends StatefulWidget {
  final Function(String id, String name)? onCategorySelected;
  const ShopCategoriesScreen({super.key, this.onCategorySelected});

  @override
  State<ShopCategoriesScreen> createState() => _ShopCategoriesScreenState();
}

class _ShopCategoriesScreenState extends State<ShopCategoriesScreen> with SingleTickerProviderStateMixin {
  List<model.Category> _rootCategories = [];
  final Map<String, List<model.Category>> _subcategoriesMap = {};
  bool _loading = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final roots = await provider.fetchRootCategories();
    
    if (mounted) {
      setState(() {
        if (roots.isNotEmpty) {
          _rootCategories = roots;
        } else {
          // Mock Level 1 categories fallback
          _rootCategories = [
            const model.Category(id: 'women-mock', name: 'Women', imageUrl: ''),
            const model.Category(id: 'men-mock', name: 'Men', imageUrl: ''),
            const model.Category(id: 'kids-mock', name: 'Kids', imageUrl: ''),
          ];
        }
        _tabController = TabController(length: _rootCategories.length, vsync: this);
        _tabController!.addListener(_handleTabChange);
        _loading = false;
      });
      // Pre-load subcategories for first tab
      if (_rootCategories.isNotEmpty) {
        _loadSubcategories(_rootCategories[0].id);
      }
    }
  }

  void _handleTabChange() {
    if (_tabController != null && !_tabController!.indexIsChanging) {
      final activeId = _rootCategories[_tabController!.index].id;
      _loadSubcategories(activeId);
    }
  }

  Future<void> _loadSubcategories(String parentId) async {
    if (_subcategoriesMap.containsKey(parentId)) return; // Use cache

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final subs = await provider.fetchSubcategories(parentId);
    
    if (mounted) {
      setState(() {
        if (subs.isNotEmpty) {
          _subcategoriesMap[parentId] = subs;
        } else {
          // Mock Level 2 categories fallback for any root category
          _subcategoriesMap[parentId] = [
            model.Category(id: '$parentId-new-mock', name: 'New', imageUrl: 'assets/images/Pasted image (10).png'),
            model.Category(id: '$parentId-clothes-mock', name: 'Clothes', imageUrl: 'assets/images/Pasted image (11).png', hasChildren: true),
            model.Category(id: '$parentId-shoes-mock', name: 'Shoes', imageUrl: 'assets/images/Pasted image (12).png'),
            model.Category(id: '$parentId-accessories-mock', name: 'Accessories', imageUrl: 'assets/images/Pasted image (13).png'),
          ];
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _tabController == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const Text('Categories',
            style: TextStyle(fontFamily: 'Metropolis', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.dark)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.dark),
            onPressed: () => Navigator.of(context).pushNamed('/visual-search'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.dark,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Metropolis', fontSize: 16),
          tabs: _rootCategories.map((c) => Tab(text: c.name)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _rootCategories.map((c) => _buildCategoryList(context, c.id)).toList(),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, String parentId) {
    final subs = _subcategoriesMap[parentId] ?? [];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // SUMMER SALES banner
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SUMMER SALES',
                  style: TextStyle(fontFamily: 'Metropolis', fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
              SizedBox(height: 4),
              Text('Up to 50% off',
                  style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Category items
        if (subs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No subcategories found',
                style: TextStyle(fontFamily: 'Metropolis', color: AppColors.grey, fontSize: 14),
              ),
            ),
          )
        else
          ...subs.map((sub) => _categoryItem(context, sub)),
      ],
    );
  }

  Widget _categoryItem(BuildContext context, model.Category category) {
    String imgUrl = category.imageUrl;
    if (imgUrl.isEmpty) {
      if (category.name.toLowerCase() == 'new') {
        imgUrl = 'assets/images/Pasted image (10).png';
      } else if (category.name.toLowerCase() == 'clothes') {
        imgUrl = 'assets/images/Pasted image (11).png';
      } else if (category.name.toLowerCase() == 'shoes') {
        imgUrl = 'assets/images/Pasted image (12).png';
      } else if (category.name.toLowerCase() == 'accessories') {
        imgUrl = 'assets/images/Pasted image (13).png';
      } else {
        imgUrl = 'assets/images/Pasted image (10).png';
      }
    }

    return GestureDetector(
      onTap: () {
        if (category.hasChildren) {
          if (widget.onCategorySelected != null) {
            widget.onCategorySelected!(category.id, category.name);
          } else {
            Navigator.of(context).pushNamed(
              '/subcategories',
              arguments: {'id': category.id, 'name': category.name},
            );
          }
        } else {
          Navigator.of(context).pushNamed(
            '/category',
            arguments: {'id': category.id, 'name': category.name},
          );
        }
      },
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 23),
                child: Text(category.name,
                    style: const TextStyle(fontFamily: 'Metropolis', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.dark)),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
              child: Image.asset(imgUrl, width: 171, height: 100, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 171, height: 100, color: AppColors.inputGrey)),
            ),
          ],
        ),
      ),
    );
  }
}
