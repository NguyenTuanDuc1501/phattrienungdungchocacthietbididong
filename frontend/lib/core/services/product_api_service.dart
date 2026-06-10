import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../../data/models/product.dart';
import '../../data/models/category.dart';

class ProductApiService {
  final _client = ApiClient();

  // ── Lấy danh sách danh mục ───────────────────────────────────────────
  Future<List<Category>> getCategories({String? parentId}) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.categories,
        queryParameters: parentId != null ? {'parentId': parentId} : null,
      );
      final List dataList = response.data['data'] as List? ?? [];
      return dataList.map((item) => Category.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Lấy sản phẩm theo ID danh mục ────────────────────────────────────
  Future<List<Product>> getProductsByCategoryId(String categoryId) async {
    try {
      final response = await _client.dio.get('${ApiEndpoints.products}/by-category/$categoryId');
      final List dataList = response.data['data'] as List? ?? [];
      return dataList.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Lấy toàn bộ sản phẩm ─────────────────────────────────────────────
  Future<List<Product>> getProducts() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.products);
      final List dataList = response.data['data'] as List? ?? [];
      return dataList.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Lấy sản phẩm mới ─────────────────────────────────────────────────
  Future<List<Product>> getNewProducts() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.newProducts);
      final List dataList = response.data['data'] as List? ?? [];
      return dataList.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Lấy sản phẩm giảm giá ────────────────────────────────────────────
  Future<List<Product>> getSaleProducts() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.saleProducts);
      final List dataList = response.data['data'] as List? ?? [];
      return dataList.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Xử lý lỗi Dio ─────────────────────────────────────────────────────
  String _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'];
      if (message != null) return message.toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Không thể kết nối đến server. Kiểm tra lại mạng.';
    }
    return 'Lỗi không xác định. Vui lòng thử lại.';
  }
}
