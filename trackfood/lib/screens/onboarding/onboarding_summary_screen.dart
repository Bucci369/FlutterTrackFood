import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../dashboard/dashboard_screen.dart';

// Apple White color
const Color appleWhite = Color(0xFFF6F1E7);

class OnboardingSummaryScreen extends StatefulWidget {
  const OnboardingSummaryScreen({super.key});

  @override
  State<OnboardingSummaryScreen> createState() =>
      _OnboardingSummaryScreenState();
}

class _OnboardingSummaryScreenState extends State<OnboardingSummaryScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _backgroundController;
  late AnimationController _chartController;
  late AnimationController _pulseController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _backgroundController.repeat();
    _pulseController.repeat(reverse: true);

    // Enhanced staggered animation sequence
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _confettiController.play();
        HapticFeedback.lightImpact();
      }
    });

    // Start chart animation after UI elements load
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _chartController.forward();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _backgroundController.dispose();
    _chartController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _mapGoalToDatabase(String flutterGoal) {
    switch (flutterGoal) {
      case 'weight_loss':
        return 'lose_weight';
      case 'weight_gain':
        return 'gain_weight';
      case 'maintain_weight':
        return 'maintain_weight';
      case 'muscle_gain':
        return 'build_muscle';
      default:
        return 'maintain_weight';
    }
  }

  String _mapActivityToDatabase(String flutterActivity) {
    switch (flutterActivity) {
      case 'sedentary':
        return 'sedentary';
      case 'lightly_active':
        return 'lightly_active';
      case 'moderately_active':
        return 'moderately_active';
      case 'very_active':
        return 'very_active';
      case 'extremely_active':
        return 'extra_active';
      default:
        return 'moderately_active';
    }
  }

  Future<void> _handleComplete(Profile profile) async {
    setState(() => _isLoading = true);

    // Play celebration confetti again on completion
    _confettiController.play();
    HapticFeedback.mediumImpact();

    try {
      final supabaseService = SupabaseService();
      final userId = supabaseService.currentUserId;

      if (userId == null) {
        throw Exception('Benutzer nicht angemeldet');
      }

      final client = supabaseService.client;

      // Map Flutter values to database-compatible values
      final databaseGoal = _mapGoalToDatabase(
        profile.goal ?? 'maintain_weight',
      );
      final databaseActivity = _mapActivityToDatabase(
        profile.activityLevel ?? 'moderately_active',
      );

      await client
          .from('profiles')
          .update({
            'onboarding_completed': true,
            'age': profile.age,
            'gender': profile.gender,
            'height_cm': profile.heightCm,
            'weight_kg': profile.weightKg,
            'activity_level': databaseActivity,
            'goal': databaseGoal,
            'target_weight_kg': profile.targetWeightKg,
            'diet_type': profile.dietType,
            'is_glutenfree': profile.isGlutenfree ?? false,
            'first_name': profile.name.split(' ').first,
            'last_name': profile.name.split(' ').length > 1
                ? profile.name.split(' ').skip(1).join(' ')
                : '',
          })
          .eq('id', userId);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Fehler'),
            content: Text('Fehler beim Speichern: $e'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context).profile;
    if (profile == null) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    final weight = profile.weightKg ?? 0.0;
    final height = profile.heightCm ?? 0.0;
    final goal = profile.goal ?? 'maintain_weight';
    final targetWeight = profile.targetWeightKg ?? weight;
    final bmi = (height > 0) ? weight / ((height / 100) * (height / 100)) : 0.0;
    final progressPercentage = goal == 'weight_loss'
        ? ((weight - targetWeight) / (weight == 0 ? 1 : weight) * 100).round()
        : goal == 'weight_gain'
        ? ((targetWeight - weight) / (weight == 0 ? 1 : weight) * 100).round()
        : 0;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Modern Header
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
                              color: AppColors.label,
                              size: 24,
                            ),
                          ),
                          Text(
                            'Schritt 6 von 6',
                            style: AppTypography.body.copyWith(
                              color: AppColors.label.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(width: 40), // Balance the back button
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: AppColors.separator,
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: AppColors.label,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Welcome message with enhanced animation
                          Text(
                                'Perfekt, ${profile.name.split(' ').first}! 🎉',
                                style: AppTypography.largeTitle.copyWith(
                                  color: AppColors.label,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 300.ms)
                              .slideY(begin: 0.3, end: 0)
                              .then() // Chain animations
                              .shimmer(
                                duration: 1500.ms,
                                color: AppColors.primary.withOpacity(0.3),
                              ),

                          const SizedBox(height: 12),

                          Text(
                                'Dein persönlicher Ernährungsplan ist bereit! Hier ist deine Zusammenfassung:',
                                style: AppTypography.body.copyWith(
                                  color: AppColors.label.withOpacity(0.8),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 500.ms)
                              .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 40),

                          // Enhanced Progress Chart
                          _buildProgressChart(weight, targetWeight, goal)
                              .animate()
                              .slideY(
                                begin: 0.3,
                                duration: 800.ms,
                                delay: 700.ms,
                              )
                              .fadeIn(duration: 800.ms, delay: 700.ms)
                              .scale(
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1, 1),
                              ),

                          const SizedBox(height: 24),

                          // Summary Cards with enhanced animations
                          _buildModernSummaryCard(
                                'BMI Bewertung',
                                bmi.toStringAsFixed(1),
                                _getBMICategory(bmi),
                                CupertinoIcons.heart_circle,
                                _getBMIColor(bmi),
                                0,
                              )
                              .animate()
                              .slideX(
                                begin: -0.3,
                                duration: 600.ms,
                                delay: 900.ms,
                              )
                              .fadeIn(duration: 600.ms, delay: 900.ms),

                          const SizedBox(height: 16),

                          _buildModernSummaryCard(
                                _getGoalTitle(goal),
                                '${targetWeight.toStringAsFixed(1)} kg',
                                '${_getGoalDescription(goal)}: ${progressPercentage.abs()}%',
                                _getGoalIcon(goal),
                                _getGoalColor(goal),
                                1,
                              )
                              .animate()
                              .slideX(
                                begin: 0.3,
                                duration: 600.ms,
                                delay: 1000.ms,
                              )
                              .fadeIn(duration: 600.ms, delay: 1000.ms),

                          const SizedBox(height: 16),

                          _buildModernSummaryCard(
                                'Ernährungstyp',
                                _getDietDisplayName(
                                  profile.dietType ?? 'standard',
                                ),
                                profile.isGlutenfree == true
                                    ? 'Glutenfrei'
                                    : 'Normales Gluten',
                                CupertinoIcons.leaf_arrow_circlepath,
                                CupertinoColors.systemGreen,
                                2,
                              )
                              .animate()
                              .slideX(
                                begin: -0.3,
                                duration: 600.ms,
                                delay: 1100.ms,
                              )
                              .fadeIn(duration: 600.ms, delay: 1100.ms),

                          const SizedBox(height: 40),

                          // Completion button
                          Center(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: CupertinoButton(
                                    color: AppColors.primary,
                                    onPressed: _isLoading
                                        ? null
                                        : () => _handleComplete(profile),
                                    child: _isLoading
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CupertinoActivityIndicator(
                                                color: AppColors.label,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Wird gespeichert...',
                                                style: AppTypography.button
                                                    .copyWith(
                                                      color: AppColors.label,
                                                    ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            'Los geht\'s!',
                                            style: AppTypography.button
                                                .copyWith(
                                                  color: CupertinoColors.white,
                                                ),
                                          ),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 1200.ms)
                              .slideY(begin: 0.3, end: 0),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Confetti animation - single perfect explosion
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 280),
              child: IgnorePointer(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: -math.pi / 2, // Straight up
                  blastDirectionality:
                      BlastDirectionality.explosive, // Spread in all directions
                  maxBlastForce: 35,
                  minBlastForce: 20,
                  emissionFrequency: 0.01,
                  numberOfParticles: 60,
                  gravity: 0.08,
                  shouldLoop: false,
                  colors: [
                    AppColors.primary,
                    CupertinoColors.systemRed,
                    CupertinoColors.systemBlue,
                    CupertinoColors.systemPink,
                    CupertinoColors.systemGreen,
                    CupertinoColors.systemOrange,
                    CupertinoColors.systemPurple,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(
    double currentWeight,
    double targetWeight,
    String goal,
  ) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: appleWhite,
        border: Border.all(color: AppColors.separator, width: 1),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.chart_bar_alt_fill,
                color: AppColors.label,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Dein Weg zum Ziel',
                style: TextStyle(
                  color: AppColors.label,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Legend with better styling
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Dein Gewicht', AppColors.primary),
              const SizedBox(width: 24),
              _buildLegendItem('Kaloriendefizit', CupertinoColors.systemOrange),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: AnimatedBuilder(
              animation: _chartController,
              builder: (context, child) {
                final animationProgress = _chartController.value;

                List<FlSpot> weightSpots = [];
                List<FlSpot> calorieDeficitSpots = [];
                final startWeight = currentWeight;
                final endWeight = targetWeight;

                if (animationProgress > 0) {
                  final progressPoints = (animationProgress * 50).round();
                  for (int i = 0; i <= progressPoints && i <= 50; i++) {
                    final t = i / 50;
                    final x = t * 6;

                    // Weight curve - smooth decline
                    final weightY =
                        startWeight -
                        (startWeight - endWeight) *
                            (1 - math.cos(math.pi * t)) /
                            2;

                    // Calorie deficit curve - starts below weight, ends 50% above weight endpoint with smooth curve down in middle
                    final weightDifference =
                        startWeight - endWeight; // Total weight loss
                    final targetEndDeficit =
                        endWeight +
                        (weightDifference * 0.5); // 50% above endpoint
                    final startDeficit = endWeight - 1.5; // Starting point

                    // Linear progression from start to end
                    final linearY =
                        startDeficit + ((targetEndDeficit - startDeficit) * t);

                    // Add smooth downward curve in middle (parabola that peaks at t=0.5)
                    final curveAmplitude = 1.2; // How deep the curve goes
                    final curve =
                        -curveAmplitude *
                        4 *
                        t *
                        (1 -
                            t); // Parabola: peaks at t=0.5, zero at t=0 and t=1

                    final deficitY = linearY + curve;

                    weightSpots.add(FlSpot(x, weightY));
                    calorieDeficitSpots.add(FlSpot(x, deficitY));
                  }
                }

                return LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 6,
                    minY: goal == 'weight_loss'
                        ? targetWeight - 3
                        : currentWeight - 3,
                    maxY: goal == 'weight_loss'
                        ? currentWeight + 3
                        : targetWeight + 3,
                    lineBarsData: [
                      // Main weight line
                      if (weightSpots.isNotEmpty)
                        LineChartBarData(
                          spots: weightSpots,
                          isCurved: true,
                          color: AppColors.label,
                          barWidth: 4,
                          dotData: FlDotData(
                            show: animationProgress > 0.8,
                            getDotPainter: (spot, percent, barData, index) {
                              if (index == 0 ||
                                  index == weightSpots.length - 1) {
                                return FlDotCirclePainter(
                                  radius: 8,
                                  color: AppColors.label,
                                  strokeWidth: 3,
                                  strokeColor: CupertinoColors.systemBlue,
                                );
                              }
                              return FlDotCirclePainter(
                                radius: 0,
                                color: Colors.transparent,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: animationProgress > 0.4,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary.withOpacity(0.4),
                                AppColors.primary.withOpacity(0.1),
                                AppColors.primary.withOpacity(0.02),
                              ],
                              stops: [0.0, 0.6, 1.0],
                            ),
                          ),
                        ),

                      // Calorie deficit line
                      if (calorieDeficitSpots.isNotEmpty)
                        LineChartBarData(
                          spots: calorieDeficitSpots,
                          isCurved: true,
                          color: CupertinoColors.systemOrange,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: animationProgress > 0.8,
                            getDotPainter: (spot, percent, barData, index) {
                              if (index == calorieDeficitSpots.length - 1) {
                                return FlDotCirclePainter(
                                  radius: 5,
                                  color: CupertinoColors.systemOrange,
                                  strokeWidth: 2,
                                  strokeColor: CupertinoColors.white,
                                );
                              }
                              return FlDotCirclePainter(
                                radius: 0,
                                color: Colors.transparent,
                              );
                            },
                          ),
                          dashArray: [6, 4],
                        ),
                    ],
                    titlesData: FlTitlesData(show: false),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: AppColors.label,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildModernSummaryCard(
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
    int index,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: appleWhite,
        border: Border.all(color: AppColors.separator, width: 1),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
              border: Border.all(color: color.withOpacity(0.4), width: 2),
            ),
            child: Icon(icon, size: 26, color: AppColors.label),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.label,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.title2.copyWith(color: AppColors.label),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryLabel,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Subtle indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Untergewicht';
    if (bmi < 25) return 'Normalgewicht';
    if (bmi < 30) return 'Übergewicht';
    return 'Adipositas';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return CupertinoColors.systemBlue;
    if (bmi < 25) return CupertinoColors.systemGreen;
    if (bmi < 30) return CupertinoColors.systemOrange;
    return CupertinoColors.systemRed;
  }

  String _getGoalTitle(String goal) {
    switch (goal) {
      case 'weight_loss':
        return 'Gewichtsverlust';
      case 'weight_gain':
        return 'Gewichtszunahme';
      case 'muscle_gain':
        return 'Muskelaufbau';
      case 'improved_health':
        return 'Gesundheit';
      case 'more_energy':
        return 'Mehr Energie';
      default:
        return 'Zielfortschritt';
    }
  }

  String _getGoalDescription(String goal) {
    switch (goal) {
      case 'weight_loss':
        return 'Geplanter Verlust';
      case 'weight_gain':
        return 'Geplante Zunahme';
      case 'muscle_gain':
        return 'Muskelzuwachs';
      case 'improved_health':
        return 'Gesundheitsverbesserung';
      case 'more_energy':
        return 'Energiesteigerung';
      default:
        return 'Fortschritt';
    }
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'weight_loss':
        return CupertinoIcons.arrow_down_circle;
      case 'weight_gain':
        return CupertinoIcons.arrow_up_circle;
      case 'muscle_gain':
        return CupertinoIcons.sportscourt;
      case 'improved_health':
        return CupertinoIcons.heart_circle;
      case 'more_energy':
        return CupertinoIcons.bolt_circle;
      default:
        return CupertinoIcons.flag_circle;
    }
  }

  Color _getGoalColor(String goal) {
    switch (goal) {
      case 'weight_loss':
        return CupertinoColors.systemGreen;
      case 'weight_gain':
        return CupertinoColors.systemBlue;
      case 'muscle_gain':
        return CupertinoColors.systemPurple;
      case 'improved_health':
        return CupertinoColors.systemPink;
      case 'more_energy':
        return CupertinoColors.systemYellow;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  String _getDietDisplayName(String diet) {
    switch (diet) {
      case 'standard':
        return 'Standard';
      case 'vegan':
        return 'Vegan';
      case 'vegetarian':
        return 'Vegetarisch';
      case 'keto':
        return 'Keto';
      case 'other':
        return 'Andere';
      default:
        return 'Standard';
    }
  }
}
