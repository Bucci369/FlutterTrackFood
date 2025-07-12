import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class CustomAnimatedLogo extends StatefulWidget {
  const CustomAnimatedLogo({super.key});

  @override
  State<CustomAnimatedLogo> createState() => _CustomAnimatedLogoState();
}

class _CustomAnimatedLogoState extends State<CustomAnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _backgroundController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _particleController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF99D98C).withOpacity(0.8),
              const Color(0xFF76C893),
              const Color(0xFF52B69A),
              const Color(0xFF34A0A4),
              const Color(0xFF168AAD),
            ],
            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: ParticlePainter(_particleController.value, size),
                );
              },
            ),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with sophisticated animations
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: Curves.elasticOut.transform(_logoController.value),
                        child: Transform.rotate(
                          angle: (1 - _logoController.value) * 2 * 3.14159,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/image/logo1.webp',
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                              .animate(delay: 300.ms)
                              .shimmer(
                                duration: 1500.ms,
                                color: Colors.white.withOpacity(0.5),
                              ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Animated app name
                  Container(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'TrackFood',
                          textStyle: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                          speed: const Duration(milliseconds: 150),
                        ),
                      ],
                      totalRepeatCount: 1,
                      pause: const Duration(milliseconds: 500),
                    ),
                  )
                      .animate(delay: 800.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 20),
                  
                  // Subtitle with gradient effect
                  Container(
                    child: const Text(
                      'Intelligente Ernährung',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.2,
                      ),
                    ),
                  )
                      .animate(delay: 1200.ms)
                      .fadeIn(duration: 800.ms)
                      .slideY(begin: 0.2, end: 0),
                      
                  const SizedBox(height: 60),
                  
                  // Loading indicator with custom design
                  Container(
                    width: 50,
                    height: 50,
                    child: Stack(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(delay: 1500.ms)
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.5, 0.5)),
                ],
              ),
            ),
            
            // Floating elements
            ..._buildFloatingElements(size),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingElements(Size size) {
    return List.generate(8, (index) {
      final delay = index * 200.0;
      final elementSize = 20.0 + (index % 3) * 15.0;
      
      return Positioned(
        left: (index % 4) * (size.width / 4),
        top: (index ~/ 4) * (size.height / 2) + 100,
        child: Container(
          width: elementSize,
          height: elementSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
        )
            .animate(delay: Duration(milliseconds: delay.toInt()))
            .fadeIn(duration: 1000.ms)
            .scale(begin: const Offset(0, 0))
            .then(delay: 500.ms)
            .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
      );
    });
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;
  final Size screenSize;
  
  ParticlePainter(this.animationValue, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = (i * 37) % screenSize.width;
      final y = ((i * 23) % screenSize.height + animationValue * 100) % screenSize.height;
      final radius = (i % 3) + 1.0;
      
      canvas.drawCircle(
        Offset(x, y),
        radius * animationValue,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}