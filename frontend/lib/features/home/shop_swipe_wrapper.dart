import 'package:flutter/material.dart';
import 'shop_categories_screen.dart';
import 'subcategories_screen.dart';

/// Wraps ShopCategoriesScreen and SubcategoriesScreen in a horizontal PageView
/// to allow users to swipe between the Categories and Subcategories views on the Shop tab.
class ShopSwipeWrapper extends StatefulWidget {
  const ShopSwipeWrapper({super.key});

  @override
  State<ShopSwipeWrapper> createState() => _ShopSwipeWrapperState();
}

class _ShopSwipeWrapperState extends State<ShopSwipeWrapper> {
  late final PageController _pageController;
  String? _selectedParentId;
  String? _selectedParentName;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String parentId, String parentName) {
    setState(() {
      _selectedParentId = parentId;
      _selectedParentName = parentName;
    });
    _navigateToSubcategories();
  }

  void _navigateToSubcategories() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToCategories() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      children: [
        ShopCategoriesScreen(
          onCategorySelected: _onCategorySelected,
        ),
        SubcategoriesScreen(
          parentId: _selectedParentId,
          parentName: _selectedParentName,
          onBackPressed: _navigateToCategories,
        ),
      ],
    );
  }
}
