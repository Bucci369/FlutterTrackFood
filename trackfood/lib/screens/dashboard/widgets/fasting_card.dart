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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A1A), // Dark card background start
            const Color(0xFF2A2A2A), // Dark card background middle (lighter)
            const Color(0xFF1A1A1A), // Dark card background end
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.2), // Card border - subtle white border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.white.withValues(alpha: 0.1), // Card glow shadow
            blurRadius: 40,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.8), // Card drop shadow
            blurRadius: 50,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: CupertinoColors.white.withValues(alpha: 0.05), // Card top light shadow
            blurRadius: 80,
            offset: const Offset(0, -10),
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
                    color: CupertinoColors.white, // Fasting title text color
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: CupertinoColors.white.withValues(alpha: 0.3), // Fasting title text shadow
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                if (isFasting)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.systemGreen.withValues(alpha: 0.3), // Active badge background gradient start - green
                          CupertinoColors.systemGreen.withValues(alpha: 0.1), // Active badge background gradient end - green
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppTheme.cornerRadiusS,
                      ),
                      border: Border.all(
                        color: CupertinoColors.systemGreen.withValues(alpha: 0.6), // Active badge border - green
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGreen.withValues(alpha: 0.4), // Active badge glow shadow - green
                          blurRadius: 15,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Text(
                      'AKTIV',
                      style: AppTypography.footnote.copyWith(
                        color: CupertinoColors.white, // Active badge text color
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
                                    color: CupertinoColors.white, // Progress percentage text color
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
                            color: CupertinoColors.white, // Active fasting plan text color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Läuft seit: ${_formatDuration(_currentFastingTime)}',
                          style: AppTypography.body.copyWith(
                            color: CupertinoColors.white.withValues(alpha: 0.8), // Active fasting duration text color
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ziel: ${_formatDuration(_fastingDuration)}',
                          style: AppTypography.footnote.copyWith(
                            color: CupertinoColors.white.withValues(alpha: 0.6), // Active fasting goal text color
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: AppTheme.paddingM),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CupertinoColors.systemRed, // Stop fasting button background gradient start - red
                      CupertinoColors.systemRed.withValues(alpha: 0.8), // Stop fasting button background gradient end - red
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.cornerRadiusM),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemRed.withValues(alpha: 0.4), // Stop fasting button glow shadow - red
                      blurRadius: 20,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: CupertinoButton(
                  onPressed: _stopFasting,
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
                          gradient: LinearGradient(
                            colors: isSelected
                                ? [
                                    const Color(0xFF2A2A2A), // Selected fasting type background start
                                    const Color(0xFF1A1A1A), // Selected fasting type background end
                                  ]
                                : [
                                    const Color(0xFF1A1A1A), // Unselected fasting type background start
                                    const Color(0xFF0F0F0F), // Unselected fasting type background end
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? type.color.withValues(alpha: 0.6)
                                : CupertinoColors.white.withValues(alpha: 0.1), // Unselected fasting type border
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: type.color.withValues(alpha: 0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 0),
                                  ),
                                ]
                              : [],
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
                                      color: CupertinoColors.white, // Fasting type name text color
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    type.description,
                                    style: AppTypography.footnote.copyWith(
                                      color: CupertinoColors.white.withValues(alpha: 0.7), // Fasting type description text color
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
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _fastingTypes[_selectedFastingType].color, // Start fasting button background gradient start - dynamic color
                      _fastingTypes[_selectedFastingType].color.withValues(alpha: 0.8), // Start fasting button background gradient end - dynamic color
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.cornerRadiusM),
                  boxShadow: [
                    BoxShadow(
                      color: _fastingTypes[_selectedFastingType].color.withValues(alpha: 0.4), // Start fasting button glow shadow - dynamic color
                      blurRadius: 20,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: CupertinoButton(
                  onPressed: _startFasting,
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
      ..color = CupertinoColors.white.withValues(alpha: 0.1) // Progress ring background color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      // Add glow effect
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      final sweepAngle = 2 * math.pi * progress;
      
      // Draw glow effect first
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
      
      // Draw main progress arc
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
