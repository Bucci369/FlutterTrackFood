import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _animationController.forward();
    _backgroundController.repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        _showSnackBar('Erfolgreich angemeldet!', isSuccess: true);
      } else {
        await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        _showSnackBar('Registrierung erfolgreich! Bitte E-Mail bestätigen.',
            isSuccess: true);
      }
    } on AuthException catch (error) {
      _showSnackBar('Fehler: ${error.message}', isError: true);
      HapticFeedback.heavyImpact();
    } catch (error) {
      _showSnackBar('Unerwarteter Fehler: $error', isError: true);
      HapticFeedback.heavyImpact();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'trackfood://auth-callback',
      );
      _showSnackBar('Mit Google angemeldet!', isSuccess: true);
    } catch (e) {
      _showSnackBar('Google Anmeldung fehlgeschlagen: $e', isError: true);
      HapticFeedback.heavyImpact();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message,
      {bool isError = false, bool isSuccess = false}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(isError ? 'Fehler' : isSuccess ? 'Erfolg' : 'Information'),
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.41,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/background1.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Animated gradient overlay
            AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF99D98C).withValues(alpha: 0.7),
                        Color(0xFF76C893).withValues(alpha: 0.6),
                        Color(0xFF52B69A).withValues(alpha: 0.7),
                        Color(0xFF34A0A4).withValues(alpha: 0.8),
                      ],
                      transform: GradientRotation(
                          _backgroundController.value * 2 * 3.14159),
                    ),
                  ),
                );
              },
            ),

            // Safe area content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  height: size.height - MediaQuery.of(context).padding.top,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

                      // Logo and title section
                      Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.3),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/image/logo1.webp',
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                              .animate()
                              .scale(
                                  delay: 200.ms,
                                  duration: 800.ms,
                                  curve: Curves.elasticOut)
                              .shimmer(delay: 800.ms, duration: 1500.ms),
                          const SizedBox(height: 24),
                          Text(
                            _isLogin ? 'Willkommen zurück!' : 'Konto erstellen',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.41,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 600.ms)
                              .slideY(begin: 0.3, end: 0),
                          const SizedBox(height: 8),
                          Text(
                            _isLogin
                                ? 'Melde dich an, um fortzufahren'
                                : 'Erstelle dein TrackFood Konto',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w300,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 600.ms, duration: 600.ms)
                              .slideY(begin: 0.2, end: 0),
                        ],
                      ),

                      const SizedBox(height: 60),

                      // Form section with glassmorphism
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: 420,
                        borderRadius: 24,
                        blur: 20,
                        alignment: Alignment.center,
                        border: 2,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.25),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.3),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Email field
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'E-Mail Adresse',
                                  icon: CupertinoIcons.mail,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Bitte E-Mail eingeben';
                                    }
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                        .hasMatch(value!)) {
                                      return 'Ungültige E-Mail Adresse';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Password field
                                _buildTextField(
                                  controller: _passwordController,
                                  label: 'Passwort',
                                  icon: CupertinoIcons.lock,
                                  obscureText: _obscurePassword,
                                  suffixIcon: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      setState(() =>
                                          _obscurePassword = !_obscurePassword);
                                      HapticFeedback.selectionClick();
                                    },
                                    child: Icon(
                                      _obscurePassword
                                          ? CupertinoIcons.eye_slash
                                          : CupertinoIcons.eye,
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      size: 20,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Bitte Passwort eingeben';
                                    }
                                    if (!_isLogin && value!.length < 6) {
                                      return 'Passwort muss mindestens 6 Zeichen haben';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 32),

                                // Auth button
                                _buildAuthButton(),

                                const SizedBox(height: 16),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color:
                                            Colors.white.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(
                                        'oder',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color:
                                            Colors.white.withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Google sign in button
                                _buildGoogleButton(),
                              ],
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 800.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 32),

                      // Switch auth mode
                      CupertinoButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _formKey.currentState?.reset();
                          });
                          HapticFeedback.selectionClick();
                        },
                        child: Text(
                          _isLogin
                              ? 'Noch kein Konto? Jetzt registrieren'
                              : 'Bereits registriert? Jetzt anmelden',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            letterSpacing: -0.41,
                          ),
                        ),
                      ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),

                      if (_isLogin) ...[
                        const SizedBox(height: 8),
                        CupertinoButton(
                          onPressed: () =>
                              _showSnackBar('Passwort-Reset kommt bald!'),
                          child: Text(
                            'Passwort vergessen?',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                              letterSpacing: -0.41,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.41,
              ),
            ),
          ),
          CupertinoTextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: -0.41,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.transparent),
            ),
            prefix: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20,
              ),
            ),
            suffix: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: suffixIcon,
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: CupertinoButton.filled(
        onPressed: _isLoading ? null : _handleAuth,
        borderRadius: BorderRadius.circular(16),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CupertinoActivityIndicator(
                  color: CupertinoColors.white,
                ),
              )
            : Text(
                _isLogin ? 'Anmelden' : 'Registrieren',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.41,
                  color: CupertinoColors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: CupertinoButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/image/google_logo.svg',
              height: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Mit Google fortfahren',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.41,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
