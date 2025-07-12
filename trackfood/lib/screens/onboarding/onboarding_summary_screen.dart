import 'package:flutter/material.dart';
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
  bool _animateChart = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
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
        setState(() => _animateChart = true);
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
      case 'weight_loss': return 'lose_weight';
      case 'weight_gain': return 'gain_weight';
      case 'maintain_weight': return 'maintain_weight';
      case 'muscle_gain': return 'build_muscle';
      default: return 'maintain_weight';
    }
  }

  String _mapActivityToDatabase(String flutterActivity) {
    switch (flutterActivity) {
      case 'sedentary': return 'sedentary';
      case 'lightly_active': return 'lightly_active';
      case 'moderately_active': return 'moderately_active';
      case 'very_active': return 'very_active';
      case 'extremely_active': return 'extra_active';
      default: return 'moderately_active';
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
      final databaseGoal = _mapGoalToDatabase(profile.goal);
      final databaseActivity = _mapActivityToDatabase(profile.activityLevel);
      
      await client.from('profiles').update({
        'onboarding_completed': true,
        'age': profile.age,
        'gender': profile.gender,
        'height_cm': profile.heightCm,
        'weight_kg': profile.weightKg,
        'activity_level': databaseActivity,
        'goal': databaseGoal,
        'diet_type': profile.dietType,
        'is_glutenfree': profile.isGlutenfree ?? false,
        'first_name': profile.name.split(' ').first,
        'last_name': profile.name.split(' ').length > 1
            ? profile.name.split(' ').skip(1).join(' ')
            : '',
      }).eq('id', userId);
      
      if (mounted) {
        // The AuthWrapper will automatically show the dashboard when onboarding is completed
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern: $e')),
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final weight = profile.weightKg;
    final height = profile.heightCm;
    final targetWeight = profile.goal == 'weight_loss'
        ? (weight - 5)
        : profile.goal == 'weight_gain'
            ? (weight + 5)
            : weight;
    final bmi = weight / ((height / 100) * (height / 100));
    final progressPercentage = profile.goal == 'weight_loss'
        ? ((weight - targetWeight) / weight * 100).round()
        : profile.goal == 'weight_gain'
            ? ((targetWeight - weight) / weight * 100).round()
            : 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/background2.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black26,
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
                        const Color(0xFF99D98C).withValues(alpha: 0.7),
                        const Color(0xFF76C893).withValues(alpha: 0.6),
                        const Color(0xFF52B69A).withValues(alpha: 0.7),
                        const Color(0xFF34A0A4).withValues(alpha: 0.8),
                      ],
                      transform: GradientRotation(
                          _backgroundController.value * 2 * 3.14159),
                    ),
                  ),
                );
              },
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Celebration icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.celebration,
                          size: 50,
                          color: Colors.white,
                        ),
                      )
                          .animate()
                          .scale(
                              delay: 100.ms,
                              duration: 600.ms,
                              curve: Curves.elasticOut)
                          .shimmer(
                              delay: 200.ms,
                              duration: 1000.ms,
                              color: Colors.white),

                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        'Perfekt!',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),

                      const SizedBox(height: 8),

                      const Text(
                        'Dein persönlicher Plan ist bereit!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 600.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 40),

                      // Progress Chart
                      _buildProgressChart(weight, targetWeight, profile.goal)
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 800.ms)
                          .scale(
                              begin: const Offset(0.9, 0.9),
                              delay: 800.ms,
                              duration: 800.ms),

                      const SizedBox(height: 32),

                      // Summary Cards
                      _buildSummaryCard(
                        'BMI',
                        bmi.toStringAsFixed(1),
                        _getBMICategory(bmi),
                        Icons.monitor_weight,
                        _getBMIColor(bmi),
                      )
                          .animate()
                          .fadeIn(delay: 1000.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),

                      const SizedBox(height: 16),

                      _buildSummaryCard(
                        _getGoalTitle(profile.goal),
                        '$progressPercentage%',
                        _getGoalDescription(profile.goal),
                        _getGoalIcon(profile.goal),
                        _getGoalColor(profile.goal),
                      )
                          .animate()
                          .fadeIn(delay: 1100.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),

                      const SizedBox(height: 16),

                      _buildSummaryCard(
                        'Ernährung',
                        _getDietDisplayName(profile.dietType ?? 'standard'),
                        profile.isGlutenfree == true
                            ? 'Glutenfrei'
                            : 'Mit Gluten',
                        Icons.restaurant,
                        Colors.orange,
                      )
                          .animate()
                          .fadeIn(delay: 1200.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),

                      const SizedBox(height: 32),

                      // Motivational text
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: 80,
                        borderRadius: 20,
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
                        child: const Text(
                          '✨ Du bist startklar für deine Reise!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 1300.ms, duration: 600.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 40),

                      // Action Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _handleComplete(profile),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF34A0A4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            disabledBackgroundColor:
                                Colors.white.withValues(alpha: 0.5),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF34A0A4),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Los geht\'s! 🚀',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 1400.ms, duration: 600.ms)
                          .slideY(begin: 0.5, end: 0)
                          .scale(
                              begin: const Offset(0.95, 0.95), delay: 1400.ms),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Color(0xFFFFD700),
                  Color(0xFFFF6347),
                  Color(0xFF4682B4),
                  Color(0xFF32CD32),
                  Color(0xFF9370DB),
                  Color(0xFF99D98C),
                  Color(0xFF34A0A4),
                ],
                gravity: 0.3,
                emissionFrequency: 0.03,
                numberOfParticles: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart(
      double currentWeight, double targetWeight, String goal) {
    // Chart visualization (simplified for now)
    // Future: Add calorie deficit calculations

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
                      final weightY = startWeight +
                          (endWeight - startWeight) *
                              (0.5 - 0.5 * math.cos(math.pi * t));
                      // Goldene Linie: S-Kurve, aber immer knapp unterhalb der Gewichtskurve
                      final calorieY = weightY -
                          1.2 +
                          0.5 *
                              math.sin(math.pi * t -
                                  math.pi /
                                      2); // optisch ansprechend, immer sichtbar
                      calorieSpots.add(FlSpot(x, calorieY));
                      weightSpots.add(FlSpot(x, weightY));
                    }
                  }

                  return LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: 6,
                      minY: endWeight - 2,
                      maxY: startWeight + 2,
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
                                    strokeColor:
                                        Colors.white.withValues(alpha: 0.8),
                                  );
                                }
                                return FlDotCirclePainter(
                                    radius: 0, color: Colors.transparent);
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: animationProgress > 0.7,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.3),
                                  Colors.white.withValues(alpha: 0.1),
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
                                    strokeColor:
                                        Colors.white.withValues(alpha: 0.8),
                                  );
                                }
                                return FlDotCirclePainter(
                                    radius: 0, color: Colors.transparent);
                              },
                            ),
                            belowBarData: BarAreaData(show: false),
                          ),
                      ],
                      titlesData: FlTitlesData(
                        show: false,
                      ),
                      gridData: FlGridData(
                        show: false,
                      ),
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

  Widget _buildSummaryCard(String title, String value, String description,
      IconData icon, Color color) {
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
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.2),
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
                      color: Colors.white.withValues(alpha: 0.8),
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
                            color: Colors.white.withValues(alpha: 0.7),
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
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getGoalTitle(String goal) {
    switch (goal) {
      case 'weight_loss':
        return 'Gewichtsverlust';
      case 'weight_gain':
        return 'Gewichtszunahme';
      case 'muscle_gain':
        return 'Muskelaufbau';
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
      default:
        return 'Fortschritt';
    }
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'weight_loss':
        return Icons.trending_down;
      case 'weight_gain':
        return Icons.trending_up;
      case 'muscle_gain':
        return Icons.fitness_center;
      default:
        return Icons.flag;
    }
  }

  Color _getGoalColor(String goal) {
    switch (goal) {
      case 'weight_loss':
        return Colors.green;
      case 'weight_gain':
        return Colors.blue;
      case 'muscle_gain':
        return Colors.purple;
      default:
        return Colors.grey;
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
