import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../core/services/auth_api_service.dart';
import '../core/network/api_client.dart';
import '../data/models/user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _authService = AuthApiService();
  final _apiClient = ApiClient();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Kiểm tra trạng thái đăng nhập khi khởi động app
  Future<void> checkAuthStatus() async {
    final loggedIn = await _apiClient.isLoggedIn();
    if (loggedIn) {
      try {
        _currentUser = await _authService.getCurrentUser();
        _status = AuthStatus.authenticated;
      } catch (e) {
        print('[AuthStatus] Lỗi lấy thông tin user: $e');
        if (e.toString().contains('Không thể kết nối')) {
          // Lỗi kết nối mạng, giữ trạng thái đăng nhập ngoại tuyến
          _status = AuthStatus.authenticated;
        } else {
          // Lỗi xác thực (token hết hạn), xoá token và yêu cầu đăng nhập lại
          await _apiClient.clearTokens();
          _currentUser = null;
          _status = AuthStatus.unauthenticated;
        }
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── ĐĂNG KÝ ──────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _authService.register(
        name: name, email: email, password: password,
      );
      // Đăng ký thành công, không tự động đăng nhập (giữ unauthenticated)
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── ĐĂNG NHẬP ─────────────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.login(email: email, password: password);
      _currentUser = result.user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── ĐĂNG XUẤT ─────────────────────────────────────────────────────────
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();

      // Đăng xuất khỏi Google SDK
      try {
        final googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      } catch (e) {
        print('[Auth] Lỗi đăng xuất Google: $e');
      }

      // Đăng xuất khỏi Facebook SDK
      try {
        await FacebookAuth.instance.logOut();
      } catch (e) {
        print('[Auth] Lỗi đăng xuất Facebook: $e');
      }

      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // ── XOÁ TÀI KHOẢN ──────────────────────────────────────────────────────
  Future<bool> deleteAccount() async {
    _setLoading(true);
    try {
      await _authService.deleteAccount();

      // Đăng xuất khỏi Google SDK
      try {
        final googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      } catch (e) {
        print('[Auth] Lỗi đăng xuất Google khi xoá acc: $e');
      }

      // Đăng xuất khỏi Facebook SDK
      try {
        await FacebookAuth.instance.logOut();
      } catch (e) {
        print('[Auth] Lỗi đăng xuất Facebook khi xoá acc: $e');
      }

      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── QUÊN MẬT KHẨU ─────────────────────────────────────────────────────
  Future<String?> forgotPassword(String email) async {
    _setLoading(true);
    try {
      final message = await _authService.forgotPassword(email);
      return message;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ── ĐĂNG NHẬP GOOGLE ──────────────────────────────────────────────────
  Future<bool> loginWithGoogle({
    bool isRegister = false,
    required Future<bool> Function({
      required String name,
      required String email,
      required String? photoUrl,
    }) onConfirm,
  }) async {
    _setLoading(true);
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '795405589157-e4stn4094as6fu188f4dghdjrs5tvt5b.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      // Đảm bảo luôn hiện hộp thoại chọn tài khoản Google bằng cách sign out trước khi sign in
      try {
        await googleSignIn.signOut();
      } catch (_) {}

      final account = await googleSignIn.signIn();
      if (account == null) {
        _setLoading(false);
        return false; // User huỷ
      }

      // Hiện hộp thoại xác nhận trước khi tiếp tục
      final confirmed = await onConfirm(
        name: account.displayName ?? 'Google User',
        email: account.email,
        photoUrl: account.photoUrl,
      );
      if (!confirmed) {
        try {
          await googleSignIn.signOut();
        } catch (_) {}
        _setLoading(false);
        return false; // Chọn Cancel trên hộp thoại của ta
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('Không lấy được Google token.');

      final result = await _authService.loginWithGoogle(idToken, isRegister: isRegister);
      if (isRegister) {
        // Đăng ký mạng xã hội thành công, không tự động đăng nhập (giữ unauthenticated)
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      } else {
        _currentUser = result.user;
        _status = AuthStatus.authenticated;
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── ĐĂNG NHẬP FACEBOOK ────────────────────────────────────────────────
  Future<bool> loginWithFacebook({
    bool isRegister = false,
    required Future<bool> Function({
      required String name,
      required String email,
      required String? photoUrl,
    }) onConfirm,
  }) async {
    _setLoading(true);
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );
      if (result.status == LoginStatus.success) {
        final token = result.accessToken!.token;

        // Lấy thông tin tài khoản Facebook từ Graph API qua SDK
        final userData = await FacebookAuth.instance.getUserData();
        final name = userData['name'] as String? ?? 'Facebook User';
        final email = userData['email'] as String? ?? '';
        final photoUrl = userData['picture']?['data']?['url'] as String?;

        // Hiện hộp thoại xác nhận tài khoản trước khi tiếp tục
        final confirmed = await onConfirm(
          name: name,
          email: email,
          photoUrl: photoUrl,
        );
        if (!confirmed) {
          try {
            await FacebookAuth.instance.logOut();
          } catch (_) {}
          _setLoading(false);
          return false; // Chọn Cancel trên hộp thoại
        }

        final authResult = await _authService.loginWithFacebook(token, isRegister: isRegister);
        if (isRegister) {
          // Đăng ký mạng xã hội thành công, không tự động đăng nhập (giữ unauthenticated)
          _currentUser = null;
          _status = AuthStatus.unauthenticated;
        } else {
          _currentUser = authResult.user;
          _status = AuthStatus.authenticated;
        }
        _errorMessage = null;
        notifyListeners();
        return true;
      } else if (result.status == LoginStatus.cancelled) {
        _setLoading(false);
        return false;
      } else {
        throw Exception(result.message ?? 'Đăng nhập Facebook thất bại.');
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── ĐĂNG NHẬP FACEBOOK MÔ PHỎNG (MOCK) ───────────────────────────────
  Future<bool> loginWithMockFacebookAccount({
    required String name,
    required String email,
    required String avatar,
  }) async {
    _setLoading(true);
    try {
      // Lưu token giả lập để thỏa mãn trạng thái đăng nhập hệ thống
      await _apiClient.saveTokens(
        accessToken: 'mock_fb_access_token_${email.hashCode}',
        refreshToken: 'mock_fb_refresh_token_${email.hashCode}',
      );
      _currentUser = UserModel(
        id: 'fb_${email.hashCode}',
        name: name,
        email: email,
        avatarUrl: avatar,
        provider: 'FACEBOOK',
      );
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Xoá error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
