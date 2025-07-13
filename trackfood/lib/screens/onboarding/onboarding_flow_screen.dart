import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../providers/profile_provider.dart';
import '../../models/profile.dart';
import '../../services/supabase_service.dart';
import 'onboarding_summary_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _animationController;
  late AnimationController _backgroundController;

  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();

  // Selected values
  String? _selectedGender;
  String? _selectedGoal;
  String? _selectedActivityLevel;
  String? _selectedDietType;
  bool _isGlutenfree = false;

  final List<String> _genders = ['male', 'female', 'other'];
  final List<String> _goals = [
    'weight_loss',
    'weight_gain',
    'maintain_weight',
    'muscle_gain',
  ];
  final List<String> _activityLevels = [
    'sedentary',
    'lightly_active',
    'moderately_active',
    'very_active',
    'extremely_active',
  ];
  final List<String> _dietTypes = [
    'standard',
    'vegan',
    'vegetarian',
    'keto',
    'other',
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
    _pageController.dispose();
    _animationController.dispose();
    _backgroundController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 7) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _completeOnboarding() {
    final userId = SupabaseService().currentUserId ?? '';

    final profile = Profile(
      id: userId,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      age: int.tryParse(_ageController.text) ?? 25,
      gender: _selectedGender ?? 'other',
      heightCm: double.tryParse(_heightController.text) ?? 170.0,
      weightKg: double.tryParse(_weightController.text) ?? 70.0,
      targetWeightKg: double.tryParse(_targetWeightController.text),
      goal: _selectedGoal ?? 'maintain_weight',
      activityLevel: _selectedActivityLevel ?? 'moderately_active',
      dietType: _selectedDietType,
      isGlutenfree: _isGlutenfree,
      onboardingCompleted: false,
    );

    Provider.of<ProfileProvider>(context, listen: false).setProfile(profile);

    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (context) => const OnboardingSummaryScreen()),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _firstNameController.text.isNotEmpty &&
            _lastNameController.text.isNotEmpty;
      case 1:
        return _ageController.text.isNotEmpty &&
            (int.tryParse(_ageController.text) ?? 0) > 0;
      case 2:
        return _selectedGender != null;
      case 3:
        return _heightController.text.isNotEmpty &&
            (double.tryParse(_heightController.text) ?? 0) > 0;
      case 4:
        return _weightController.text.isNotEmpty &&
            (double.tryParse(_weightController.text) ?? 0) > 0;
      case 5:
        return _targetWeightController.text.isNotEmpty &&
            (double.tryParse(_targetWeightController.text) ?? 0) > 0;
      case 6:
        return _selectedGoal != null && _selectedActivityLevel != null;
      case 7:
        return _selectedDietType != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/background2.png'),
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
                        _backgroundController.value * 2 * 3.14159,
                      ),
                    ),
                  ),
                );
              },
            ),

            SafeArea(
              child: Column(
                children: [
                  // Progress indicator
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentPage > 0)
                              IconButton(
                                onPressed: _previousPage,
                                icon: const Icon(
                                  CupertinoIcons.back,
                                  color: Colors.white,
                                ),
                              )
                            else
                              const SizedBox(width: 48),
                            Text(
                              'Schritt ${_currentPage + 1} von 8',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                CupertinoIcons.xmark,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (_currentPage + 1) / 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Page content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                        _animationController.reset();
                        _animationController.forward();
                      },
                      children: [
                        _buildNamePage(),
                        _buildAgePage(),
                        _buildGenderPage(),
                        _buildHeightPage(),
                        _buildWeightPage(),
                        _buildTargetWeightPage(),
                        _buildGoalsPage(),
                        _buildDietPage(),
                      ],
                    ),
                  ),

                  // Bottom button
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: CupertinoButton.filled(
                        onPressed: _canProceed() ? _nextPage : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Text(
                          _currentPage == 7 ? 'Fertigstellen' : 'Weiter',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: CupertinoColors.white,
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

  Widget _buildNamePage() {
    return _buildPageContent(
      title: 'Wie heißt du?',
      subtitle: 'Bitte gib Vor- und Nachname ein',
      icon: CupertinoIcons.person,
      child: Column(
        children: [
          _buildTextField(
            controller: _firstNameController,
            label: 'Vorname',
            hint: 'z.B. Max',
            icon: CupertinoIcons.person,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _lastNameController,
            label: 'Nachname',
            hint: 'z.B. Mustermann',
            icon: CupertinoIcons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildAgePage() {
    return _buildPageContent(
      title: 'Wie alt bist du?',
      subtitle: 'Dein Alter hilft uns bei der Berechnung',
      icon: CupertinoIcons.gift,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alter in Jahren',
            style: const TextStyle(
              color: CupertinoColors.label,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            placeholder: 'z.B. 25',
            prefix: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Icon(
                CupertinoIcons.calendar,
                color: CupertinoColors.systemGrey,
                size: 22,
              ),
            ),
            style: const TextStyle(color: CupertinoColors.label, fontSize: 18),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CupertinoColors.systemGrey3),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderPage() {
    return _buildPageContent(
      title: 'Geschlecht',
      subtitle: 'Für präzise Kalorienwerte',
      icon: CupertinoIcons.person_2,
      child: Column(
        children: [
          ..._genders.map(
            (gender) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = gender),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: _selectedGender == gender
                        ? CupertinoColors.systemGrey5
                        : CupertinoColors.systemGrey6,
                    border: Border.all(
                      color: _selectedGender == gender
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.systemGrey3,
                      width: _selectedGender == gender ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getGenderIcon(gender),
                        color: CupertinoColors.label,
                        size: 28,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          _getGenderDisplayName(gender),
                          style: const TextStyle(
                            color: CupertinoColors.label,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_selectedGender == gender)
                        const Icon(
                          CupertinoIcons.check_mark_circled_solid,
                          color: CupertinoColors.activeBlue,
                          size: 28,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightPage() {
    return _buildPageContent(
      title: 'Körpergröße',
      subtitle: 'In Zentimetern',
      icon: CupertinoIcons.textformat_size,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Größe in cm',
            style: const TextStyle(
              color: CupertinoColors.label,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            placeholder: 'z.B. 175',
            prefix: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Icon(
                CupertinoIcons.textformat_size,
                color: CupertinoColors.systemGrey,
                size: 22,
              ),
            ),
            style: const TextStyle(color: CupertinoColors.label, fontSize: 18),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CupertinoColors.systemGrey3),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightPage() {
    return _buildPageContent(
      title: 'Aktuelles Gewicht',
      subtitle: 'In Kilogramm',
      icon: CupertinoIcons.sportscourt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aktuelles Gewicht in kg',
            style: const TextStyle(
              color: CupertinoColors.label,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            placeholder: 'z.B. 70',
            prefix: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Icon(
                CupertinoIcons.gauge,
                color: CupertinoColors.systemGrey,
                size: 22,
              ),
            ),
            style: const TextStyle(color: CupertinoColors.label, fontSize: 18),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CupertinoColors.systemGrey3),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetWeightPage() {
    return _buildPageContent(
      title: 'Zielgewicht',
      subtitle: 'Was möchtest du erreichen?',
      icon: CupertinoIcons.flag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zielgewicht in kg',
            style: const TextStyle(
              color: CupertinoColors.label,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _targetWeightController,
            keyboardType: TextInputType.number,
            placeholder: 'z.B. 65',
            prefix: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Icon(
                CupertinoIcons.scope,
                color: CupertinoColors.systemGrey,
                size: 22,
              ),
            ),
            style: const TextStyle(color: CupertinoColors.label, fontSize: 18),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CupertinoColors.systemGrey3),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: CupertinoColors.systemGrey6,
              border: Border.all(color: CupertinoColors.systemGrey3),
            ),
            child: Column(
              children: [
                const Icon(
                  CupertinoIcons.info_circle,
                  color: CupertinoColors.label,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tipp: Ein gesundes Zielgewicht liegt in der Regel 0,5-1 kg pro Woche vom aktuellen Gewicht entfernt.',
                  style: TextStyle(
                    color: CupertinoColors.label,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    return _buildPageContent(
      title: 'Was sind deine Ziele?',
      subtitle: 'Wähle dein Hauptziel aus',
      icon: CupertinoIcons.star,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...[
            _buildGoalCard(
              'weight_loss',
              'Gewichtsverlust',
              '🏃‍♂️',
              CupertinoColors.activeBlue,
            ),
            const SizedBox(height: 16),
            _buildGoalCard(
              'maintain_weight',
              'Verbesserte\nGesundheit',
              '❤️',
              CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            _buildGoalCard(
              'weight_gain',
              'Mehr Energie',
              '⚡',
              CupertinoColors.activeOrange,
            ),
            const SizedBox(height: 16),
            _buildGoalCard(
              'muscle_gain',
              'Mentales Wohlbefinden',
              '🧘‍♀️',
              CupertinoColors.systemPink,
            ),
            const SizedBox(height: 16),
            _buildGoalCard(
              'maintain_weight',
              'Bessere Verdauung',
              '🍎',
              CupertinoColors.systemPurple,
            ),
            const SizedBox(height: 16),
            _buildGoalCard(
              'weight_loss',
              'Immunsystem stärken',
              '🛡️',
              CupertinoColors.systemTeal,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalCard(String goal, String title, String emoji, Color color) {
    final isSelected = _selectedGoal == goal;

    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goal),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: const Color(0xFF00C853), width: 2)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                  letterSpacing: -0.41,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C853),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.checkmark,
                  color: CupertinoColors.white,
                  size: 16,
                ),
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.systemGrey3,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietPage() {
    return _buildPageContent(
      title: 'Ernährungspräferenzen',
      subtitle: 'Was passt zu deinem Lebensstil?',
      icon: CupertinoIcons.heart_fill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ernährungsart:',
            style: TextStyle(
              color: CupertinoColors.label,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _dietTypes.length,
            itemBuilder: (context, index) {
              final dietType = _dietTypes[index];
              final isSelected = _selectedDietType == dietType;

              return GestureDetector(
                onTap: () => setState(() => _selectedDietType = dietType),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? CupertinoColors.systemGrey5
                        : CupertinoColors.systemGrey6,
                    border: Border.all(
                      color: isSelected
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.systemGrey3,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getDietEmoji(dietType),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDietDisplayName(dietType),
                        style: const TextStyle(
                          color: CupertinoColors.label,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 2),
                        Icon(
                          CupertinoIcons.check_mark_circled_solid,
                          color: CupertinoColors.activeBlue,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: () => setState(() => _isGlutenfree = !_isGlutenfree),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _isGlutenfree
                    ? CupertinoColors.systemGrey5
                    : CupertinoColors.systemGrey6,
                border: Border.all(
                  color: _isGlutenfree
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.systemGrey3,
                  width: _isGlutenfree ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _isGlutenfree
                          ? CupertinoColors.activeBlue
                          : Colors.transparent,
                      border: Border.all(
                        color: CupertinoColors.activeBlue,
                        width: 2,
                      ),
                    ),
                    child: _isGlutenfree
                        ? const Icon(
                            CupertinoIcons.check_mark,
                            size: 14,
                            color: CupertinoColors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Text('🌾', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  const Text(
                    'Glutenfrei',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Header
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
                  child: Icon(icon, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: GlassmorphicContainer(
              width: double.infinity,
              height: double.infinity,
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.label,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          keyboardType: keyboardType,
          placeholder: hint,
          prefix: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Icon(icon, color: CupertinoColors.systemGrey, size: 22),
          ),
          style: const TextStyle(color: CupertinoColors.label, fontSize: 18),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CupertinoColors.systemGrey3),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildSelectionTile<T>({
    required String title,
    required T value,
    required T? groupValue,
    required void Function(T?) onChanged,
    required IconData icon,
  }) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              const Icon(
                CupertinoIcons.check_mark_circled_solid,
                color: Colors.white,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  String _getGenderDisplayName(String gender) {
    switch (gender) {
      case 'male':
        return 'Männlich';
      case 'female':
        return 'Weiblich';
      case 'other':
        return 'Divers';
      default:
        return gender;
    }
  }

  IconData _getGenderIcon(String gender) {
    switch (gender) {
      case 'male':
        return CupertinoIcons.person;
      case 'female':
        return CupertinoIcons.person;
      case 'other':
        return CupertinoIcons.person_2;
      default:
        return CupertinoIcons.person;
    }
  }

  String _getGoalDisplayName(String goal) {
    switch (goal) {
      case 'weight_loss':
        return 'Gewicht verlieren';
      case 'weight_gain':
        return 'Gewicht zunehmen';
      case 'maintain_weight':
        return 'Gewicht halten';
      case 'muscle_gain':
        return 'Muskeln aufbauen';
      default:
        return goal;
    }
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'weight_loss':
        return CupertinoIcons.arrow_down;
      case 'weight_gain':
        return CupertinoIcons.arrow_up;
      case 'maintain_weight':
        return CupertinoIcons.minus;
      case 'muscle_gain':
        return CupertinoIcons.sportscourt;
      default:
        return CupertinoIcons.flag;
    }
  }

  String _getActivityDisplayName(String level) {
    switch (level) {
      case 'sedentary':
        return 'Wenig aktiv (Bürojob)';
      case 'lightly_active':
        return 'Leicht aktiv (1-3x Sport/Woche)';
      case 'moderately_active':
        return 'Mäßig aktiv (3-5x Sport/Woche)';
      case 'very_active':
        return 'Sehr aktiv (6-7x Sport/Woche)';
      case 'extremely_active':
        return 'Extrem aktiv (2x täglich)';
      default:
        return level;
    }
  }

  IconData _getActivityIcon(String level) {
    switch (level) {
      case 'sedentary':
        return CupertinoIcons.house;
      case 'lightly_active':
        return CupertinoIcons.person_crop_circle;
      case 'moderately_active':
        return CupertinoIcons.play;
      case 'very_active':
        return CupertinoIcons.sportscourt;
      case 'extremely_active':
        return CupertinoIcons.sportscourt;
      default:
        return CupertinoIcons.person_crop_circle;
    }
  }

  String _getDietDisplayName(String diet) {
    switch (diet) {
      case 'standard':
        return 'Standard';
      case 'vegan':
        return 'Vegan';
      case 'vegetarian':
        return 'Vegetarisch';
      case 'keto':
        return 'Keto';
      case 'other':
        return 'Andere';
      default:
        return diet;
    }
  }

  String _getDietEmoji(String diet) {
    switch (diet) {
      case 'standard':
        return '🥩';
      case 'vegan':
        return '🥑';
      case 'vegetarian':
        return '🥦';
      case 'keto':
        return '🍣';
      case 'other':
        return '🍽️';
      default:
        return '🍽️';
    }
  }
}
