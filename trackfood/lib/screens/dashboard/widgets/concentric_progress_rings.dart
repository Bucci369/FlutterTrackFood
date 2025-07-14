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
  State<ConcentricProgressRings> createState() => _ConcentricProgressRingsState();
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF6F1E7), // Apple White
        border: Border.all(color: AppColors.separator, width: 1),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          Text(
            'Heute\'s Ziele',
            style: AppTypography.title2.copyWith(
              color: AppColors.label,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Concentric Rings
          SizedBox(
            width: 280,
            height: 280,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConcentricRingsPainter(
                    calorieProgress: widget.calorieProgress * _calorieAnimation.value,
                    waterProgress: widget.waterProgress * _waterAnimation.value,
                    burnedProgress: (widget.burnedCaloriesGoal > 0 
                        ? widget.burnedCalories / widget.burnedCaloriesGoal 
                        : 0.0) * _burnedAnimation.value,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${((widget.calorieProgress * 100).clamp(0, 100)).toInt()}%',
                          style: AppTypography.title1.copyWith(
                            color: AppColors.label,
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        ),
                        Text(
                          'Erreicht',
                          style: AppTypography.body.copyWith(
                            color: AppColors.secondaryLabel,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                color: CupertinoColors.systemRed.darkColor,
                label: 'Kalorien',
                value: '${widget.caloriesCurrent.toInt()}',
                icon: CupertinoIcons.flame_fill,
              ),
              _buildLegendItem(
                color: CupertinoColors.systemBlue,
                label: 'Wasser',
                value: '${(widget.waterCurrent / 1000).toStringAsFixed(1)}L',
                icon: CupertinoIcons.drop_fill,
              ),
              _buildLegendItem(
                color: CupertinoColors.systemOrange,
                label: 'Verbrannt',
                value: '${widget.burnedCalories.toInt()}',
                icon: CupertinoIcons.bolt_fill,
              ),
            ],
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
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.body.copyWith(
            color: AppColors.label,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption1.copyWith(
            color: AppColors.secondaryLabel,
          ),
        ),
      ],
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
        'colors': [CupertinoColors.systemRed.darkColor, CupertinoColors.systemPink],
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
        ..color = AppColors.separator.withValues(alpha: 0.3)
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