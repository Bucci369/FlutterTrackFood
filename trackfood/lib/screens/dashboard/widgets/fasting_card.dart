import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:async';
import 'dart:math' as math;

class FastingCard extends StatefulWidget {
  const FastingCard({super.key});

  @override
  State<FastingCard> createState() => _FastingCardState();
}

class _FastingCardState extends State<FastingCard>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  Timer? _timer;
  
  bool _isFasting = false;
  DateTime? _fastingStartTime;
  Duration _fastingDuration = const Duration(hours: 16); // 16:8 default
  Duration _currentFastingTime = Duration.zero;
  
  final List<Map<String, dynamic>> _fastingTypes = [
    {
      'name': '16:8',
      'description': 'Intermittierendes Fasten',
      'duration': const Duration(hours: 16),
      'color': const Color(0xFF4CAF50),
      'emoji': '⏰',
    },
    {
      'name': '18:6',
      'description': 'Verlängertes Fasten',
      'duration': const Duration(hours: 18),
      'color': const Color(0xFF2196F3),
      'emoji': '🕕',
    },
    {
      'name': '20:4',
      'description': 'Warrior Diet',
      'duration': const Duration(hours: 20),
      'color': const Color(0xFF9C27B0),
      'emoji': '⚔️',
    },
    {
      'name': '24h',
      'description': 'Ganztägiges Fasten',
      'duration': const Duration(hours: 24),
      'color': const Color(0xFFFF5722),
      'emoji': '🌅',
    },
  ];
  
  int _selectedFastingType = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Load fasting state from storage/database
    _loadFastingState();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _loadFastingState() {
    // This would load from Supabase fasting_sessions table
    // For now, using sample state
    setState(() {
      _isFasting = false;
      _selectedFastingType = 0;
      _fastingDuration = _fastingTypes[0]['duration'];
    });
  }

  void _startFasting() {
    setState(() {
      _isFasting = true;
      _fastingStartTime = DateTime.now();
      _fastingDuration = _fastingTypes[_selectedFastingType]['duration'];
      _currentFastingTime = Duration.zero;
    });
    
    _startTimer();
    _progressController.forward();
    
    // Save to Supabase fasting_sessions table
    _saveFastingSession();
  }

  void _stopFasting() {
    setState(() {
      _isFasting = false;
      _fastingStartTime = null;
      _currentFastingTime = Duration.zero;
    });
    
    _timer?.cancel();
    _progressController.reset();
    
    // Update Supabase fasting session as completed/aborted
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_fastingStartTime != null) {
        setState(() {
          _currentFastingTime = DateTime.now().difference(_fastingStartTime!);
        });
        
        // Update progress animation
        final progress = _currentFastingTime.inSeconds / _fastingDuration.inSeconds;
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
    // Show completion celebration
    // Update database with completed status
  }

  void _saveFastingSession() {
    // Save to Supabase fasting_sessions table
    // {
    //   'user_id': userId,
    //   'fasting_type': _fastingTypes[_selectedFastingType]['name'],
    //   'start_time': _fastingStartTime,
    //   'target_duration': _fastingDuration.inMinutes,
    //   'status': 'active'
    // }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 220,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Intervallfasten',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_isFasting)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'AKTIV',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_isFasting) ...[
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
                            color: _fastingTypes[_selectedFastingType]['color'],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _fastingTypes[_selectedFastingType]['emoji'],
                                  style: const TextStyle(fontSize: 20),
                                ),
                                Text(
                                  '${(_progressController.value * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fastingTypes[_selectedFastingType]['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Läuft seit ${_formatDuration(_currentFastingTime)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Ziel: ${_formatDuration(_fastingDuration)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _stopFasting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text(
                  'Fasten beenden',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ] else ...[
              // Fasting type selector
              SizedBox(
                height: 80,
                child: PageView.builder(
                  itemCount: _fastingTypes.length,
                  onPageChanged: (index) {
                    setState(() => _selectedFastingType = index);
                  },
                  itemBuilder: (context, index) {
                    final type = _fastingTypes[index];
                    final isSelected = index == _selectedFastingType;
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected 
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                          color: isSelected 
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            type['emoji'],
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  type['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  type['description'],
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _startFasting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _fastingTypes[_selectedFastingType]['color'],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: Text(
                  '${_fastingTypes[_selectedFastingType]['name']} starten',
                  style: const TextStyle(fontWeight: FontWeight.w600),
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

  FastingProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..strokeWidth = 4
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
    return oldDelegate.progress != progress;
  }
}