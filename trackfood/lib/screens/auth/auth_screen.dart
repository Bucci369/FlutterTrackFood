import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trackfood/theme/app_theme.dart';
import 'package:trackfood/theme/app_colors.dart';
import 'package:trackfood/theme/app_typography.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        _showDialog(
          'Registrierung erfolgreich',
          'Bitte überprüfe dein E-Mail-Postfach und bestätige deine Adresse, um fortzufahren.',
        );
      }
    } on AuthException catch (error) {
      _showDialog('Fehler bei der Anmeldung', error.message);
      HapticFeedback.heavyImpact();
    } catch (error) {
      _showDialog(
        'Unerwarteter Fehler',
        'Ein unbekannter Fehler ist aufgetreten.',
      );
      HapticFeedback.heavyImpact();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
    } on AuthException catch (error) {
      _showDialog('Google Anmeldung fehlgeschlagen', error.message);
      HapticFeedback.heavyImpact();
    } catch (error) {
      _showDialog('Google Anmeldung fehlgeschlagen', error.toString());
      HapticFeedback.heavyImpact();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDialog(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content, style: AppTypography.subhead),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppTheme.horizontalPagePadding,
            physics: const BouncingScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              // *** BEGINN DER ÄNDERUNG ***
              // Animiere nur den statischen Header
              _buildHeader()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              // Animiere die Formular-Elemente als Gruppe
              ...[
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 32),
                    _buildAuthButton(),
                    const SizedBox(height: 12),
                    _buildSocialDivider(),
                    const SizedBox(height: 12),
                    _buildGoogleButton(),
                    const SizedBox(height: 24),
                    _buildAuthModeToggle(),
                    if (_isLogin) _buildForgotPasswordButton(),
                  ]
                  .animate(interval: 50.ms, delay: 200.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
              // *** ENDE DER ÄNDERUNG ***
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(
          CupertinoIcons.leaf_arrow_circlepath,
          size: 64,
          color: AppColors.primary,
        ),
        const SizedBox(height: 24),
        Text(
          _isLogin ? 'Willkommen zurück!' : 'Konto erstellen',
          style: AppTypography.largeTitle.copyWith(color: AppColors.label),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin
              ? 'Melde dich an, um fortzufahren'
              : 'Beginne deine gesunde Reise mit uns',
          style: AppTypography.body.copyWith(color: AppColors.secondaryLabel),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Row(
      children: [
        Expanded(
          child: CupertinoTextFormFieldRow(
            controller: _emailController,
            prefix: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8.0),
              child: Icon(CupertinoIcons.mail, color: AppColors.placeholder),
            ),
            placeholder: 'E-Mail Adresse',
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            style: AppTypography.body.copyWith(color: AppColors.label),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: AppTheme.borderRadiusM,
            ),
            validator: (value) {
              if (value == null ||
                  !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Bitte gib eine gültige E-Mail an.';
              }
              return null;
            },
          ),
        ),
        SizedBox(
          width: 40, // gleiche Breite wie das Auge-Icon im Passwortfeld
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Row(
      children: [
        Expanded(
          child: CupertinoTextFormFieldRow(
            controller: _passwordController,
            prefix: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8.0),
              child: Icon(CupertinoIcons.lock, color: AppColors.placeholder),
            ),
            placeholder: 'Passwort',
            obscureText: _obscurePassword,
            style: AppTypography.body.copyWith(color: AppColors.label),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: AppTheme.borderRadiusM,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte gib dein Passwort ein.';
              }
              if (!_isLogin && value.length < 6) {
                return 'Das Passwort muss mind. 6 Zeichen lang sein.';
              }
              return null;
            },
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
            HapticFeedback.selectionClick();
          },
          child: Icon(
            _obscurePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            color: AppColors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton.filled(
        onPressed: _isLoading ? null : _handleAuth,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: _isLoading
            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
            : Text(
                _isLogin ? 'Anmelden' : 'Konto erstellen',
                style: AppTypography.button.copyWith(
                  color: CupertinoColors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildSocialDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.separator)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ODER',
            style: AppTypography.footnote.copyWith(
              color: AppColors.secondaryLabel,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.separator)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        color: AppColors.secondaryBackground,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/image/google_logo.svg', height: 24),
            const SizedBox(width: 12),
            Text(
              'Mit Google fortfahren',
              style: AppTypography.button.copyWith(color: AppColors.label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthModeToggle() {
    return CupertinoButton(
      onPressed: () {
        setState(() {
          _isLogin = !_isLogin;
          _formKey.currentState?.reset();
        });
      },
      child: Text(
        _isLogin
            ? 'Noch kein Konto? Registrieren'
            : 'Bereits ein Konto? Anmelden',
        style: AppTypography.subhead.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return CupertinoButton(
      onPressed: () {
        _showDialog(
          'Info',
          'Die Funktion zum Zurücksetzen des Passworts wird in Kürze verfügbar sein.',
        );
      },
      child: Text(
        'Passwort vergessen?',
        style: AppTypography.subhead.copyWith(color: AppColors.secondaryLabel),
      ),
    );
  }
}
