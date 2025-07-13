import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trackfood/theme/app_theme.dart';
import 'package:trackfood/theme/app_colors.dart';
import 'package:trackfood/theme/app_typography.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
        redirectTo: 'io.supabase.flutterquickstart://reset-password/',
      );
      
      setState(() => _emailSent = true);
      HapticFeedback.lightImpact();
    } on AuthException catch (error) {
      _showDialog('Fehler', error.message);
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(
            CupertinoIcons.back,
            color: AppColors.primary,
          ),
        ),
        middle: Text(
          'Passwort zurücksetzen',
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
              
              if (!_emailSent) ...[
                // Password Reset Form
                _buildHeader()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                
                ...[
                  _buildEmailField(),
                  const SizedBox(height: 32),
                  _buildResetButton(),
                ]
                    .animate(interval: 50.ms, delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),
              ] else ...[
                // Success Message
                _buildSuccessMessage()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                
                _buildBackToLoginButton()
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),
              ],
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
          CupertinoIcons.lock_rotation,
          size: 64,
          color: AppColors.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Passwort vergessen?',
          style: AppTypography.largeTitle.copyWith(color: AppColors.label),
        ),
        const SizedBox(height: 8),
        Text(
          'Gib deine E-Mail-Adresse ein und wir senden dir einen Link zum Zurücksetzen deines Passworts.',
          style: AppTypography.body.copyWith(color: AppColors.secondaryLabel),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        const Icon(
          CupertinoIcons.checkmark_circle_fill,
          size: 64,
          color: CupertinoColors.systemGreen,
        ),
        const SizedBox(height: 24),
        Text(
          'E-Mail gesendet!',
          style: AppTypography.largeTitle.copyWith(color: AppColors.label),
        ),
        const SizedBox(height: 8),
        Text(
          'Wir haben dir einen Link zum Zurücksetzen deines Passworts an ${_emailController.text.trim()} gesendet. Überprüfe dein E-Mail-Postfach und folge den Anweisungen.',
          style: AppTypography.body.copyWith(color: AppColors.secondaryLabel),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Keine E-Mail erhalten? Überprüfe deinen Spam-Ordner oder versuche es erneut.',
          style: AppTypography.footnote.copyWith(color: AppColors.tertiaryLabel),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return CupertinoTextFormFieldRow(
      controller: _emailController,
      prefix: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 8.0),
        child: Icon(CupertinoIcons.mail, color: AppColors.placeholder),
      ),
      placeholder: 'E-Mail Adresse',
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handlePasswordReset(),
      style: AppTypography.body.copyWith(color: AppColors.label),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: AppTheme.borderRadiusM,
      ),
      validator: (value) {
        if (value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Bitte gib eine gültige E-Mail an.';
        }
        return null;
      },
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton.filled(
        onPressed: _isLoading ? null : _handlePasswordReset,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: _isLoading
            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
            : Text(
                'Passwort zurücksetzen',
                style: AppTypography.button.copyWith(
                  color: CupertinoColors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: () => Navigator.of(context).pop(),
        color: AppColors.secondaryBackground,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Zurück zur Anmeldung',
          style: AppTypography.button.copyWith(color: AppColors.label),
        ),
      ),
    );
  }
}