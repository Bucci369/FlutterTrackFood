import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../providers/profile_provider.dart';
import '../../models/profile.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // Selected values
  String? _selectedGender;
  String? _selectedGoal;
  String? _selectedActivityLevel;
  String? _selectedDietType;
  bool _isGlutenfree = false;

  final List<String> _genders = ['male', 'female', 'other'];
  final List<String> _goals = ['weight_loss', 'weight_gain', 'maintain_weight', 'muscle_gain'];
  final List<String> _activityLevels = ['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active'];
  final List<String> _dietTypes = ['standard', 'vegan', 'vegetarian', 'keto', 'other'];

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
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 6) {
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
    final profile = Profile(
      id: '', // Will be set by provider
      name: _nameController.text,
      age: int.tryParse(_ageController.text) ?? 25,
      gender: _selectedGender ?? 'other',
      heightCm: double.tryParse(_heightController.text) ?? 170.0,
      weightKg: double.tryParse(_weightController.text) ?? 70.0,
      goal: _selectedGoal ?? 'maintain_weight',
      activityLevel: _selectedActivityLevel ?? 'moderately_active',
      dietType: _selectedDietType,
      isGlutenfree: _isGlutenfree,
      onboardingCompleted: false,
    );

    Provider.of<ProfileProvider>(context, listen: false).setProfile(profile);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OnboardingSummaryScreen()),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0: return _nameController.text.isNotEmpty;
      case 1: return _ageController.text.isNotEmpty && (int.tryParse(_ageController.text) ?? 0) > 0;
      case 2: return _selectedGender != null;
      case 3: return _heightController.text.isNotEmpty && (double.tryParse(_heightController.text) ?? 0) > 0;
      case 4: return _weightController.text.isNotEmpty && (double.tryParse(_weightController.text) ?? 0) > 0;
      case 5: return _selectedGoal != null && _selectedActivityLevel != null;
      case 6: return _selectedDietType != null;
      default: return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Container(
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
                      transform: GradientRotation(_backgroundController.value * 2 * 3.14159),
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
                                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                              )
                            else
                              const SizedBox(width: 48),
                            Text(
                              'Schritt ${_currentPage + 1} von 7',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: (_currentPage + 1) / 7,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 4,
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
                        _buildGoalsPage(),
                        _buildDietPage(),
                      ],
                    ),
                  ),
                  
                  // Bottom button
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _canProceed() ? _nextPage : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF34A0A4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                        ),
                        child: Text(
                          _currentPage == 6 ? 'Fertigstellen' : 'Weiter',
                          style: const TextStyle(
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

  Widget _buildNamePage() {
    return _buildPageContent(
      title: 'Wie heißt du?',
      subtitle: 'Lass uns dich kennenlernen',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Dein Name',
            hint: 'z.B. Max Mustermann',
            icon: Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildAgePage() {
    return _buildPageContent(
      title: 'Wie alt bist du?',
      subtitle: 'Dein Alter hilft uns bei der Berechnung',
      icon: Icons.cake_outlined,
      child: Column(
        children: [
          _buildTextField(
            controller: _ageController,
            label: 'Alter in Jahren',
            hint: 'z.B. 25',
            icon: Icons.calendar_today,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderPage() {
    return _buildPageContent(
      title: 'Geschlecht',
      subtitle: 'Für präzise Kalorienwerte',
      icon: Icons.wc_outlined,
      child: Column(
        children: [
          ..._genders.map((gender) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => setState(() => _selectedGender = gender),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: _selectedGender == gender 
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: _selectedGender == gender 
                      ? Colors.white 
                      : Colors.white.withValues(alpha: 0.3),
                    width: _selectedGender == gender ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getGenderIcon(gender),
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        _getGenderDisplayName(gender),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_selectedGender == gender)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 28,
                      ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHeightPage() {
    return _buildPageContent(
      title: 'Körpergröße',
      subtitle: 'In Zentimetern',
      icon: Icons.height_outlined,
      child: Column(
        children: [
          _buildTextField(
            controller: _heightController,
            label: 'Größe in cm',
            hint: 'z.B. 175',
            icon: Icons.straighten,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightPage() {
    return _buildPageContent(
      title: 'Gewicht',
      subtitle: 'In Kilogramm',
      icon: Icons.fitness_center_outlined,
      child: Column(
        children: [
          _buildTextField(
            controller: _weightController,
            label: 'Gewicht in kg',
            hint: 'z.B. 70',
            icon: Icons.monitor_weight,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    return _buildPageContent(
      title: 'Deine Ziele',
      subtitle: 'Was möchtest du erreichen?',
      icon: Icons.flag_outlined,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Hauptziel:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Goals as compact grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _goals.length,
            itemBuilder: (context, index) {
              final goal = _goals[index];
              final isSelected = _selectedGoal == goal;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedGoal = goal),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isSelected 
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                    border: Border.all(
                      color: isSelected 
                        ? Colors.white 
                        : Colors.white.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getGoalIcon(goal),
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getGoalDisplayName(goal),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 4),
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Aktivitätslevel:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Activity levels as compact list
          ..._activityLevels.map((level) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: _buildSelectionTile(
              title: _getActivityDisplayName(level),
              value: level,
              groupValue: _selectedActivityLevel,
              onChanged: (value) => setState(() => _selectedActivityLevel = value),
              icon: _getActivityIcon(level),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDietPage() {
    return _buildPageContent(
      title: 'Ernährungspräferenzen',
      subtitle: 'Was passt zu deinem Lebensstil?',
      icon: Icons.restaurant_outlined,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ernährungsart:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Diet types grid - more compact
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,  // 3 columns instead of 2
              childAspectRatio: 0.9,  // Slightly taller
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
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                    border: Border.all(
                      color: isSelected 
                        ? Colors.white 
                        : Colors.white.withValues(alpha: 0.3),
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
                          color: Colors.white,
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
                          Icons.check_circle,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ),
              )
              .animate(delay: Duration(milliseconds: 100 * index))
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8));
            },
          ),
          
          const SizedBox(height: 20),
          
          // Glutenfree checkbox - more compact
          GestureDetector(
            onTap: () => setState(() => _isGlutenfree = !_isGlutenfree),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _isGlutenfree 
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
                border: Border.all(
                  color: _isGlutenfree 
                    ? Colors.white 
                    : Colors.white.withValues(alpha: 0.3),
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
                        ? Colors.white 
                        : Colors.transparent,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: _isGlutenfree
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Color(0xFF34A0A4),
                        )
                      : null,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '🌾',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Glutenfrei',
                    style: TextStyle(
                      color: Colors.white,
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
                  child: Icon(
                    icon,
                    size: 40,
                    color: Colors.white,
                  ),
                )
                .animate()
                .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 24),
                
                Text(
                  title,
                  style: const TextStyle(
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
                  subtitle,
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
          )
          .animate()
          .fadeIn(delay: 800.ms, duration: 800.ms)
          .slideY(begin: 0.2, end: 0),
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      textAlign: TextAlign.center,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.8)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
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
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
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
                Icons.check_circle,
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
      case 'male': return 'Männlich';
      case 'female': return 'Weiblich';
      case 'other': return 'Divers';
      default: return gender;
    }
  }

  IconData _getGenderIcon(String gender) {
    switch (gender) {
      case 'male': return Icons.male;
      case 'female': return Icons.female;
      case 'other': return Icons.transgender;
      default: return Icons.person;
    }
  }

  String _getGoalDisplayName(String goal) {
    switch (goal) {
      case 'weight_loss': return 'Gewicht verlieren';
      case 'weight_gain': return 'Gewicht zunehmen';
      case 'maintain_weight': return 'Gewicht halten';
      case 'muscle_gain': return 'Muskeln aufbauen';
      default: return goal;
    }
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'weight_loss': return Icons.trending_down;
      case 'weight_gain': return Icons.trending_up;
      case 'maintain_weight': return Icons.trending_flat;
      case 'muscle_gain': return Icons.fitness_center;
      default: return Icons.flag;
    }
  }

  String _getActivityDisplayName(String level) {
    switch (level) {
      case 'sedentary': return 'Wenig aktiv (Bürojob)';
      case 'lightly_active': return 'Leicht aktiv (1-3x Sport/Woche)';
      case 'moderately_active': return 'Mäßig aktiv (3-5x Sport/Woche)';
      case 'very_active': return 'Sehr aktiv (6-7x Sport/Woche)';
      case 'extremely_active': return 'Extrem aktiv (2x täglich)';
      default: return level;
    }
  }

  IconData _getActivityIcon(String level) {
    switch (level) {
      case 'sedentary': return Icons.chair;
      case 'lightly_active': return Icons.directions_walk;
      case 'moderately_active': return Icons.directions_run;
      case 'very_active': return Icons.fitness_center;
      case 'extremely_active': return Icons.sports_gymnastics;
      default: return Icons.directions_walk;
    }
  }

  String _getDietDisplayName(String diet) {
    switch (diet) {
      case 'standard': return 'Standard';
      case 'vegan': return 'Vegan';
      case 'vegetarian': return 'Vegetarisch';
      case 'keto': return 'Keto';
      case 'other': return 'Andere';
      default: return diet;
    }
  }

  String _getDietEmoji(String diet) {
    switch (diet) {
      case 'standard': return '🥩';
      case 'vegan': return '🥑';
      case 'vegetarian': return '🥦';
      case 'keto': return '🍣';
      case 'other': return '🍽️';
      default: return '🍽️';
    }
  }
}