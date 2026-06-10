import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../../data/models/review.dart';

class ReviewApiService {
  final _client = ApiClient();

  // ── Lấy danh sách đánh giá của sản phẩm ────────────────────────────────
  Future<List<Review>> getReviews(String productId) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.productReviews(productId));
      final List dataList = response.data['data'] as List? ?? [];
      return dataList.map((item) => Review.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Tạo đánh giá mới cho sản phẩm ──────────────────────────────────────
  Future<Review> createReview({
    required String productId,
    required int rating,
    required String comment,
    String? title,
    List<String>? imageUrls,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.reviews,
        data: {
          'productId': productId,
          'rating': rating,
          'title': title ?? '',
          'comment': comment,
          'imageUrls': imageUrls ?? const [],
        },
      );
      return Review.fromJson(response.data['data'] as Map<String, dynamic>);
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
