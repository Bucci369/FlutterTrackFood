import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import 'dart:math' as math;

class MacroGrid extends StatelessWidget {
  final Map<String, double> macros;

  const MacroGrid({super.key, required this.macros});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A1A), // 🎨 NÄHRSTOFFE KARTE OBEN: Dunkelgrau
            const Color(0xFF2A2A2A), // 🎨 NÄHRSTOFFE KARTE MITTE: Helleres Grau
            const Color(0xFF1A1A1A), // 🎨 NÄHRSTOFFE KARTE UNTEN: Dunkelgrau
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
            color: CupertinoColors.white.withValues(
              alpha: 0.05,
            ), // Reduced glow
            blurRadius: 20, // Softened blur
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: CupertinoColors.black.withValues(
              alpha: 0.5,
            ), // Softened shadow
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title with underline
          Column(
            children: [
              Text(
                'Nährstoffe',
                style: AppTypography.headline.copyWith(
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
              const SizedBox(height: 8),
              Container(
                width: 180, // A bit wider than the text
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CupertinoColors.white.withOpacity(0.0),
                      CupertinoColors.white.withOpacity(0.4),
                      CupertinoColors.white.withOpacity(0.0),
                    ],
                    stops: const [0.1, 0.5, 0.9],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Grid of macro rings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildMacroRing(
                  'Eiweiß',
                  macros['protein'] ?? 0,
                  50,
                  CupertinoColors.systemRed,
                  0,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildMacroRing(
                  'Kohlenhydrate',
                  macros['carbs'] ?? 0,
                  150,
                  CupertinoColors.systemBlue,
                  1,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildMacroRing(
                  'Fett',
                  macros['fat'] ?? 0,
                  70,
                  CupertinoColors.systemGreen,
                  2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMacroRing(
                  'Ballaststoffe',
                  macros['fiber'] ?? 0,
                  25,
                  CupertinoColors.systemOrange,
                  3,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildMacroRing(
                  'Zucker',
                  macros['sugar'] ?? 0,
                  50,
                  CupertinoColors.systemPurple,
                  4,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildMacroRing(
                  'Natrium',
                  macros['sodium'] ?? 0,
                  2300,
                  CupertinoColors.systemYellow,
                  5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRing(
    String label,
    double current,
    double goal,
    Color color,
    int index,
  ) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(
                  0xFF2A2A2A,
                ), // 🎨 EINZELNE MAKRO RING OBEN: Helleres Grau
                const Color(
                  0xFF1A1A1A,
                ), // 🎨 EINZELNE MAKRO RING MITTE: Dunkelgrau
                const Color(
                  0xFF2A2A2A,
                ), // 🎨 EINZELNE MAKRO RING UNTEN: Helleres Grau
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(
                alpha: 0.4,
              ), // 🎨 MAKRO RING RAHMEN: Dynamische Farbe je Nährstoff 40%
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 25,
                offset: const Offset(0, 0),
              ),
              BoxShadow(
                color: CupertinoColors.white.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(
                  painter: MacroRingPainter(
                    progress: progress,
                    color: color,
                    strokeWidth: 8,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${current.toInt()}',
                          style: AppTypography.body.copyWith(
                            color: CupertinoColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: CupertinoColors.white.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CupertinoColors.white.withValues(alpha: 0.1),
                                CupertinoColors.white.withValues(alpha: 0.4),
                                CupertinoColors.white.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 2),
                        ),
                        Text(
                          '${goal.toInt()}',
                          style: AppTypography.body.copyWith(
                            color: CupertinoColors.white.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Enhanced label with icon
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.3),
                          color.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            label,
                            style: AppTypography.body.copyWith(
                              color: CupertinoColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Progress percentage
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTypography.caption1.copyWith(
                      color: CupertinoColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: color.withValues(alpha: 0.8),
                          blurRadius: 4,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
