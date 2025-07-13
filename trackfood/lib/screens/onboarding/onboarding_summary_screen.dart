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
          CupertinoPageRoute(
            builder: (context) => const CupertinoPageScaffold(
              child: Center(
                child: Text('Dashboard wird geladen...'),
              ),
            ),
          ),
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
      backgroundColor: CupertinoColors.systemBackground,
      child: Stack(
        children: [
          // Enhanced animated background with Cupertino colors
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
                          0.8 + 0.2 * math.sin(_backgroundController.value * 2 * math.pi),
                        ),
                        CupertinoColors.systemBlue.withOpacity(
                          0.8 + 0.2 * math.cos(_backgroundController.value * 2 * math.pi + math.pi / 2),
                        ),
                        CupertinoColors.systemIndigo.withOpacity(
                          0.6 + 0.1 * math.sin(_backgroundController.value * 3 * math.pi),
                        ),
                      ],
                      transform: GradientRotation(_backgroundController.value * 2 * math.pi / 4),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Enhanced confetti with more particles and colors
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -math.pi / 2,
              maxBlastForce: 25,
              minBlastForce: 15,
              emissionFrequency: 0.03,
              numberOfParticles: 30,
              gravity: 0.15,
              shouldLoop: false,
              colors: const [
                CupertinoColors.systemYellow,
                CupertinoColors.systemBlue,
                CupertinoColors.systemPink,
                CupertinoColors.systemGreen,
                CupertinoColors.systemOrange,
                CupertinoColors.systemPurple,
              ],
            ),
          ),
          
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
                              color: CupertinoColors.white,
                              size: 24,
                            ),
                          ),
                          Text(
                            'Schritt 6 von 6',
                            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: CupertinoColors.white.withOpacity(0.9),
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
                          color: CupertinoColors.white.withOpacity(0.3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: CupertinoColors.white,
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
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .navLargeTitleTextStyle
                                .copyWith(
                                  color: CupertinoColors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                          ).animate()
                           .fadeIn(duration: 600.ms, delay: 300.ms)
                           .slideY(begin: 0.3, end: 0)
                           .then() // Chain animations
                           .shimmer(duration: 1500.ms, color: CupertinoColors.white.withOpacity(0.3)),
                          
                          const SizedBox(height: 12),
                          
                          Text(
                            'Dein persönlicher Ernährungsplan ist bereit! Hier ist deine Zusammenfassung:',
                            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              color: CupertinoColors.white.withOpacity(0.9),
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                            ),
                          ).animate()
                           .fadeIn(duration: 600.ms, delay: 500.ms)
                           .slideY(begin: 0.2, end: 0),
                          
                          const SizedBox(height: 40),
                          
                          // Enhanced Progress Chart
                          _buildProgressChart(weight, targetWeight, goal)
                              .animate()
                              .slideY(begin: 0.3, duration: 800.ms, delay: 700.ms)
                              .fadeIn(duration: 800.ms, delay: 700.ms)
                              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                          
                          const SizedBox(height: 24),
                          
                          // Summary Cards with enhanced animations
                          _buildModernSummaryCard(
                            'BMI Bewertung',
                            bmi.toStringAsFixed(1),
                            _getBMICategory(bmi),
                            CupertinoIcons.heart_circle,
                            _getBMIColor(bmi),
                            0,
                          ).animate()
                           .slideX(begin: -0.3, duration: 600.ms, delay: 900.ms)
                           .fadeIn(duration: 600.ms, delay: 900.ms),
                          
                          const SizedBox(height: 16),
                          
                          _buildModernSummaryCard(
                            _getGoalTitle(goal),
                            '${targetWeight.toStringAsFixed(1)} kg',
                            '${_getGoalDescription(goal)}: ${progressPercentage.abs()}%',
                            _getGoalIcon(goal),
                            _getGoalColor(goal),
                            1,
                          ).animate()
                           .slideX(begin: 0.3, duration: 600.ms, delay: 1000.ms)
                           .fadeIn(duration: 600.ms, delay: 1000.ms),
                          
                          const SizedBox(height: 16),
                          
                          _buildModernSummaryCard(
                            'Ernährungstyp',
                            _getDietDisplayName(profile.dietType ?? 'standard'),
                            profile.isGlutenfree == true ? 'Glutenfrei' : 'Normales Gluten',
                            CupertinoIcons.leaf_arrow_circlepath,
                            CupertinoColors.systemGreen,
                            2,
                          ).animate()
                           .slideX(begin: -0.3, duration: 600.ms, delay: 1100.ms)
                           .fadeIn(duration: 600.ms, delay: 1100.ms),
                          
                          const SizedBox(height: 40),
                          
                          // Enhanced completion button with pulse animation
                          Center(
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + (_pulseController.value * 0.05),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: CupertinoColors.white.withOpacity(0.3),
                                          blurRadius: 20 + (_pulseController.value * 10),
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: CupertinoButton.filled(
                                      onPressed: _isLoading ? null : () => _handleComplete(profile),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 50,
                                        vertical: 18,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      child: _isLoading
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CupertinoActivityIndicator(
                                                  color: CupertinoColors.white,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Wird gespeichert...',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: CupertinoColors.white,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  CupertinoIcons.rocket,
                                                  color: CupertinoColors.white,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Los geht\'s!',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: CupertinoColors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ).animate()
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
        ],
      ),
    );
  }

  Widget _buildProgressChart(double currentWeight, double targetWeight, String goal) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: CupertinoColors.white.withOpacity(0.15),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.3),
          width: 1,
        ),
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
                color: CupertinoColors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Dein Weg zum Ziel',
                style: TextStyle(
                  color: CupertinoColors.white,
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
              _buildLegendItem('Gewichtsverlauf', CupertinoColors.white),
              const SizedBox(width: 24),
              _buildLegendItem('Zielbereich', CupertinoColors.systemYellow),
            ],
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: AnimatedBuilder(
              animation: _chartController,
              builder: (context, child) {
                final animationProgress = _chartController.value;
                
                List<FlSpot> weightSpots = [];
                List<FlSpot> targetSpots = [];
                final startWeight = currentWeight;
                final endWeight = targetWeight;

                if (animationProgress > 0) {
                  final progressPoints = (animationProgress * 50).round();
                  for (int i = 0; i <= progressPoints && i <= 50; i++) {
                    final t = i / 50;
                    final x = t * 6;
                    
                    // Enhanced S-curve for weight progression
                    final weightY = startWeight + (endWeight - startWeight) * 
                        (1 - math.cos(math.pi * t)) / 2;
                    
                    // Target zone with slight variation
                    final targetY = endWeight + 0.8 * math.sin(math.pi * t * 3);
                    
                    weightSpots.add(FlSpot(x, weightY));
                    targetSpots.add(FlSpot(x, targetY));
                  }
                }

                return LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 6,
                    minY: goal == 'weight_loss' ? targetWeight - 3 : currentWeight - 3,
                    maxY: goal == 'weight_loss' ? currentWeight + 3 : targetWeight + 3,
                    lineBarsData: [
                      // Main weight line
                      if (weightSpots.isNotEmpty)
                        LineChartBarData(
                          spots: weightSpots,
                          isCurved: true,
                          color: CupertinoColors.white,
                          barWidth: 4,
                          dotData: FlDotData(
                            show: animationProgress > 0.8,
                            getDotPainter: (spot, percent, barData, index) {
                              if (index == 0 || index == weightSpots.length - 1) {
                                return FlDotCirclePainter(
                                  radius: 8,
                                  color: CupertinoColors.white,
                                  strokeWidth: 3,
                                  strokeColor: CupertinoColors.systemBlue,
                                );
                              }
                              return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: animationProgress > 0.6,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                CupertinoColors.white.withOpacity(0.3),
                                CupertinoColors.white.withOpacity(0.05),
                              ],
                            ),
                          ),
                        ),
                      
                      // Target zone line
                      if (targetSpots.isNotEmpty)
                        LineChartBarData(
                          spots: targetSpots,
                          isCurved: true,
                          color: CupertinoColors.systemYellow,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          dashArray: [8, 4],
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
            color: CupertinoColors.white.withOpacity(0.9),
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
        color: CupertinoColors.white.withOpacity(0.15),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.3),
          width: 1,
        ),
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
              border: Border.all(
                color: color.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Icon(icon, size: 26, color: CupertinoColors.white),
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
                    color: CupertinoColors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.white.withOpacity(0.7),
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
