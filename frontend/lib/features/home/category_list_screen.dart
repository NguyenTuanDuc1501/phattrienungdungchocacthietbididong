import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/product_card.dart';
import '../../data/models/product.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/product_provider.dart';

/// Figma "Catalog" — Product grid with tag filters, sort, and view toggle
class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key, this.categoryId, required this.categoryName});
  final String? categoryId;
  final String categoryName;

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  String _sortBy = 'Popular';
  bool _isGrid = true;
  String _selectedTag = 'All';
  static const _tags = ['All', 'T-shirts', 'Crop tops', 'Sleeveless', 'Blouses'];

  List<Product> _products = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void didUpdateWidget(covariant CategoryListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryId != oldWidget.categoryId || widget.categoryName != oldWidget.categoryName) {
      _fetchProducts();
    }
  }

  Future<void> _fetchProducts() async {
    final categoryId = widget.categoryId;
    if (categoryId != null && categoryId.isNotEmpty && !categoryId.contains('-mock')) {
      setState(() {
        _loading = true;
      });
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final list = await provider.fetchProductsByCategoryId(categoryId);
      if (mounted) {
        setState(() {
          _products = list;
          _loading = false;
        });
      }
    } else {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      setState(() {
        _products = provider.getProductsByCategory(widget.categoryName);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          color: AppColors.dark,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.categoryName, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.dark)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: AppColors.dark,
            onPressed: () {},
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Tag filter chips
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _tags.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      final sel = _tags[i] == _selectedTag;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTag = _tags[i]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: sel ? AppColors.dark : Colors.transparent,
                            border: Border.all(color: sel ? AppColors.dark : AppColors.grey),
                          ),
                          child: Text(_tags[i], style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: sel ? Colors.white : AppColors.dark)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Filter / Sort bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/filters'),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.filter_list, size: 18, color: AppColors.dark),
                            SizedBox(width: 4),
                            Text('Filters', style: TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.dark)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _showSort,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.swap_vert, size: 18, color: AppColors.dark),
                            const SizedBox(width: 4),
                            Text(_sortBy, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.dark)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _isGrid = !_isGrid),
                        child: Icon(_isGrid ? Icons.grid_view : Icons.view_list, color: AppColors.dark, size: 20),
                      ),
                    ],
                  ),
                ),
                // Product grid/list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await productProvider.loadProducts();
                      await _fetchProducts();
                    },
                    color: AppColors.primary,
                    child: _products.isEmpty
                        ? const Center(
                            child: Text(
                              'Không có sản phẩm nào trong danh mục này.',
                              style: TextStyle(fontFamily: 'Metropolis', color: AppColors.grey, fontSize: 14),
                            ),
                          )
                        : _isGrid
                            ? GridView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.52,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 24,
                                ),
                                itemCount: _products.length,
                                itemBuilder: (ctx, i) {
                                  final p = _products[i];
                                  return Consumer<FavoritesProvider>(
                                    builder: (ctx, fav, _) => ProductCard(
                                      product: p,
                                      onTap: () => Navigator.of(context).pushNamed('/product', arguments: p),
                                      onFavoriteTap: () => fav.toggleFavorite(p),
                                    ),
                                  );
                                },
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: _products.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 16),
                                itemBuilder: (ctx, i) => _listItem(_products[i]),
                              ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _listItem(Product p) {
    final imageWidget = p.imageUrls.isEmpty
        ? Container(width: 104, height: 104, color: AppColors.inputGrey, child: const Icon(Icons.image_not_supported, color: AppColors.grey))
        : (p.imageUrls.first.startsWith('http')
            ? Image.network(p.imageUrls.first, width: 104, height: 104, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 104, height: 104, color: AppColors.inputGrey))
            : Image.asset(p.imageUrls.first, width: 104, height: 104, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 104, height: 104, color: AppColors.inputGrey)));

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/product', arguments: p),
      child: Container(
        height: 104,
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1))]),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              child: imageWidget,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(p.brand, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.grey)),
                    Text(p.name, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark)),
                    const SizedBox(height: 4),
                    Text('${p.price.toInt()}\$', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.dark)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSort() {
    final options = ['Popular', 'Newest', 'Customer review', 'Price: lowest to high', 'Price: highest to low'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 60, height: 6, decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(3)))),
            const SizedBox(height: 16),
            const Text('Sort by', style: TextStyle(fontFamily: 'Metropolis', fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...options.map((o) => Container(
                  color: _sortBy == o ? AppColors.primary : Colors.transparent,
                  child: ListTile(
                    title: Text(o, style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: _sortBy == o ? FontWeight.w600 : FontWeight.w400, color: _sortBy == o ? Colors.white : AppColors.dark)),
                    onTap: () {
                      setState(() => _sortBy = o);
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
