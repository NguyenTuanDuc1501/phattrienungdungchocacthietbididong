import 'package:flutter/material.dart';
import '../data/models/product.dart';
import '../data/models/category.dart';
import '../core/services/product_api_service.dart';
import '../data/dummy/dummy_products.dart' as dummy;

class ProductProvider extends ChangeNotifier {
  final _apiService = ProductApiService();

  List<Product> _products = [];
  List<Product> _newProducts = [];
  List<Product> _saleProducts = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<Product> get newProducts => _newProducts;
  List<Product> get saleProducts => _saleProducts;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Lọc sản phẩm theo danh mục
  List<Product> getProductsByCategory(String categoryName) {
    if (categoryName == 'New') return _newProducts;
    if (categoryName == 'Sale') return _saleProducts;
    return _products
        .where((p) =>
            p.category.toLowerCase() == categoryName.toLowerCase())
        .toList();
  }

  // Tải dữ liệu từ backend API với fallback sang dummy data
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _apiService.getProducts();
      _newProducts = await _apiService.getNewProducts();
      _saleProducts = await _apiService.getSaleProducts();
      _categories = await _apiService.getCategories();
    } catch (e) {
      _errorMessage = e.toString();
      // Fallback sang dữ liệu local
      _products = dummy.dummyProducts;
      _newProducts = dummy.newProducts;
      _saleProducts = dummy.saleProducts;
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy danh mục gốc Level 1
  Future<List<Category>> fetchRootCategories() async {
    try {
      return await _apiService.getCategories();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Lấy danh mục con Level 2 hoặc Level 3
  Future<List<Category>> fetchSubcategories(String parentId) async {
    try {
      return await _apiService.getCategories(parentId: parentId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Lấy danh sách sản phẩm theo ID danh mục
  Future<List<Product>> fetchProductsByCategoryId(String categoryId) async {
    try {
      return await _apiService.getProductsByCategoryId(categoryId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }
}

