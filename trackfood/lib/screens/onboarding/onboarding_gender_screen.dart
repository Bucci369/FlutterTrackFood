import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/supabase_service.dart';

class OnboardingGenderScreen extends StatefulWidget {
  const OnboardingGenderScreen({super.key});

  @override
  State<OnboardingGenderScreen> createState() => _OnboardingGenderScreenState();
}

class _OnboardingGenderScreenState extends State<OnboardingGenderScreen> {
  String? _selectedGender;
  String? _error;
  bool _isLoading = false;

  final List<GenderOption> _genders = [
    GenderOption(
      'male',
      'Männlich',
      'Biologisch männlich',
      CupertinoIcons.person,
    ),
    GenderOption(
      'female',
      'Weiblich',
      'Biologisch weiblich',
      CupertinoIcons.person_alt,
    ),
    GenderOption(
      'other',
      'Divers',
      'Nicht-binär/Andere',
      CupertinoIcons.person_2,
    ),
  ];

  Future<void> _handleNext() async {
    if (_selectedGender == null) {
      setState(() => _error = 'Bitte wähle ein Geschlecht aus.');
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      
      // Update local state
      provider.updateField('gender', _selectedGender);
      
      // Save to Supabase incrementally
      final supabaseService = SupabaseService();
      final userId = supabaseService.currentUserId;
      
      if (userId != null) {
        await supabaseService.client
            .from('profiles')
            .update({'gender': _selectedGender})
            .eq('id', userId);
      }

      if (mounted) {
        Navigator.of(context).pushNamed('/onboarding/height');
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
                          'Schritt 3 von 6',
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
                        widthFactor: 3.0 / 6.0,
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

              // Content with scroll
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
                            CupertinoIcons.person_3,
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
                          'Welches Geschlecht hast du?',
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
                          'Diese Information hilft uns bei der Berechnung deines Kalorienbedarfs',
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
                        
                        // Gender Options Container
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
                              // Gender options in grid
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: _genders.map((gender) {
                                      return SizedBox(
                                        width: (constraints.maxWidth - 24) / 3,
                                        child: _buildGenderCard(
                                          gender,
                                          _genders.indexOf(gender),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
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
                    onPressed: _selectedGender != null && !_isLoading ? _handleNext : null,
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

  Widget _buildGenderCard(GenderOption gender, int index) {
    final isSelected = _selectedGender == gender.key;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender.key;
          _error = null;
        });
        HapticFeedback.selectionClick();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? CupertinoColors.systemBlue.withOpacity(0.1)
              : CupertinoColors.systemGrey6,
          border: Border.all(
            color: isSelected
                ? CupertinoColors.systemBlue
                : CupertinoColors.separator,
            width: isSelected ? 2 : 0.5,
          ),
        ),
        child: Column(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? CupertinoColors.systemBlue.withOpacity(0.15)
                    : CupertinoColors.systemGrey5,
              ),
              child: Icon(
                gender.icon,
                color: isSelected
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.secondaryLabel,
                size: 24,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Title
            Text(
              gender.title,
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                color: isSelected
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.label,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            // Description
            Text(
              gender.description,
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                color: CupertinoColors.secondaryLabel,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            if (isSelected) ...[
              const SizedBox(height: 8),
              Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: CupertinoColors.systemBlue,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
     .fadeIn(duration: 600.ms)
     .scale(begin: const Offset(0.8, 0.8));
  }
}

class GenderOption {
  final String key;
  final String title;
  final String description;
  final IconData icon;

  GenderOption(this.key, this.title, this.description, this.icon);
}