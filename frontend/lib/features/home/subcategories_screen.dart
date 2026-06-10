import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_app_bar.dart';
import '../../providers/product_provider.dart';
import '../../data/models/category.dart' as model;

class SubcategoriesScreen extends StatefulWidget {
  final String? parentId;
  final String? parentName;
  final VoidCallback? onBackPressed;

  const SubcategoriesScreen({
    super.key,
    this.parentId,
    this.parentName,
    this.onBackPressed,
  });

  @override
  State<SubcategoriesScreen> createState() => _SubcategoriesScreenState();
}

class _SubcategoriesScreenState extends State<SubcategoriesScreen> {
  List<model.Category> _subcategories = [];
  bool _loading = false;
  String? _effectiveParentId;
  String? _effectiveParentName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveArgumentsAndFetch();
  }

  @override
  void didUpdateWidget(covariant SubcategoriesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.parentId != oldWidget.parentId) {
      _resolveArgumentsAndFetch();
    }
  }

  void _resolveArgumentsAndFetch() {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final parentId = widget.parentId ?? routeArgs?['id'];
    final parentName = widget.parentName ?? routeArgs?['name'];

    if (parentId != _effectiveParentId) {
      _effectiveParentId = parentId;
      _effectiveParentName = parentName;
      if (parentId != null) {
        _loadSubcategories(parentId);
      } else {
        setState(() {
          _subcategories = _getMockSubcategories();
        });
      }
    }
  }

  Future<void> _loadSubcategories(String parentId) async {
    setState(() {
      _loading = true;
    });

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final list = await provider.fetchSubcategories(parentId);

    if (mounted) {
      setState(() {
        if (list.isNotEmpty) {
          _subcategories = list;
        } else {
          _subcategories = _getMockSubcategories();
        }
        _loading = false;
      });
    }
  }

  List<model.Category> _getMockSubcategories() {
    const mockNames = [
      'Tops', 'Shirts & Blouses', 'Cardigans & Sweaters', 'Knitwear',
      'Blazers', 'Outerwear', 'Pants', 'Jeans', 'Shorts', 'Skirts', 'Dresses'
    ];
    return mockNames
        .map((name) => model.Category(
              id: '${name.toLowerCase().replaceAll(' ', '-')}-mock',
              name: name,
              imageUrl: '',
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = _effectiveParentName ?? 'Categories';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(
        title: title,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          color: AppColors.dark,
          onPressed: () {
            if (widget.onBackPressed != null) {
              widget.onBackPressed!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.dark),
            onPressed: () => Navigator.of(context).pushNamed('/visual-search'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // "VIEW ALL ITEMS" button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed(
                      '/category',
                      arguments: {
                        'id': _effectiveParentId ?? '',
                        'name': _effectiveParentName ?? 'Women',
                      },
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    child: const Text('VIEW ALL ITEMS'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Choose category', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey)),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _subcategories.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (ctx, i) {
                      final sub = _subcategories[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(sub.name, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 16, color: AppColors.dark)),
                        onTap: () => Navigator.of(context).pushNamed(
                          '/category',
                          arguments: {
                            'id': sub.id,
                            'name': sub.name,
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
