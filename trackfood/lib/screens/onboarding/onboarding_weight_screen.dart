import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/supabase_service.dart';

class OnboardingWeightScreen extends StatefulWidget {
  const OnboardingWeightScreen({super.key});

  @override
  State<OnboardingWeightScreen> createState() => _OnboardingWeightScreenState();
}

class _OnboardingWeightScreenState extends State<OnboardingWeightScreen> {
  final TextEditingController _weightController = TextEditingController();
  String? _error;
  bool _isLoading = false;

  Future<void> _handleNext() async {
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight < 30 || weight > 300) {
      setState(() => _error = 'Bitte gib ein realistisches Gewicht zwischen 30 und 300 kg an.');
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      
      // Update local state
      provider.updateField('weightKg', weight);
      
      // Save to Supabase incrementally
      final supabaseService = SupabaseService();
      final userId = supabaseService.currentUserId;
      
      if (userId != null) {
        await supabaseService.client
            .from('profiles')
            .update({'weight_kg': weight})
            .eq('id', userId);
      }

      if (mounted) {
        Navigator.of(context).pushNamed('/onboarding/activity');
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Fehler beim Speichern. Versuche es erneut.');
        HapticFeedback.heavyImpact();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CupertinoColors.systemBlue.withOpacity(0.1),
              CupertinoColors.systemBackground,
              CupertinoColors.systemGreen.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).pop(),
                          child: Icon(
                            CupertinoIcons.back,
                            color: CupertinoColors.systemBlue,
                            size: 24,
                          ),
                        ),
                        Text(
                          'Schritt 5 von 6',
                          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst),
                          child: Icon(
                            CupertinoIcons.xmark,
                            color: CupertinoColors.systemGrey,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: CupertinoColors.systemGrey5,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 5.0 / 6.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: CupertinoScrollbar(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        
                        // Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.systemBlue.withOpacity(0.1),
                            border: Border.all(
                              color: CupertinoColors.systemBlue.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            CupertinoIcons.waveform_path_ecg,
                            size: 36,
                            color: CupertinoColors.systemBlue,
                          ),
                        ).animate().scale(
                          delay: 200.ms,
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Title
                        Text(
                          'Wie viel wiegst du?',
                          style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.label,
                          ),
                          textAlign: TextAlign.center,
                        ).animate()
                         .fadeIn(delay: 400.ms, duration: 600.ms)
                         .slideY(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Dein aktuelles Gewicht hilft uns bei der BMI-Berechnung und Zielsetzung',
                          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            fontSize: 16,
                            color: CupertinoColors.secondaryLabel,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ).animate()
                         .fadeIn(delay: 600.ms, duration: 600.ms)
                         .slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 48),
                        
                        // Weight Input Container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: CupertinoColors.systemBackground,
                            border: Border.all(
                              color: CupertinoColors.separator,
                              width: 0.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.systemGrey.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Weight Icon
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CupertinoColors.systemBlue.withOpacity(0.1),
                                ),
                                child: Icon(
                                  CupertinoIcons.increase_indent,
                                  size: 28,
                                  color: CupertinoColors.systemBlue,
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Weight Input Field
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: CupertinoTextField(
                                      controller: _weightController,
                                      placeholder: '70.5',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      textAlign: TextAlign.center,
                                      style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: CupertinoColors.label,
                                      ),
                                      placeholderStyle: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: CupertinoColors.placeholderText,
                                      ),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemGrey6,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'kg',
                                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: CupertinoColors.secondaryLabel,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Weight Range Info
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Gültiger Bereich: 30-300 kg',
                                  style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                    fontSize: 14,
                                    color: CupertinoColors.systemBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Privacy Note
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.lock_shield,
                                      size: 16,
                                      color: CupertinoColors.systemGreen,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Deine Daten bleiben privat',
                                      style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                        fontSize: 13,
                                        color: CupertinoColors.systemGreen,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Error message
                              if (_error != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemRed.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: CupertinoColors.systemRed.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    _error!,
                                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                      color: CupertinoColors.systemRed,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ).animate()
                         .fadeIn(delay: 800.ms, duration: 800.ms)
                         .slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton.filled(
                    onPressed: _isLoading ? null : _handleNext,
                    child: _isLoading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CupertinoActivityIndicator(
                                color: CupertinoColors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Speichert...',
                                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Weiter',
                            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}