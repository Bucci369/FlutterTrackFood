import 'package:flutter/cupertino.dart'; // Keep Cupertino for consistency
import 'package:flutter/material.dart'; // Material is still needed for some utilities like Colors
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
import '../../services/supabase_service.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundController.repeat();

    // Staggered animation start
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _confettiController.play();
        HapticFeedback.lightImpact();
      }
    });

    // Start chart animation after initial elements
    Future.delayed(const Duration(milliseconds: 800), () {
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
        // The AuthWrapper will automatically show the dashboard when onboarding is completed
        // Changed to CupertinoPageRoute for consistency, assuming '/' leads to a Cupertino screen
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(
            builder: (context) => const CupertinoPageScaffold(
              child: Center(child: Text('Dashboard Placeholder')),
            ),
          ), // Replace with your actual dashboard
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
      // Use CupertinoPageScaffold for the main layout
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Zusammenfassung',
          style: CupertinoTheme.of(
            context,
          ).textTheme.navTitleTextStyle.copyWith(color: Colors.white),
        ),
        backgroundColor:
            Colors.transparent, // Make it transparent for the background effect
        border: const Border(), // Remove the default border
      ),
      child: Stack(
        children: [
          // Background Animation
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CupertinoColors.systemPurple.withOpacity(
                          0.7 +
                              0.1 *
                                  math.sin(
                                    _backgroundController.value * 2 * math.pi,
                                  ),
                        ),
                        CupertinoColors.activeBlue.withOpacity(
                          0.7 +
                              0.1 *
                                  math.cos(
                                    _backgroundController.value * 2 * math.pi,
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -math.pi / 2, // From top
              maxBlastForce: 20,
              minBlastForce: 10,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                CupertinoColors.systemYellow,
                CupertinoColors.systemBlue,
                CupertinoColors.systemPink,
                CupertinoColors.systemGreen,
              ],
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Hallo, ${profile.name.split(' ').first}!',
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .navLargeTitleTextStyle
                        .copyWith(color: Colors.white),
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
                  const SizedBox(height: 10),
                  Text(
                    'Hier ist eine Zusammenfassung deiner Daten und dein Weg zum Ziel.',
                    style: CupertinoTheme.of(context).textTheme.textStyle
                        .copyWith(color: Colors.white.withOpacity(0.8)),
                  ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
                  const SizedBox(height: 30),
                  _buildProgressChart(weight, targetWeight, goal)
                      .animate()
                      .slideY(begin: 0.2, duration: 600.ms, delay: 700.ms)
                      .fadeIn(duration: 600.ms, delay: 700.ms),
                  const SizedBox(height: 20),
                  _buildSummaryCard(
                        'BMI',
                        bmi.toStringAsFixed(1),
                        _getBMICategory(bmi),
                        CupertinoIcons.graph_circle,
                        _getBMIColor(bmi),
                      )
                      .animate()
                      .slideY(begin: 0.2, duration: 600.ms, delay: 800.ms)
                      .fadeIn(duration: 600.ms, delay: 800.ms),
                  const SizedBox(height: 15),
                  _buildSummaryCard(
                        _getGoalTitle(goal),
                        '${targetWeight.toStringAsFixed(1)} kg',
                        '${_getGoalDescription(goal)}: ${progressPercentage.abs()}%',
                        _getGoalIcon(goal),
                        _getGoalColor(goal),
                      )
                      .animate()
                      .slideY(begin: 0.2, duration: 600.ms, delay: 900.ms)
                      .fadeIn(duration: 600.ms, delay: 900.ms),
                  const SizedBox(height: 15),
                  _buildSummaryCard(
                        'Ernährungstyp',
                        _getDietDisplayName(profile.dietType ?? 'standard'),
                        profile.isGlutenfree == true
                            ? 'Glutenfrei'
                            : 'Nicht glutenfrei',
                        CupertinoIcons.heart_fill,
                        CupertinoColors.systemPink,
                      )
                      .animate()
                      .slideY(begin: 0.2, duration: 600.ms, delay: 1000.ms)
                      .fadeIn(duration: 600.ms, delay: 1000.ms),
                  const SizedBox(height: 30),
                  Center(
                    child: CupertinoButton.filled(
                      onPressed: _isLoading
                          ? null
                          : () => _handleComplete(profile),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      child: _isLoading
                          ? const CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Los geht\'s!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ).animate().fadeIn(duration: 500.ms, delay: 1100.ms),
                  ),
                  const SizedBox(height: 20),
                ],
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
    return GlassmorphicContainer(
      width: double.infinity,
      height: 280,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.25), // Corrected: Use withOpacity
          Colors.white.withOpacity(0.1), // Corrected: Use withOpacity
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.3), // Corrected: Use withOpacity
          Colors.white.withOpacity(0.1), // Corrected: Use withOpacity
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Dein Weg zum Ziel',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Gewicht',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Kalorien-Defizit',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedBuilder(
                animation: _chartController,
                builder: (context, child) {
                  final animationProgress = _chartController.value;

                  // Gewichtskurve: nur zwischen Start- und Zielgewicht
                  List<FlSpot> weightSpots = [];
                  List<FlSpot> calorieSpots = [];
                  final startWeight = currentWeight;
                  final endWeight = targetWeight;

                  if (animationProgress > 0) {
                    final progressPoints = (animationProgress * 40).round();
                    for (int i = 0; i <= progressPoints && i <= 40; i++) {
                      final t = i / 40;
                      final x = t * 6;
                      // Gewicht: S-Kurve
                      final weightY =
                          startWeight +
                          (endWeight - startWeight) *
                              (0.5 - 0.5 * math.cos(math.pi * t));
                      // Goldene Linie: S-Kurve, aber immer knapp unterhalb der Gewichtskurve
                      final calorieY =
                          weightY -
                          1.2 +
                          0.5 *
                              math.sin(
                                math.pi * t - math.pi / 2,
                              ); // optisch ansprechend, immer sichtbar
                      calorieSpots.add(FlSpot(x, calorieY));
                      weightSpots.add(FlSpot(x, weightY));
                    }
                  }

                  return LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: 6,
                      minY: goal == 'weight_loss'
                          ? targetWeight - 2
                          : currentWeight - 2,
                      maxY: goal == 'weight_loss'
                          ? currentWeight + 2
                          : targetWeight + 2,
                      lineBarsData: [
                        // Gewichtslinie (S-Kurve)
                        if (weightSpots.isNotEmpty)
                          LineChartBarData(
                            spots: weightSpots,
                            isCurved: true,
                            color: Colors.white,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: animationProgress > 0.9,
                              getDotPainter: (spot, percent, barData, index) {
                                if (index == 0 ||
                                    index == weightSpots.length - 1) {
                                  return FlDotCirclePainter(
                                    radius: 6,
                                    color: Colors.white,
                                    strokeWidth: 3,
                                    strokeColor: Colors.white.withOpacity(
                                      0.8,
                                    ), // Corrected: Use withOpacity
                                  );
                                }
                                return FlDotCirclePainter(
                                  radius: 0,
                                  color: Colors.transparent,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: animationProgress > 0.7,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(
                                    0.3,
                                  ), // Corrected: Use withOpacity
                                  Colors.white.withOpacity(
                                    0.1,
                                  ), // Corrected: Use withOpacity
                                ],
                              ),
                            ),
                          ),
                        // Goldene Linie: optisch animiert
                        if (calorieSpots.isNotEmpty)
                          LineChartBarData(
                            spots: calorieSpots,
                            isCurved: true,
                            color: const Color(0xFFFFD700),
                            barWidth: 3,
                            dotData: FlDotData(
                              show: animationProgress > 0.9,
                              getDotPainter: (spot, percent, barData, index) {
                                if (index == 0 ||
                                    index == calorieSpots.length - 1) {
                                  return FlDotCirclePainter(
                                    radius: 6,
                                    color: const Color(0xFFFFD700),
                                    strokeWidth: 3,
                                    strokeColor: Colors.white.withOpacity(
                                      0.8,
                                    ), // Corrected: Use withOpacity
                                  );
                                }
                                return FlDotCirclePainter(
                                  radius: 0,
                                  color: Colors.transparent,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(show: false),
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
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
  ) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 80,
      borderRadius: 16,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.25), // Corrected: Use withOpacity
          Colors.white.withOpacity(0.1), // Corrected: Use withOpacity
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.3), // Corrected: Use withOpacity
          Colors.white.withOpacity(0.1), // Corrected: Use withOpacity
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2), // Corrected: Use withOpacity
              ),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(
                        0.8,
                      ), // Corrected: Use withOpacity
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(
                              0.7,
                            ), // Corrected: Use withOpacity
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
        return 'Immunsystem stärken';
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
        return 'Gesundheit verbessern';
      case 'more_energy':
        return 'Mehr Energie';
      default:
        return 'Fortschritt';
    }
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'weight_loss':
        return CupertinoIcons.arrow_down;
      case 'weight_gain':
        return CupertinoIcons.arrow_up;
      case 'muscle_gain':
        return CupertinoIcons.sportscourt;
      case 'improved_health':
        return CupertinoIcons.heart_fill;
      case 'more_energy':
        return CupertinoIcons.bolt;
      default:
        return CupertinoIcons.flag;
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
