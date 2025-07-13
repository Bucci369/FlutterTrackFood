import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/supabase_service.dart';

class OnboardingActivityScreen extends StatefulWidget {
  const OnboardingActivityScreen({super.key});

  @override
  State<OnboardingActivityScreen> createState() =>
      _OnboardingActivityScreenState();
}

class _OnboardingActivityScreenState extends State<OnboardingActivityScreen> {
  String? _selectedActivity;
  String? _error;
  bool _isLoading = false;

  final List<ActivityOption> _activities = [
    ActivityOption(
      'low',
      'Wenig aktiv',
      'Sitzende Tätigkeit, wenig Sport',
      CupertinoIcons.bed_double,
    ),
    ActivityOption(
      'medium',
      'Mittel aktiv',
      'Gelegentlich Sport, normale Aktivität',
      CupertinoIcons.person_alt_circle,
    ),
    ActivityOption(
      'high',
      'Sehr aktiv',
      'Regelmäßiger Sport, aktiver Lebensstil',
      CupertinoIcons.flame,
    ),
  ];

  Future<void> _handleNext() async {
    if (_selectedActivity == null) {
      setState(() => _error = 'Bitte wähle dein Aktivitätslevel aus.');
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      
      // Update local state
      provider.updateField('activityLevel', _selectedActivity);
      
      // Save to Supabase incrementally
      final supabaseService = SupabaseService();
      final userId = supabaseService.currentUserId;
      
      if (userId != null) {
        await supabaseService.client
            .from('profiles')
            .update({'activity_level': _selectedActivity})
            .eq('id', userId);
      }

      if (mounted) {
        Navigator.of(context).pushNamed('/onboarding/goal');
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
                            CupertinoIcons.person_2_alt,
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
                          'Wie aktiv bist du?',
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
                          'Hilf uns, deine Kalorienbedürfnisse zu bestimmen',
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
                        
                        // Activity Options Container
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
                              // Activity options
                              ...List.generate(_activities.length, (index) {
                                final activity = _activities[index];
                                return Column(
                                  children: [
                                    _buildActivityCard(activity, index),
                                    if (index < _activities.length - 1)
                                      const SizedBox(height: 16),
                                  ],
                                );
                              }),

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
                    onPressed: _selectedActivity != null && !_isLoading ? _handleNext : null,
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

  Widget _buildActivityCard(ActivityOption activity, int index) {
    final isSelected = _selectedActivity == activity.key;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedActivity = activity.key;
          _error = null;
        });
        HapticFeedback.selectionClick();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? CupertinoColors.systemBlue.withOpacity(0.15)
                    : CupertinoColors.systemGrey5,
              ),
              child: Icon(
                activity.icon,
                color: isSelected
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.secondaryLabel,
                size: 28,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      color: isSelected
                          ? CupertinoColors.systemBlue
                          : CupertinoColors.label,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: CupertinoColors.systemBlue,
                size: 24,
              ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
     .fadeIn(duration: 600.ms)
     .slideX(begin: 0.3, end: 0);
  }
}

class ActivityOption {
  final String key;
  final String title;
  final String description;
  final IconData icon;

  ActivityOption(this.key, this.title, this.description, this.icon);
}