// API Endpoints — tập trung tất cả URL ở một chỗ

class ApiEndpoints {
  // Base URL — THAY THẾ bằng IP máy tính của bạn (ví dụ: 192.168.1.X) khi test trên điện thoại thật
  // Dùng 10.0.2.2 cho Android Emulator, localhost cho desktop/simulator
  static const String baseUrl = 'http://10.202.208.236:8080/api';

  // Auth endpoints
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String googleLogin = '$baseUrl/auth/oauth2/google';
  static const String facebookLogin = '$baseUrl/auth/oauth2/facebook';
  static const String me = '$baseUrl/user/me';

  // Products & Categories
  static const String categories = '$baseUrl/categories';
  static const String products = '$baseUrl/products';
  static const String newProducts = '$baseUrl/products/new';
  static const String saleProducts = '$baseUrl/products/sale';

  // Reviews
  static const String reviews = '$baseUrl/reviews';
  static String productReviews(String productId) => '$baseUrl/reviews/product/$productId';
}
