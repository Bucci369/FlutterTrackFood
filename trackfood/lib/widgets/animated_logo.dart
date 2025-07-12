import 'package:flutter/material.dart';

class CustomAnimatedLogo extends StatefulWidget {
  const CustomAnimatedLogo({super.key});

  @override
  State<CustomAnimatedLogo> createState() => _CustomAnimatedLogoState();
}

class _CustomAnimatedLogoState extends State<CustomAnimatedLogo>
    with TickerProviderStateMixin {
  // AnimationController entfernt

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
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
              ),
              const SizedBox(height: 40),
              const Text(
                'TrackFood',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Intelligente Ernährung',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 60),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Keine Floating-Objekte mehr
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
      final y = ((i * 23) % screenSize.height + animationValue * 100) %
          screenSize.height;
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
