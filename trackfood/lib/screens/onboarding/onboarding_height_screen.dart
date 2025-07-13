import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/supabase_service.dart';

class OnboardingHeightScreen extends StatefulWidget {
  const OnboardingHeightScreen({super.key});

  @override
  State<OnboardingHeightScreen> createState() => _OnboardingHeightScreenState();
}

class _OnboardingHeightScreenState extends State<OnboardingHeightScreen> {
  final TextEditingController _heightController = TextEditingController();
  String? _error;
  bool _isLoading = false;

  Future<void> _handleNext() async {
    final height = double.tryParse(_heightController.text);
    if (height == null || height < 100 || height > 250) {
      setState(() => _error = 'Bitte gib eine Größe zwischen 100 und 250 cm an.');
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      
      // Update local state
      provider.updateField('heightCm', height);
      
      // Save to Supabase incrementally
      final supabaseService = SupabaseService();
      final userId = supabaseService.currentUserId;
      
      if (userId != null) {
        await supabaseService.client
            .from('profiles')
            .update({'height_cm': height})
            .eq('id', userId);
      }

      if (mounted) {
        Navigator.of(context).pushNamed('/onboarding/weight');
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
                          'Schritt 4 von 6',
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
                        widthFactor: 4.0 / 6.0,
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
                            CupertinoIcons.arrow_up_down,
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
                          'Wie groß bist du?',
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
                          'Deine Körpergröße wird für die Berechnung deines BMI benötigt',
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
                        
                        // Height Input Container
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
                              // Height Icon
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CupertinoColors.systemBlue.withOpacity(0.1),
                                ),
                                child: Icon(
                                  CupertinoIcons.chart_bar_alt_fill,
                                  size: 28,
                                  color: CupertinoColors.systemBlue,
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Height Input Field
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: CupertinoTextField(
                                      controller: _heightController,
                                      placeholder: '175',
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
                                    'cm',
                                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: CupertinoColors.secondaryLabel,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Height Range Info
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
                                  'Gültige Größe: 100-250 cm',
                                  style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                    fontSize: 14,
                                    color: CupertinoColors.systemBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
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