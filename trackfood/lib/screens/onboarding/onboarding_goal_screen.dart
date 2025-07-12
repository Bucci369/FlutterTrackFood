import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../providers/profile_provider.dart';

class OnboardingGoalScreen extends StatefulWidget {
  const OnboardingGoalScreen({super.key});

  @override
  State<OnboardingGoalScreen> createState() => _OnboardingGoalScreenState();
}

class _OnboardingGoalScreenState extends State<OnboardingGoalScreen>
    with TickerProviderStateMixin {
  String? _selectedGoal;
  String? _error;

  late AnimationController _animationController;
  late AnimationController _backgroundController;

  final List<GoalOption> _goals = [
    GoalOption('weight_loss', 'Gewichtsverlust', Icons.trending_down,
        'Erreiche dein Wunschgewicht'),
    GoalOption(
        'weight_gain', 'Gewichtszunahme', Icons.trending_up, 'Gesund zunehmen'),
    GoalOption('maintain_weight', 'Gewicht halten', Icons.trending_flat,
        'Aktuelles Gewicht beibehalten'),
    GoalOption('muscle_gain', 'Muskelaufbau', Icons.fitness_center,
        'Muskeln aufbauen'),
    GoalOption('improved_health', 'Gesundheit verbessern', Icons.favorite,
        'Allgemeine Gesundheit'),
    GoalOption(
        'more_energy', 'Mehr Energie', Icons.bolt, 'Mehr Vitalität im Alltag'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _animationController.forward();
    _backgroundController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_selectedGoal == null) {
      setState(() => _error = 'Bitte wähle dein Ziel aus.');
      HapticFeedback.heavyImpact();
      return;
    }

    Provider.of<ProfileProvider>(context, listen: false)
        .updateField('goal', _selectedGoal);
    Navigator.of(context).pushNamed('/onboarding/summary');
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/background3.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Animated gradient overlay
            AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF99D98C).withValues(alpha: 0.6),
                        Color(0xFF76C893).withValues(alpha: 0.5),
                        Color(0xFF52B69A).withValues(alpha: 0.6),
                        Color(0xFF34A0A4).withValues(alpha: 0.7),
                      ],
                      transform: GradientRotation(
                          _backgroundController.value * 2 * 3.14159),
                    ),
                  ),
                );
              },
            ),

            SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.white),
                            ),
                            const Text(
                              'Schritt 6 von 6',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context)
                                  .popUntil((route) => route.isFirst),
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: 1.0, // 100% complete
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ),

                  // Content with scroll
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Title section
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  child: const Icon(
                                    Icons.flag_outlined,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ).animate().scale(
                                    delay: 200.ms,
                                    duration: 600.ms,
                                    curve: Curves.elasticOut),
                                const SizedBox(height: 24),
                                const Text(
                                  'Was ist dein Ziel?',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                    .animate()
                                    .fadeIn(delay: 400.ms, duration: 600.ms)
                                    .slideY(begin: 0.3, end: 0),
                                const SizedBox(height: 8),
                                Text(
                                  'Wähle dein Hauptziel für eine optimale Ernährung',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w300,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                    .animate()
                                    .fadeIn(delay: 600.ms, duration: 600.ms)
                                    .slideY(begin: 0.2, end: 0),
                              ],
                            ),
                          ),

                          // Goals grid in glassmorphic container
                          GlassmorphicContainer(
                            width: double.infinity,
                            height: 420,
                            borderRadius: 24,
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
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  // Goals grid
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.85,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                    itemCount: _goals.length,
                                    itemBuilder: (context, index) {
                                      final goal = _goals[index];
                                      return _buildGoalCard(goal, index);
                                    },
                                  ),

                                  // Error message
                                  if (_error != null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.red.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.red
                                                .withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        _error!,
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 800.ms, duration: 800.ms)
                              .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Bottom button
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedGoal != null ? _handleNext : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF34A0A4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          disabledBackgroundColor:
                              Colors.white.withValues(alpha: 0.5),
                        ),
                        child: const Text(
                          'Fertigstellen',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
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

  Widget _buildGoalCard(GoalOption goal, int index) {
    final isSelected = _selectedGoal == goal.key;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = goal.key;
          _error = null; // Clear error when selection is made
        });
        HapticFeedback.selectionClick();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          border: Border.all(
            color:
                isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: isSelected ? 0.3 : 0.2),
                ),
                child: Icon(
                  goal.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                goal.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                goal.description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected) ...[
                const SizedBox(height: 8),
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }
}

class GoalOption {
  final String key;
  final String title;
  final IconData icon;
  final String description;

  GoalOption(this.key, this.title, this.icon, this.description);
}
