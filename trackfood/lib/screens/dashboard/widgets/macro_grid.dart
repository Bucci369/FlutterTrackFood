import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import 'dart:math' as math;

class MacroGrid extends StatelessWidget {
  final Map<String, double> macros;

  const MacroGrid({
    super.key,
    required this.macros,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nährstoffe',
            style: AppTypography.headline.copyWith(
              color: AppColors.label,
            ),
          ),
          const SizedBox(height: 20),
          // Grid of 6 macro circles (2 rows x 3 columns)
          Row(
            children: [
              Expanded(child: _buildMacroRing('Eiweiß', macros['protein'] ?? 0, 50, CupertinoColors.systemRed, 0)),
              const SizedBox(width: 16),
              Expanded(child: _buildMacroRing('Kohlenhydrate', macros['carbs'] ?? 0, 150, CupertinoColors.systemBlue, 1)),
              const SizedBox(width: 16),
              Expanded(child: _buildMacroRing('Fett', macros['fat'] ?? 0, 70, CupertinoColors.systemGreen, 2)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMacroRing('Ballaststoffe', macros['fiber'] ?? 0, 25, CupertinoColors.systemOrange, 3)),
              const SizedBox(width: 16),
              Expanded(child: _buildMacroRing('Zucker', macros['sugar'] ?? 0, 50, CupertinoColors.systemPurple, 4)),
              const SizedBox(width: 16),
              Expanded(child: _buildMacroRing('Natrium', macros['sodium'] ?? 0, 2300, CupertinoColors.systemYellow, 5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRing(String label, double current, double goal, Color color, int index) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CustomPaint(
            painter: MacroRingPainter(
              progress: progress,
              color: color,
              strokeWidth: 6,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${current.toInt()}',
                    style: AppTypography.body.copyWith(
                      color: AppColors.label,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${goal.toInt()}',
                    style: AppTypography.body.copyWith(
                      color: AppColors.secondaryLabel,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: AppTypography.body.copyWith(
                  color: AppColors.label,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    )
    .animate(delay: Duration(milliseconds: 100 * index))
    .fadeIn(duration: 400.ms)
    .scale(begin: const Offset(0.8, 0.8));
  }
}

class MacroRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  MacroRingPainter({
    required this.progress,
    required this.color,
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
        ..color = color
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
  bool shouldRepaint(MacroRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}