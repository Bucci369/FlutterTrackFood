import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/providers/dashboard_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_typography.dart';

// A dedicated class for fasting types to improve type safety and avoid caching issues.
class FastingType {
  final String key;
  final String name;
  final String description;
  final Duration duration;
  final Color color;
  final String emoji;

  const FastingType({
    required this.key,
    required this.name,
    required this.description,
    required this.duration,
    required this.color,
    required this.emoji,
  });
}

const List<FastingType> _kFastingTypes = [
  FastingType(
    key: 'intermittent_16_8',
    name: '16:8',
    description: '16h fasten, 8h essen',
    duration: Duration(hours: 16),
    color: CupertinoColors.systemGreen,
    emoji: '⏰',
  ),
  FastingType(
    key: 'intermittent_18_6',
    name: '18:6',
    description: '18h fasten, 6h essen',
    duration: Duration(hours: 18),
    color: CupertinoColors.systemBlue,
    emoji: '🕕',
  ),
  FastingType(
    key: 'intermittent_20_4',
    name: '20:4',
    description: '20h fasten, 4h essen',
    duration: Duration(hours: 20),
    color: CupertinoColors.systemPurple,
    emoji: '⚔️',
  ),
  FastingType(
    key: 'custom_24',
    name: '24h',
    description: 'Ganztägiges Fasten',
    duration: Duration(hours: 24),
    color: CupertinoColors.systemRed,
    emoji: '🌅',
  ),
];

class FastingCard extends ConsumerStatefulWidget {
  const FastingCard({super.key});

  @override
  ConsumerState<FastingCard> createState() => _FastingCardState();
}

class _FastingCardState extends ConsumerState<FastingCard>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  Timer? _timer;

  // Local state for UI, managed by Riverpod
  // bool _isFasting = false;
  // DateTime? _fastingStartTime;
  Duration _fastingDuration = const Duration(hours: 16); // 16:8 default
  Duration _currentFastingTime = Duration.zero;

  final List<FastingType> _fastingTypes = _kFastingTypes;

  int _selectedFastingType = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initial load is handled by the provider
  }

  @override
  void dispose() {
    _progressController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startFasting() {
    final fastingTypeData = _fastingTypes[_selectedFastingType];
    final planName =
        '${fastingTypeData.duration.inHours}:${24 - fastingTypeData.duration.inHours}';

    ref
        .read(fastingProvider.notifier)
        .startFasting(fastingTypeData.key, planName, fastingTypeData.duration);
  }

  void _stopFasting() {
    ref.read(fastingProvider.notifier).stopFasting();
  }

  void _startTimer(DateTime startTime) {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Calculate difference in UTC to avoid timezone issues
          _currentFastingTime = DateTime.now().toUtc().difference(
            startTime.toUtc(),
          );
        });

        final progress =
            _currentFastingTime.inSeconds / _fastingDuration.inSeconds;
        if (progress >= 1.0) {
          _progressController.animateTo(1.0);
          _completeFasting();
        } else {
          _progressController.animateTo(progress.clamp(0.0, 1.0));
        }
      }
    });
  }

  void _completeFasting() {
    _timer?.cancel();
    // Optionally show a celebration and then stop
    _stopFasting();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final fastingState = ref.watch(fastingProvider);
    final session = fastingState.session;
    final isFasting = session != null && session.isActive;

    // Update timer and duration when fasting state changes
    if (isFasting) {
      _fastingDuration = Duration(hours: session.targetDurationHours ?? 16);
      if (_timer == null || !_timer!.isActive) {
        _startTimer(session.startTime);
      }
    } else {
      _timer?.cancel();
      _progressController.reset();
      _currentFastingTime = Duration.zero;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF6F1E7), // Apple White
        border: Border.all(color: AppColors.separator, width: 1),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AnimatedSize(
        duration: AppTheme.animDuration,
        curve: AppTheme.animCurve,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Intervallfasten',
                  style: AppTypography.headline.copyWith(
                    color: AppColors.label,
                  ),
                ),
                if (isFasting)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(
                        AppTheme.cornerRadiusS,
                      ),
                      border: Border.all(
                        color: CupertinoColors.systemGreen.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'AKTIV',
                      style: AppTypography.footnote.copyWith(
                        color: CupertinoColors.systemGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingM),

            if (fastingState.isLoading && !isFasting)
              const Center(child: CupertinoActivityIndicator())
            else if (isFasting) ...[
              // Active fasting display
              Row(
                children: [
                  // Progress ring
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: FastingProgressPainter(
                            progress: _progressController.value,
                            color: _fastingTypes
                                .firstWhere(
                                  (t) => t.key == session.fastingType,
                                  orElse: () => _fastingTypes.first,
                                )
                                .color,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _fastingTypes
                                      .firstWhere(
                                        (t) => t.key == session.fastingType,
                                        orElse: () => _fastingTypes.first,
                                      )
                                      .emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(_progressController.value * 100).toInt()}%',
                                  style: AppTypography.footnote.copyWith(
                                    color: AppColors.label,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.plan, // Removed unnecessary null-check
                          style: AppTypography.title3.copyWith(
                            color: AppColors.label,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Läuft seit: ${_formatDuration(_currentFastingTime)}',
                          style: AppTypography.body.copyWith(
                            color: AppColors.secondaryLabel,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ziel: ${_formatDuration(_fastingDuration)}',
                          style: AppTypography.footnote.copyWith(
                            color: AppColors.tertiaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: AppTheme.paddingM),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: _stopFasting,
                  color: CupertinoColors.systemRed,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  borderRadius: BorderRadius.circular(AppTheme.cornerRadiusM),
                  child: const Text(
                    'Fasten beenden',
                    style: AppTypography.button,
                  ),
                ),
              ),
            ] else ...[
              // Fasting type selector
              SizedBox(
                height: 85,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.9),
                  itemCount: _fastingTypes.length,
                  onPageChanged: (index) {
                    setState(() => _selectedFastingType = index);
                  },
                  itemBuilder: (context, index) {
                    final type = _fastingTypes[index];
                    final isSelected = index == _selectedFastingType;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedFastingType = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(AppTheme.paddingS),
                        decoration: BoxDecoration(
                          borderRadius: AppTheme.borderRadiusM,
                          color: isSelected
                              ? AppColors.fill
                              : AppColors.secondaryBackground,
                          border: Border.all(
                            color: isSelected
                                ? type.color
                                : AppColors.separator,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              type.emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    type.name,
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.label,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    type.description,
                                    style: AppTypography.footnote.copyWith(
                                      color: AppColors.secondaryLabel,
                                    ),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppTheme.paddingM),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: _startFasting,
                  color: _fastingTypes[_selectedFastingType].color,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  borderRadius: BorderRadius.circular(AppTheme.cornerRadiusM),
                  child: Text(
                    '${_fastingTypes[_selectedFastingType].name} starten',
                    style: AppTypography.button,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FastingProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  FastingProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background circle
    final backgroundPaint = Paint()
      ..color = AppColors.separator
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(FastingProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
