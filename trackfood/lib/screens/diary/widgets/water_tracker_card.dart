import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../../../models/water_intake.dart';
import '../../../services/supabase_service.dart';

class WaterTrackerCard extends StatefulWidget {
  final WaterIntake? waterIntake;
  final DateTime selectedDate;
  final VoidCallback onWaterAdded;

  const WaterTrackerCard({
    super.key,
    this.waterIntake,
    required this.selectedDate,
    required this.onWaterAdded,
  });

  @override
  State<WaterTrackerCard> createState() => _WaterTrackerCardState();
}

class _WaterTrackerCardState extends State<WaterTrackerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _waveController.repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  int get _currentAmount => widget.waterIntake?.amountMl ?? 0;
  int get _dailyGoal => widget.waterIntake?.dailyGoalMl ?? 2000; // Default 2L
  double get _progress => _currentAmount / _dailyGoal;

  Future<void> _addWater(int amountMl) async {
    if (_isAdding) return;

    setState(() => _isAdding = true);
    HapticFeedback.lightImpact();

    try {
      final supabaseService = SupabaseService();
      final userId = supabaseService.currentUserId;

      if (userId == null) return;

      final dateString = widget.selectedDate.toIso8601String().split('T')[0];
      final newAmount = _currentAmount + amountMl;

      if (widget.waterIntake != null) {
        // Update existing record
        await supabaseService.client
            .from('water_intake')
            .update({
              'amount_ml': newAmount,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', widget.waterIntake!.id);
      } else {
        // Create new record
        await supabaseService.client.from('water_intake').insert({
          'user_id': userId,
          'date': dateString,
          'amount_ml': newAmount,
          'daily_goal_ml': _dailyGoal,
        });
      }

      widget.onWaterAdded();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Speichern: $e')));
      }
    } finally {
      setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 200,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Wasser',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: Colors.blue.withValues(alpha: 0.8),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(_currentAmount / 1000).toStringAsFixed(1)}L / ${(_dailyGoal / 1000).toStringAsFixed(1)}L',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress visualization with wave effect
            Expanded(
              child: Row(
                children: [
                  // Water progress circle
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background circle
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        // Water fill with wave animation
                        AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            return ClipOval(
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: CustomPaint(
                                  painter: WavePainter(
                                    progress: _progress,
                                    wavePhase:
                                        _waveController.value * 2 * 3.14159,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Progress text
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Quick add buttons
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildQuickAddButton('250ml', 250)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildQuickAddButton('500ml', 500)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildQuickAddButton('750ml', 750)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildQuickAddButton('1L', 1000)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddButton(String label, int amountMl) {
    return GestureDetector(
          onTap: _isAdding ? null : () => _addWater(amountMl),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: _isAdding
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * (amountMl ~/ 250)))
        .scale(begin: const Offset(0.8, 0.8))
        .fadeIn(duration: 300.ms);
  }
}

class WavePainter extends CustomPainter {
  final double progress;
  final double wavePhase;

  WavePainter({required this.progress, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final fillHeight = size.height * progress;
    final waveHeight = 8.0;
    final waveLength = size.width / 2;

    final path = Path();

    // Start from bottom left
    path.moveTo(0, size.height);

    // Draw bottom and sides
    path.lineTo(0, size.height - fillHeight + waveHeight);

    // Draw wave at water surface
    for (double x = 0; x <= size.width; x += 1) {
      final waveY =
          size.height -
          fillHeight +
          (waveHeight *
              (1 + progress * 0.5) *
              (sin((x / waveLength * 2 * 3.14159) + wavePhase) * 0.5 + 0.5));

      if (x == 0) {
        path.lineTo(x, waveY);
      } else {
        path.lineTo(x, waveY);
      }
    }

    // Complete the path
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.wavePhase != wavePhase;
  }
}
