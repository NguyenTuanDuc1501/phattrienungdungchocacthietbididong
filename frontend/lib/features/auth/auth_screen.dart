import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

/// Auth flow: Sign Up → Login → Forgot Password
/// Matches Figma "Sign up page", "Login page", "Forgot password" exactly.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum _AuthPage { signUp, login, forgotPassword }

class _AuthScreenState extends State<AuthScreen> {
  // Colors from Figma
  static const _validGreen = Color(0xFF2AA952);
  static const _errorRed = Color(0xFFF01F0E);
  static const _titleColor = Color(0xFF222222);
  static const _labelGrey = Color(0xFF9B9B9B);
  static const _bodyColor = Color(0xFF222222);
  static const _btnRed = Color(0xFFDB3022);

  final _signUpNameCtrl = TextEditingController();
  final _signUpEmailCtrl = TextEditingController();
  final _signUpPassCtrl = TextEditingController();
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  final _forgotEmailCtrl = TextEditingController();

  _AuthPage _page = _AuthPage.login;
  bool _signUpAttempted = false, _loginAttempted = false, _forgotAttempted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await auth.checkAuthStatus();
      if (auth.isAuthenticated && mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    });
  }

  @override
  void dispose() {
    _signUpNameCtrl.dispose();
    _signUpEmailCtrl.dispose();
    _signUpPassCtrl.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _forgotEmailCtrl.dispose();
    super.dispose();
  }

  bool get _nameOk => Validators.isValidName(_signUpNameCtrl.text);
  bool get _loginEmailOk => Validators.isValidEmail(_loginEmailCtrl.text);
  bool get _forgotEmailOk => Validators.isValidEmail(_forgotEmailCtrl.text);

  void _msg(String m) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
        content: Text(m),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF222222)));

  void _go(_AuthPage p) {
    FocusScope.of(context).unfocus();
    setState(() => _page = p);
  }

  void _handleBack() => switch (_page) {
        _AuthPage.signUp => _go(_AuthPage.login),
        _AuthPage.login => _go(_AuthPage.signUp),
        _AuthPage.forgotPassword => _go(_AuthPage.login),
      };

  void _handleSignUp() async {
    setState(() => _signUpAttempted = true);
    if (!_nameOk ||
        !Validators.isValidEmail(_signUpEmailCtrl.text) ||
        !Validators.isValidPassword(_signUpPassCtrl.text)) {
      _msg('Please complete all fields correctly.');
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _signUpNameCtrl.text.trim(),
      email: _signUpEmailCtrl.text.trim(),
      password: _signUpPassCtrl.text,
    );
    if (!mounted) return;
    if (success) {
      _msg('Đăng ký tài khoản thành công! Vui lòng đăng nhập.');
      _loginEmailCtrl.text = _signUpEmailCtrl.text;
      _loginPassCtrl.text = '';
      _signUpAttempted = false;
      _go(_AuthPage.login);
    } else {
      _msg(auth.errorMessage ?? 'Đăng ký thất bại. Vui lòng thử lại.');
    }
  }

  void _handleLogin() async {
    setState(() => _loginAttempted = true);
    if (!_loginEmailOk || _loginPassCtrl.text.isEmpty) {
      _msg('Please enter a valid email and password.');
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _loginEmailCtrl.text.trim(),
      password: _loginPassCtrl.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      _msg(auth.errorMessage ?? 'Đăng nhập thất bại. Vui lòng thử lại.');
    }
  }

  void _handleForgot() async {
    setState(() => _forgotAttempted = true);
    if (!_forgotEmailOk) {
      _msg('Please enter a valid email address.');
      return;
    }
    final auth = context.read<AuthProvider>();
    final message = await auth.forgotPassword(_forgotEmailCtrl.text.trim());
    if (!mounted) return;
    print('DEBUG forgotPassword: message=$message, errorMessage=${auth.errorMessage}');
    _msg(message ?? auth.errorMessage ?? 'Không thể gửi email. Thử lại sau.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(0.05, 0), end: Offset.zero)
                .animate(anim),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_page),
          child: switch (_page) {
            _AuthPage.signUp => _buildSignUp(),
            _AuthPage.login => _buildLogin(),
            _AuthPage.forgotPassword => _buildForgot(),
          },
        ),
      ),
    );
  }

  // ── SIGN UP ──────────────────────────────────────────────────────────
  Widget _buildSignUp() {
    final emailErr =
        _signUpAttempted && !Validators.isValidEmail(_signUpEmailCtrl.text);
    final passErr = _signUpAttempted && _signUpPassCtrl.text.length < 6;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            _backBtn(),
            const SizedBox(height: 34),
            _pageTitle('Sign up'),
            const SizedBox(height: 73),
            // Name field
            _inputCard(
              label: 'Name',
              ctrl: _signUpNameCtrl,
              type: TextInputType.name,
              suffixIcon: _nameOk
                  ? const Icon(Icons.check, color: _validGreen, size: 24)
                  : null,
            ),
            const SizedBox(height: 8),
            // Email field
            _inputCard(
              label: 'Email',
              ctrl: _signUpEmailCtrl,
              type: TextInputType.emailAddress,
              borderColor: emailErr ? _errorRed : null,
            ),
            if (emailErr) _errorText('Not a valid email address. Should be your@email.com'),
            const SizedBox(height: 8),
            // Password field
            _inputCard(
              label: 'Password',
              ctrl: _signUpPassCtrl,
              obscure: true,
              borderColor: passErr ? _errorRed : null,
            ),
            if (passErr) _errorText('Password should be at least 6 characters.'),
            const SizedBox(height: 16),
            // "Already have an account?"
            Align(
              alignment: Alignment.centerRight,
              child: _linkAction(
                'Already have an account?',
                () => _go(_AuthPage.login),
              ),
            ),
            const SizedBox(height: 28),
            _primaryBtn('SIGN UP', _handleSignUp),
            const SizedBox(height: 126),
            _socialSection('Or sign up with social account', isRegister: true),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── LOGIN ────────────────────────────────────────────────────────────
  Widget _buildLogin() {
    final emailErr = _loginAttempted && !_loginEmailOk;
    final passErr = _loginAttempted && _loginPassCtrl.text.isEmpty;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            _backBtn(),
            const SizedBox(height: 34),
            _pageTitle('Login'),
            const SizedBox(height: 73),
            _inputCard(
              label: 'Email',
              ctrl: _loginEmailCtrl,
              type: TextInputType.emailAddress,
              borderColor: emailErr ? _errorRed : null,
              suffixIcon: _loginEmailOk
                  ? const Icon(Icons.check, color: _validGreen, size: 24)
                  : null,
            ),
            if (emailErr) _errorText('Not a valid email address.'),
            const SizedBox(height: 8),
            _inputCard(
              label: 'Password',
              ctrl: _loginPassCtrl,
              obscure: true,
              borderColor: passErr ? _errorRed : null,
            ),
            if (passErr) _errorText('Password is required.'),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: _linkAction(
                'Forgot your password?',
                () => _go(_AuthPage.forgotPassword),
              ),
            ),
            const SizedBox(height: 32),
            _primaryBtn('LOGIN', _handleLogin),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => _go(_AuthPage.signUp),
              behavior: HitTestBehavior.opaque,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _bodyColor,
                    ),
                  ),
                  Text(
                    "Sign up",
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _btnRed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 154),
            _socialSection('Or login with social account', isRegister: false),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── FORGOT PASSWORD ─────────────────────────────────────────────────
  Widget _buildForgot() {
    final hasErr = !_forgotEmailOk;
    final showErr = _forgotAttempted && hasErr;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            _backBtn(),
            const SizedBox(height: 34),
            _pageTitle('Forgot password'),
            const SizedBox(height: 87),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                'Please, enter your email address. You will receive a link to create a new password via email.',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 14,
                  height: 1.5,
                  color: _bodyColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _inputCard(
              label: 'Email',
              ctrl: _forgotEmailCtrl,
              type: TextInputType.emailAddress,
              borderColor: showErr ? _errorRed : null,
              labelColor: showErr ? _errorRed : null,
              suffixIcon: showErr
                  ? const Icon(Icons.close, color: _errorRed, size: 24)
                  : null,
            ),
            if (showErr)
              _errorText('Not a valid email address. Should be your@email.com'),
            const SizedBox(height: 55),
            _primaryBtn('SEND', _handleForgot),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  REUSABLE WIDGETS — Figma-exact styling
  // ═══════════════════════════════════════════════════════════════════════

  /// Back chevron button — top-left
  Widget _backBtn() => GestureDetector(
        onTap: _handleBack,
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.arrow_back_ios, size: 20, color: _titleColor),
        ),
      );

  /// Large bold page title (34px, Metropolis Bold)
  Widget _pageTitle(String text) => Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: _titleColor,
            height: 1.0,
          ),
        ),
      );

  /// Input card with floating label — matches Figma white card with shadow
  Widget _inputCard({
    required String label,
    required TextEditingController ctrl,
    TextInputType? type,
    bool obscure = false,
    Color? borderColor,
    Color? labelColor,
    Widget? suffixIcon,
  }) {
    final hasValue = ctrl.text.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        obscureText: obscure,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          fontFamily: 'Metropolis',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _bodyColor,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: hasValue ? 11 : 14,
            color: labelColor ?? _labelGrey,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  /// Error text below input
  Widget _errorText(String text) => Padding(
        padding: const EdgeInsets.only(left: 2, top: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 11,
            color: _errorRed,
          ),
        ),
      );

  /// "Already have an account? →" style link
  Widget _linkAction(String text, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _bodyColor,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward, size: 18, color: _btnRed),
          ],
        ),
      );

  /// Red pill primary button — full width
  Widget _primaryBtn(String label, VoidCallback onTap) => SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: _btnRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            shadowColor: _btnRed.withValues(alpha: 0.4),
            textStyle: const TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: Text(label),
        ),
      );
  Future<bool> _showSocialConfirmDialog({
    required String name,
    required String email,
    required String? photoUrl,
    required String provider, // "Google" or "Facebook"
  }) async {
    // Safe generation of initials (e.g., "Alex R." -> "AR")
    String initials = '';
    final nameParts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (nameParts.isNotEmpty) {
      if (nameParts.length > 1) {
        initials = (nameParts.first[0] + nameParts.last[0]).toUpperCase();
      } else {
        initials = nameParts.first[0].toUpperCase();
      }
    }
    if (initials.isEmpty) initials = provider[0].toUpperCase();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top small title
                Text(
                  'Confirm $provider Account Selection',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9B9B9B),
                  ),
                ),
                const SizedBox(height: 12),
                // Bold confirmation question
                const Text(
                  'Confirm you want to\nselect this account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF091C3F), // Dark navy blue
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 24),
                // Account box display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // User photo or initials
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: provider == 'Facebook'
                            ? const Color(0xFF1877F2)
                            : const Color(0xFF4A89DC),
                        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null
                            ? Text(
                                initials,
                                style: const TextStyle(
                                  fontFamily: 'Metropolis',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Name and Email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Metropolis',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF222222),
                              ),
                            ),
                            if (email.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Metropolis',
                                  fontSize: 13,
                                  color: Color(0xFF9B9B9B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Green checkmark
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF2AA952),
                        size: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // Actions Row
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCCCCCC),
                            foregroundColor: const Color(0xFF222222),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Metropolis',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Continue button (Red background color)
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _btnRed, // RED COLOR for synchronization
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Metropolis',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Continue'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  /// Social login section
  Widget _socialSection(String text, {required bool isRegister}) => Column(
        children: [
          Center(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 14,
                color: _bodyColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialBtn(
                child: const _GoogleIcon(),
                onTap: () async {
                  final auth = context.read<AuthProvider>();
                  if (auth.isLoading) return;
                  final success = await auth.loginWithGoogle(
                    isRegister: isRegister,
                    onConfirm: ({required name, required email, required photoUrl}) =>
                        _showSocialConfirmDialog(
                      name: name,
                      email: email,
                      photoUrl: photoUrl,
                      provider: 'Google',
                    ),
                  );
                  if (!mounted) return;
                  if (success) {
                    if (isRegister) {
                      _msg('Đăng ký bằng Google thành công! Vui lòng đăng nhập.');
                      _go(_AuthPage.login);
                    } else {
                      Navigator.of(context).pushReplacementNamed('/main');
                    }
                  } else {
                    _msg(auth.errorMessage ?? (isRegister ? 'Google đăng ký thất bại.' : 'Google đăng nhập thất bại.'));
                  }
                },
              ),
              const SizedBox(width: 16),
              _socialBtn(
                child: const _FacebookIcon(),
                onTap: () async {
                  final auth = context.read<AuthProvider>();
                  if (auth.isLoading) return;
                  final success = await auth.loginWithFacebook(
                    isRegister: isRegister,
                    onConfirm: ({required name, required email, required photoUrl}) =>
                        _showSocialConfirmDialog(
                      name: name,
                      email: email,
                      photoUrl: photoUrl,
                      provider: 'Facebook',
                    ),
                  );
                  if (!mounted) return;
                  if (success) {
                    if (isRegister) {
                      _msg('Đăng ký bằng Facebook thành công! Vui lòng đăng nhập.');
                      _go(_AuthPage.login);
                    } else {
                      Navigator.of(context).pushReplacementNamed('/main');
                    }
                  } else {
                    _msg(auth.errorMessage ?? (isRegister ? 'Facebook đăng ký thất bại.' : 'Facebook đăng nhập thất bại.'));
                  }
                },
              ),
            ],
          ),
        ],
      );

  /// Social button — white rounded rectangle with shadow
  Widget _socialBtn({required Widget child, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 92,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 8,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      );
}

/// Google "G" logo painted via SVG
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();
  static const String _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.7 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
  <path fill="none" d="M0 0h48v48H0z"/>
</svg>''';
  @override
  Widget build(BuildContext context) => SvgPicture.string(_svg, width: 24, height: 24);
}

/// Facebook "f" logo via SVG
class _FacebookIcon extends StatelessWidget {
  const _FacebookIcon();
  static const String _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="#1877F2" d="M22.676 0H1.324C.593 0 0 .593 0 1.324v21.352C0 23.408.593 24 1.324 24h11.494v-9.294H9.689v-3.621h3.129V8.41c0-3.099 1.894-4.785 4.659-4.785 1.325 0 2.464.097 2.796.141v3.24h-1.921c-1.5 0-1.792.721-1.792 1.771v2.311h3.584l-.465 3.621h-3.119V24h6.115c.733 0 1.324-.592 1.324-1.324V1.324C24 .593 23.408 0 22.676 0z"/>
</svg>''';
  @override
  Widget build(BuildContext context) => SvgPicture.string(_svg, width: 24, height: 24);
}

