import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
import 'onboarding_summary_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Controller und State (UNVERÄNDERT)
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  String? _selectedGender;
  String? _selectedGoal;
  String? _selectedActivityLevel;
  String? _selectedDietType;
  bool _isGlutenfree = false;

  // Daten (UNVERÄNDERT)
  final List<Map<String, String>> _genders = [
    {'key': 'male', 'title': 'Männlich'},
    {'key': 'female', 'title': 'Weiblich'},
    {'key': 'other', 'title': 'Divers'},
  ];
  final List<Map<String, String>> _goals = [
    {'key': 'weight_loss', 'title': 'Gewicht verlieren'},
    {'key': 'maintain_weight', 'title': 'Gewicht halten'},
    {'key': 'weight_gain', 'title': 'Gewicht zunehmen'},
    {'key': 'muscle_gain', 'title': 'Muskeln aufbauen'},
  ];
  final List<Map<String, String>> _activityLevels = [
    {'key': 'sedentary', 'title': 'Wenig aktiv (Bürojob)'},
    {'key': 'lightly_active', 'title': 'Leicht aktiv (1-3x Sport/Woche)'},
    {'key': 'moderately_active', 'title': 'Mäßig aktiv (3-5x Sport/Woche)'},
    {'key': 'very_active', 'title': 'Sehr aktiv (6-7x Sport/Woche)'},
    {'key': 'extremely_active', 'title': 'Extrem aktiv (tägliches Training)'},
  ];
  final List<Map<String, String>> _dietTypes = [
    {'key': 'standard', 'title': 'Ausgewogen (Alles)'},
    {'key': 'vegan', 'title': 'Vegan'},
    {'key': 'vegetarian', 'title': 'Vegetarisch'},
    {'key': 'keto', 'title': 'Keto'},
    {'key': 'other', 'title': 'Andere'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _handleNext() {
    FocusScope.of(context).unfocus(); // Tastatur einklappen
    if (_currentStep < 7) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    final profileNotifier = ref.read(profileProvider.notifier);
    final currentProfile = ref.read(profileProvider).profile;

    final finalProfile = Profile(
      id: currentProfile?.id ?? '', // Use existing ID if available
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      age: int.tryParse(_ageController.text),
      gender: _selectedGender,
      heightCm: double.tryParse(_heightController.text),
      weightKg: double.tryParse(_weightController.text),
      targetWeightKg: double.tryParse(_targetWeightController.text),
      goal: _selectedGoal,
      activityLevel: _selectedActivityLevel,
      dietType: _selectedDietType,
      isGlutenfree: _isGlutenfree,
      onboardingCompleted: false, // Will be set to true on the summary screen
    );

    // Use the new method to update the state without saving to DB
    profileNotifier.setOnboardingProfile(finalProfile);

    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (context) => const OnboardingSummaryScreen()),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _firstNameController.text.isNotEmpty &&
            _lastNameController.text.isNotEmpty;
      case 1:
        return _ageController.text.isNotEmpty &&
            (int.tryParse(_ageController.text) ?? 0) >= 13;
      case 2:
        return _selectedGender != null;
      case 3:
        return _heightController.text.isNotEmpty &&
            (double.tryParse(_heightController.text) ?? 0) >= 100;
      case 4:
        return _weightController.text.isNotEmpty &&
            (double.tryParse(_weightController.text) ?? 0) >= 30;
      case 5:
        return _targetWeightController.text.isNotEmpty &&
            (double.tryParse(_targetWeightController.text) ?? 0) >= 30;
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
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildNamePage(),
                  _buildAgePage(),
                  _buildGenderPage(),
                  _buildHeightPage(),
                  _buildWeightPage(),
                  _buildTargetWeightPage(),
                  _buildGoalAndActivityPage(),
                  _buildDietPage(),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton(
                    color: AppColors.primary,
                    onPressed: _canProceed() ? _handleNext : null,
                    child: Text(
                      _currentStep == 7 ? 'Los geht\'s!' : 'Weiter',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SEITEN-BUILDER (Struktur unverändert) ---
  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Wie dürfen wir dich nennen?',
            style: AppTypography.largeTitle.copyWith(color: AppColors.label),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Icon(
            CupertinoIcons.person_badge_plus,
            size: 100,
            color: AppColors.label.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 40),
          ModernTextField(
            controller: _firstNameController,
            placeholder: 'Vorname',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          ModernTextField(
            controller: _lastNameController,
            placeholder: 'Nachname',
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildAgePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Wie alt bist du?',
            style: AppTypography.largeTitle.copyWith(color: AppColors.label),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Icon(
            CupertinoIcons.gift_fill,
            size: 100,
            color: AppColors.label.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 40),
          ModernTextField(
            controller: _ageController,
            placeholder: 'z.B. 28',
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Dein Geschlecht',
            style: AppTypography.largeTitle.copyWith(color: AppColors.label),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ..._genders.map(
            (gender) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _buildSelectionCard(
                text: gender['title']!,
                isSelected: _selectedGender == gender['key'],
                onTap: () => setState(() => _selectedGender = gender['key']),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Deine Körpergröße',
            style: AppTypography.largeTitle.copyWith(color: AppColors.label),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Icon(
            CupertinoIcons.arrow_up_down,
            size: 100,
            color: AppColors.label.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 40),
          ModernTextField(
            controller: _heightController,
            placeholder: 'Größe in cm',
            keyboardType: TextInputType.number,
            suffix: 'cm',
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Dein aktuelles Gewicht',
            style: AppTypography.largeTitle.copyWith(color: AppColors.label),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Icon(
            CupertinoIcons.circle,
            size: 100,
            color: AppColors.label.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 40),
          ModernTextField(
            controller: _weightController,
            placeholder: 'Gewicht in kg',
            keyboardType: TextInputType.number,
            suffix: 'kg',
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetWeightPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Dein Zielgewicht',
            style: AppTypography.largeTitle.copyWith(color: AppColors.label),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Icon(
            CupertinoIcons.flag_fill,
            size: 100,
            color: AppColors.label.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 40),
          ModernTextField(
            controller: _targetWeightController,
            placeholder: 'Ziel in kg',
            keyboardType: TextInputType.number,
            suffix: 'kg',
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalAndActivityPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Ziele & Aktivität',
            style: AppTypography.largeTitle.copyWith(color: AppColors.label),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mein Hauptziel',
                    style: AppTypography.headline.copyWith(
                      color: AppColors.label,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._goals.map(
                    (goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSelectionCard(
                        text: goal['title']!,
                        isSelected: _selectedGoal == goal['key'],
                        onTap: () =>
                            setState(() => _selectedGoal = goal['key']),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Mein Aktivitätslevel',
                    style: AppTypography.headline.copyWith(
                      color: AppColors.label,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._activityLevels.map(
                    (level) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSelectionCard(
                        text: level['title']!,
                        isSelected: _selectedActivityLevel == level['key'],
                        onTap: () => setState(
                          () => _selectedActivityLevel = level['key'],
                        ),
                      ),
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

  Widget _buildDietPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Deine Ernährung',
            style: AppTypography.largeTitle.copyWith(color: AppColors.label),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._dietTypes.map(
                    (diet) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSelectionCard(
                        text: diet['title']!,
                        isSelected: _selectedDietType == diet['key'],
                        onTap: () =>
                            setState(() => _selectedDietType = diet['key']),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    text: 'Ich esse glutenfrei',
                    isOn: _isGlutenfree,
                    onChanged: (value) => setState(() => _isGlutenfree = value),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI-HELPER ---
  Widget _buildSelectionCard({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : const Color(0xFFF6F1E7), // Apple White
          borderRadius: AppTheme.borderRadiusM,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.separator,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: AppTypography.body.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.label,
                ),
              ),
            ),
            if (isSelected)
              Icon(CupertinoIcons.check_mark_circled, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required String text,
    required bool isOn,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!isOn),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isOn
              ? AppColors.primary.withValues(alpha: 0.1)
              : const Color(0xFFF6F1E7), // Apple White
          borderRadius: AppTheme.borderRadiusM,
          border: Border.all(
            color: isOn ? AppColors.primary : AppColors.separator,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: AppTypography.body.copyWith(color: AppColors.label),
            ),
            CupertinoSwitch(
              value: isOn,
              onChanged: onChanged,
              activeTrackColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// HINWEIS: Die ModernTextField-Klasse muss außerhalb der _OnboardingFlowScreenState-Klasse stehen.
class ModernTextField extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final TextInputType? keyboardType;
  final String? suffix;
  final ValueChanged<String> onChanged;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.keyboardType,
    this.suffix,
    required this.onChanged,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _isFocused ? AppColors.primary : AppColors.separator,
            width: _isFocused ? 2.0 : 1.0,
          ),
        ),
      ),
      child: CupertinoTextField(
        controller: widget.controller,
        focusNode: _focusNode,
        placeholder: widget.placeholder,
        style: AppTypography.title3.copyWith(color: AppColors.label),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: null,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        suffix: widget.suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Text(
                  widget.suffix!,
                  style: AppTypography.body.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}