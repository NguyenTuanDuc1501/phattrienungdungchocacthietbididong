import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../../data/models/user_model.dart';

class AuthApiService {
  final _client = ApiClient();

  // ── Đăng ký bằng Email/Password ──────────────────────────────────────
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.register,
        data: {'fullName': name, 'email': email, 'password': password},
      );
      final data = response.data['data'];
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Đăng nhập bằng Email/Password ────────────────────────────────────
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      return _handleAuthResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Đăng xuất ─────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _client.dio.post(ApiEndpoints.logout);
    } catch (_) {
      // Dù API lỗi vẫn xóa token cục bộ
    } finally {
      await _client.clearTokens();
    }
  }

  // ── Quên mật khẩu ─────────────────────────────────────────────────────
  Future<String> forgotPassword(String email) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
      return response.data['message'] ?? 'Email đã được gửi.';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Đăng nhập Google ──────────────────────────────────────────────────
  Future<AuthResult> loginWithGoogle(String idToken, {bool isRegister = false}) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.googleLogin,
        data: {'token': idToken, 'isRegister': isRegister},
      );
      if (isRegister) {
        final data = response.data['data'];
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        return AuthResult(user: user, accessToken: '');
      } else {
        return _handleAuthResponse(response);
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Đăng nhập Facebook ────────────────────────────────────────────────
  Future<AuthResult> loginWithFacebook(String accessToken, {bool isRegister = false}) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.facebookLogin,
        data: {'token': accessToken, 'isRegister': isRegister},
      );
      if (isRegister) {
        final data = response.data['data'];
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        return AuthResult(user: user, accessToken: '');
      } else {
        return _handleAuthResponse(response);
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Lấy thông tin user hiện tại ────────────────────────────────────────
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.me);
      final data = response.data['data'];
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Xoá tài khoản ──────────────────────────────────────────────────────
  Future<void> deleteAccount() async {
    try {
      await _client.dio.delete(ApiEndpoints.me);
    } on DioException catch (e) {
      throw _handleError(e);
    } finally {
      await _client.clearTokens();
    }
  }

  // ── Xử lý response auth (lưu token) ──────────────────────────────────
  Future<AuthResult> _handleAuthResponse(Response response) async {
    final data = response.data['data'];
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;

    // Lưu token vào secure storage
    await _client.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return AuthResult(user: user, accessToken: accessToken);
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

// Kết quả trả về sau khi auth thành công
class AuthResult {
  final UserModel user;
  final String accessToken;
  const AuthResult({required this.user, required this.accessToken});
}
