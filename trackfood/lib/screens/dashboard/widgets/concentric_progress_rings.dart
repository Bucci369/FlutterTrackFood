import 'package:flutter/cupertino.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import 'dart:math' as math;

class ConcentricProgressRings extends StatefulWidget {
  final double calorieProgress;
  final double caloriesCurrent;
  final double caloriesGoal;
  final double waterProgress;
  final double waterCurrent;
  final double waterGoal;
  final double burnedCalories;
  final double burnedCaloriesGoal;

  const ConcentricProgressRings({
    super.key,
    required this.calorieProgress,
    required this.caloriesCurrent,
    required this.caloriesGoal,
    required this.waterProgress,
    required this.waterCurrent,
    required this.waterGoal,
    required this.burnedCalories,
    this.burnedCaloriesGoal = 500.0,
  });

  @override
  State<ConcentricProgressRings> createState() =>
      _ConcentricProgressRingsState();
}

class _ConcentricProgressRingsState extends State<ConcentricProgressRings>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _calorieAnimation;
  late Animation<double> _waterAnimation;
  late Animation<double> _burnedAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Create staggered animations for each ring
    _calorieAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _waterAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _burnedAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Start animation
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ConcentricProgressRings oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart animation when data changes
    if (widget.calorieProgress != oldWidget.calorieProgress ||
        widget.waterProgress != oldWidget.waterProgress ||
        widget.burnedCalories != oldWidget.burnedCalories) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF2A2A2A),
            const Color(0xFF1A1A1A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.white.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.8),
            blurRadius: 50,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: CupertinoColors.white.withValues(alpha: 0.05),
            blurRadius: 80,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced Title with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.systemBlue.withValues(alpha: 0.3),
                      AppColors.systemBlue.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.systemBlue.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.systemBlue.withValues(alpha: 0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Icon(
                  CupertinoIcons.chart_pie_fill,
                  color: CupertinoColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Heutige Ziele',
                style: AppTypography.title2.copyWith(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      color: CupertinoColors.white.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // Reduced vertical space
          // Enhanced Concentric Rings with glow effect
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.white.withValues(alpha: 0.15),
                  blurRadius: 60,
                  offset: const Offset(0, 0),
                ),
                BoxShadow(
                  color: AppColors.systemBlue.withValues(alpha: 0.3),
                  blurRadius: 80,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConcentricRingsPainter(
                    calorieProgress:
                        widget.calorieProgress * _calorieAnimation.value,
                    waterProgress: widget.waterProgress * _waterAnimation.value,
                    burnedProgress:
                        (widget.burnedCaloriesGoal > 0
                            ? widget.burnedCalories / widget.burnedCaloriesGoal
                            : 0.0) *
                        _burnedAnimation.value,
                  ),
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2A2A2A),
                            const Color(0xFF1A1A1A),
                            const Color(0xFF2A2A2A),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        border: Border.all(
                          color: CupertinoColors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.white.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 0),
                          ),
                          BoxShadow(
                            color: CupertinoColors.black.withValues(alpha: 0.8),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${((widget.calorieProgress * 100).clamp(0, 100)).toInt()}%',
                            style: AppTypography.title1.copyWith(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 32,
                              shadows: [
                                Shadow(
                                  color: CupertinoColors.white.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Erreicht',
                            style: AppTypography.body.copyWith(
                              color: CupertinoColors.white.withValues(
                                alpha: 0.8,
                              ),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(
            height: 20,
          ), // Reduced space to make the card more compact
          // Enhanced Legend with better spacing
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2A2A2A),
                  const Color(0xFF1A1A1A),
                  const Color(0xFF2A2A2A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.white.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(
                  color: CupertinoColors.systemRed.darkColor,
                  label: 'Kalorien',
                  value: '${widget.caloriesCurrent.toInt()}',
                  icon: CupertinoIcons.flame_fill,
                ),
                Container(
                  width: 1,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CupertinoColors.white.withValues(alpha: 0.1),
                        CupertinoColors.white.withValues(alpha: 0.3),
                        CupertinoColors.white.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                _buildLegendItem(
                  color: CupertinoColors.systemBlue,
                  label: 'Wasser',
                  value: '${(widget.waterCurrent / 1000).toStringAsFixed(1)}L',
                  icon: CupertinoIcons.drop_fill,
                ),
                Container(
                  width: 1,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CupertinoColors.white.withValues(alpha: 0.1),
                        CupertinoColors.white.withValues(alpha: 0.3),
                        CupertinoColors.white.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                _buildLegendItem(
                  color: CupertinoColors.systemOrange,
                  label: 'Verbrannt',
                  value: '${widget.burnedCalories.toInt()}',
                  icon: CupertinoIcons.bolt_fill,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.3),
                  color.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: CupertinoColors.white,
              size: 24,
            ), // 🎨 LEGENDE ICONS: Weiß
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.body.copyWith(
              color: CupertinoColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              shadows: [
                Shadow(
                  color: CupertinoColors.white.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption1.copyWith(
              color: CupertinoColors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ConcentricRingsPainter extends CustomPainter {
  final double calorieProgress;
  final double waterProgress;
  final double burnedProgress;

  ConcentricRingsPainter({
    required this.calorieProgress,
    required this.waterProgress,
    required this.burnedProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2 - 20;

    // Ring definitions (from outer to inner) - only 3 rings with equal stroke width
    final rings = [
      // Outer ring - Calories (rötlich)
      {
        'progress': calorieProgress.clamp(0.0, 1.0),
        'colors': [
          CupertinoColors.systemRed.darkColor,
          CupertinoColors.systemPink,
        ],
        'radius': baseRadius,
        'strokeWidth': 10.0,
      },
      // Middle ring - Water (sattes iOS Blau)
      {
        'progress': waterProgress.clamp(0.0, 1.0),
        'colors': [CupertinoColors.systemBlue, CupertinoColors.systemTeal],
        'radius': baseRadius - 18,
        'strokeWidth': 10.0,
      },
      // Inner ring - Burned Calories (Orange)
      {
        'progress': burnedProgress.clamp(0.0, 1.0),
        'colors': [CupertinoColors.systemOrange, CupertinoColors.systemYellow],
        'radius': baseRadius - 36,
        'strokeWidth': 10.0,
      },
    ];

    // Draw each ring
    for (final ring in rings) {
      final progress = ring['progress'] as double;
      final colors = ring['colors'] as List<Color>;
      final radius = ring['radius'] as double;
      final strokeWidth = ring['strokeWidth'] as double;

      // Skip if radius is too small
      if (radius <= 0) continue;

      // Background circle
      final backgroundPaint = Paint()
        ..color =
            const Color(
              0xFFE5E5EA,
            ) // 3 Ringe Hintergrund A much lighter gray for visibility
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius, backgroundPaint);

      // Progress arc
      if (progress > 0) {
        final progressPaint = Paint()
          ..shader = LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        final sweepAngle = 2 * math.pi * progress;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2, // Start from top
          sweepAngle,
          false,
          progressPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ConcentricRingsPainter oldDelegate) {
    return oldDelegate.calorieProgress != calorieProgress ||
        oldDelegate.waterProgress != waterProgress ||
        oldDelegate.burnedProgress != burnedProgress;
  }
}
