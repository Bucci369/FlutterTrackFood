import 'package:flutter/cupertino.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import 'dart:math' as math;

class ProgressRings extends StatefulWidget {
  final double calorieProgress;
  final double caloriesCurrent;
  final double caloriesGoal;
  final double waterProgress;
  final double waterCurrent;
  final double waterGoal;

  const ProgressRings({
    super.key,
    required this.calorieProgress,
    required this.caloriesCurrent,
    required this.caloriesGoal,
    required this.waterProgress,
    required this.waterCurrent,
    required this.waterGoal,
  });

  @override
  State<ProgressRings> createState() => _ProgressRingsState();
}

class _ProgressRingsState extends State<ProgressRings>
    with TickerProviderStateMixin {
  late AnimationController _calorieController;
  late AnimationController _waterController;

  @override
  void initState() {
    super.initState();
    _calorieController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _waterController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Start animations with delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _calorieController.animateTo(widget.calorieProgress.clamp(0.0, 1.0));
      }
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        _waterController.animateTo(widget.waterProgress.clamp(0.0, 1.0));
      }
    });
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _waterController.dispose();
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
        border: Border.all(
          color: AppColors.separator,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Calorie Ring
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: AnimatedBuilder(
                      animation: _calorieController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: ProgressRingPainter(
                            progress: _calorieController.value,
                            colors: const [
                              Color(0xFF99D98C),
                              Color(0xFF34A0A4),
                            ],
                            strokeWidth: 8,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${widget.caloriesCurrent.toInt()}',
                                  style: AppTypography.title2.copyWith(
                                    color: AppColors.label,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${widget.caloriesGoal.toInt()}',
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.secondaryLabel,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.flame_fill,
                        color: CupertinoColors.systemOrange,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Kalorien',
                        style: AppTypography.body.copyWith(
                          color: AppColors.label,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 32),
            
            // Water Ring
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: AnimatedBuilder(
                      animation: _waterController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: ProgressRingPainter(
                            progress: _waterController.value,
                            colors: const [
                              Color(0xFF00BCD4),
                              Color(0xFF0097A7),
                            ],
                            strokeWidth: 8,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${widget.waterCurrent.toInt()}',
                                  style: AppTypography.title2.copyWith(
                                    color: AppColors.label,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${widget.waterGoal.toInt()}',
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.secondaryLabel,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.drop_fill,
                        color: CupertinoColors.systemBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Gläser',
                        style: AppTypography.body.copyWith(
                          color: AppColors.label,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
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
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final double strokeWidth;

  ProgressRingPainter({
    required this.progress,
    required this.colors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = AppColors.separator
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

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}