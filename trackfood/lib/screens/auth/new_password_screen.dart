import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trackfood/theme/app_theme.dart';
import 'package:trackfood/theme/app_colors.dart';
import 'package:trackfood/theme/app_typography.dart';

class NewPasswordScreen extends StatefulWidget {
  final String? accessToken;
  final String? refreshToken;

  const NewPasswordScreen({
    super.key,
    this.accessToken,
    this.refreshToken,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      // Update password using Supabase Auth
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );

      // Navigate back to login with success message
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        _showSuccessDialog();
      }
      
      HapticFeedback.lightImpact();
    } on AuthException catch (error) {
      _showDialog('Fehler beim Aktualisieren', error.message);
      HapticFeedback.heavyImpact();
    } catch (error) {
      _showDialog(
        'Unerwarteter Fehler',
        'Ein unbekannter Fehler ist aufgetreten. Bitte versuche es erneut.',
      );
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

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Passwort aktualisiert'),
        content: const Text(
          'Dein Passwort wurde erfolgreich aktualisiert. Du kannst dich jetzt mit deinem neuen Passwort anmelden.',
          style: AppTypography.subhead,
        ),
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
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        border: null,
        middle: Text(
          'Neues Passwort',
          style: AppTypography.headline.copyWith(color: AppColors.label),
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppTheme.horizontalPagePadding,
            physics: const BouncingScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              
              _buildHeader()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              
              ...[
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                const SizedBox(height: 32),
                _buildUpdateButton(),
              ]
                  .animate(interval: 50.ms, delay: 200.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
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
          CupertinoIcons.lock_shield_fill,
          size: 64,
          color: AppColors.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Neues Passwort setzen',
          style: AppTypography.largeTitle.copyWith(color: AppColors.label),
        ),
        const SizedBox(height: 8),
        Text(
          'Wähle ein sicheres Passwort für dein TrackFood Konto.',
          style: AppTypography.body.copyWith(color: AppColors.secondaryLabel),
          textAlign: TextAlign.center,
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
            placeholder: 'Neues Passwort',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            style: AppTypography.body.copyWith(color: AppColors.label),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: AppTheme.borderRadiusM,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte gib ein Passwort ein.';
              }
              if (value.length < 6) {
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

  Widget _buildConfirmPasswordField() {
    return Row(
      children: [
        Expanded(
          child: CupertinoTextFormFieldRow(
            controller: _confirmPasswordController,
            prefix: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8.0),
              child: Icon(CupertinoIcons.lock, color: AppColors.placeholder),
            ),
            placeholder: 'Passwort bestätigen',
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleUpdatePassword(),
            style: AppTypography.body.copyWith(color: AppColors.label),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: AppTheme.borderRadiusM,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte bestätige dein Passwort.';
              }
              if (value != _passwordController.text) {
                return 'Die Passwörter stimmen nicht überein.';
              }
              return null;
            },
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
            HapticFeedback.selectionClick();
          },
          child: Icon(
            _obscureConfirmPassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            color: AppColors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton.filled(
        onPressed: _isLoading ? null : _handleUpdatePassword,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: _isLoading
            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
            : Text(
                'Passwort aktualisieren',
                style: AppTypography.button.copyWith(
                  color: CupertinoColors.white,
                ),
              ),
      ),
    );
  }
}