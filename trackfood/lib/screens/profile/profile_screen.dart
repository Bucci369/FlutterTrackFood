import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/profile.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  String? _selectedGender;
  String? _selectedActivityLevel;
  String? _selectedGoal;
  String? _selectedDietType;
  bool _isGlutenfree = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _loadProfileData() {
    final profileProvider = context.read<ProfileProvider>();
    final profile = profileProvider.profile;

    if (profile != null) {
      _firstNameController.text = profile.firstName ?? '';
      _lastNameController.text = profile.lastName ?? '';
      _ageController.text = profile.age?.toString() ?? '';
      _heightController.text = profile.heightCm?.toString() ?? '';
      _weightController.text = profile.weightKg?.toString() ?? '';
      _targetWeightController.text = profile.targetWeightKg?.toString() ?? '';
      _selectedGender = profile.gender;
      _selectedActivityLevel = profile.activityLevel;
      _selectedGoal = profile.goal;
      _selectedDietType = profile.dietType;
      _isGlutenfree = profile.isGlutenfree ?? false;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final profileProvider = context.read<ProfileProvider>();

      await profileProvider.updateBasicInfo(
        firstName: _firstNameController.text.trim().isEmpty
            ? null
            : _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
        age: _ageController.text.trim().isEmpty
            ? null
            : int.tryParse(_ageController.text),
        gender: _selectedGender,
      );

      await profileProvider.updatePhysicalStats(
        heightCm: _heightController.text.trim().isEmpty
            ? null
            : double.tryParse(_heightController.text),
        weightKg: _weightController.text.trim().isEmpty
            ? null
            : double.tryParse(_weightController.text),
        targetWeightKg: _targetWeightController.text.trim().isEmpty
            ? null
            : double.tryParse(_targetWeightController.text),
      );

      await profileProvider.updateGoalsAndPreferences(
        goal: _selectedGoal,
        activityLevel: _selectedActivityLevel,
        dietType: _selectedDietType,
        isGlutenfree: _isGlutenfree,
      );

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Erfolg'),
            content: const Text('Profil erfolgreich aktualisiert'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Fehler'),
            content: Text('Fehler beim Speichern: $e'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Mein Profil'),
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        border: null,
        trailing: _isLoading
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saveProfile,
                child: const Text(
                  'Speichern',
                  style: TextStyle(
                    color: Color(0xFF34A0A4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
      child: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (profileProvider.profile == null) {
            return const Center(
              child: Text('Profil konnte nicht geladen werden'),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection(
                  title: 'Persönliche Informationen',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _firstNameController,
                            label: 'Vorname',
                            validator: (value) {
                              if (value?.trim().isEmpty ?? true) {
                                return 'Bitte Vorname eingeben';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _lastNameController,
                            label: 'Nachname',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _ageController,
                            label: 'Alter',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.trim().isEmpty ?? true) return null;
                              final age = int.tryParse(value!);
                              if (age == null || age < 13 || age > 120) {
                                return 'Alter zwischen 13-120';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Geschlecht',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: CupertinoColors.label,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CupertinoButton(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                color: CupertinoColors.systemGrey6,
                                borderRadius: BorderRadius.circular(8),
                                onPressed: () => _showGenderPicker(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _getGenderDisplayText(_selectedGender),
                                      style: const TextStyle(color: CupertinoColors.label),
                                    ),
                                    const Icon(CupertinoIcons.chevron_down, size: 18),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Körperliche Daten',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _heightController,
                            label: 'Größe (cm)',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.trim().isEmpty ?? true) return null;
                              final height = double.tryParse(value!);
                              if (height == null ||
                                  height < 100 ||
                                  height > 250) {
                                return 'Größe zwischen 100-250cm';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _weightController,
                            label: 'Gewicht (kg)',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.trim().isEmpty ?? true) return null;
                              final weight = double.tryParse(value!);
                              if (weight == null ||
                                  weight < 30 ||
                                  weight > 300) {
                                return 'Gewicht zwischen 30-300kg';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _targetWeightController,
                      label: 'Zielgewicht (kg)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) return null;
                        final weight = double.tryParse(value!);
                        if (weight == null || weight < 30 || weight > 300) {
                          return 'Zielgewicht zwischen 30-300kg';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Ziele & Aktivität',
                  children: [
                    _buildCupertinoSelector(
                      label: 'Hauptziel',
                      value: _getGoalDisplayText(_selectedGoal),
                      onTap: () => _showGoalPicker(),
                    ),
                    const SizedBox(height: 16),
                    _buildCupertinoSelector(
                      label: 'Aktivitätslevel',
                      value: _getActivityDisplayText(_selectedActivityLevel),
                      onTap: () => _showActivityPicker(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Ernährungspräferenzen',
                  children: [
                    _buildCupertinoSelector(
                      label: 'Ernährungsform',
                      value: _getDietDisplayText(_selectedDietType),
                      onTap: () => _showDietPicker(),
                    ),
                    const SizedBox(height: 16),
                    _buildCupertinoSwitch(
                      label: 'Glutenfrei',
                      value: _isGlutenfree,
                      onChanged: (value) {
                        setState(() {
                          _isGlutenfree = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildHealthStatsCard(profileProvider.profile!),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildHealthStatsCard(Profile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF34A0A4).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF34A0A4).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gesundheitsdaten',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'BMI',
                  profile.bmi?.toStringAsFixed(1) ?? '-',
                  profile.bmiCategory,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'BMR',
                  profile.bmr?.toStringAsFixed(0) ?? '-',
                  'kcal/Tag',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'TDEE',
                  profile.tdee?.toStringAsFixed(0) ?? '-',
                  'kcal/Tag',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Status',
                  profile.isOnboardingComplete
                      ? 'Vollständig'
                      : 'Unvollständig',
                  '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.secondaryLabel,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
      ],
    );
  }

  // === CUPERTINO HELPER WIDGETS ===

  Widget _buildCupertinoSelector({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
          onPressed: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(color: CupertinoColors.label),
              ),
              const Icon(CupertinoIcons.chevron_down, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCupertinoSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.label,
          ),
        ),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: const Color(0xFF34A0A4),
        ),
      ],
    );
  }

  // === DISPLAY TEXT METHODS ===

  String _getGenderDisplayText(String? gender) {
    switch (gender) {
      case 'male':
        return 'Männlich';
      case 'female':
        return 'Weiblich';
      case 'other':
        return 'Divers';
      default:
        return 'Auswählen';
    }
  }

  String _getGoalDisplayText(String? goal) {
    switch (goal) {
      case 'lose_weight':
        return 'Abnehmen';
      case 'maintain_weight':
        return 'Gewicht halten';
      case 'gain_weight':
        return 'Zunehmen';
      case 'build_muscle':
        return 'Muskeln aufbauen';
      default:
        return 'Auswählen';
    }
  }

  String _getActivityDisplayText(String? activity) {
    switch (activity) {
      case 'sedentary':
        return 'Wenig aktiv';
      case 'light':
        return 'Leicht aktiv';
      case 'moderate':
        return 'Mäßig aktiv';
      case 'active':
        return 'Sehr aktiv';
      case 'very_active':
        return 'Extrem aktiv';
      default:
        return 'Auswählen';
    }
  }

  String _getDietDisplayText(String? diet) {
    switch (diet) {
      case null:
        return 'Keine Einschränkungen';
      case 'standard':
        return 'Standard';
      case 'vegetarian':
        return 'Vegetarisch';
      case 'vegan':
        return 'Vegan';
      case 'keto':
        return 'Ketogen';
      case 'paleo':
        return 'Paleo';
      case 'mediterranean':
        return 'Mediterran';
      default:
        return 'Auswählen';
    }
  }

  // === PICKER METHODS ===

  void _showGenderPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fertig'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  final genders = ['male', 'female', 'other'];
                  setState(() {
                    _selectedGender = genders[index];
                  });
                },
                children: const [
                  Center(child: Text('Männlich')),
                  Center(child: Text('Weiblich')),
                  Center(child: Text('Divers')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fertig'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  final goals = ['lose_weight', 'maintain_weight', 'gain_weight', 'build_muscle'];
                  setState(() {
                    _selectedGoal = goals[index];
                  });
                },
                children: const [
                  Center(child: Text('Abnehmen')),
                  Center(child: Text('Gewicht halten')),
                  Center(child: Text('Zunehmen')),
                  Center(child: Text('Muskeln aufbauen')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fertig'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  final activities = ['sedentary', 'light', 'moderate', 'active', 'very_active'];
                  setState(() {
                    _selectedActivityLevel = activities[index];
                  });
                },
                children: const [
                  Center(child: Text('Wenig aktiv')),
                  Center(child: Text('Leicht aktiv')),
                  Center(child: Text('Mäßig aktiv')),
                  Center(child: Text('Sehr aktiv')),
                  Center(child: Text('Extrem aktiv')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDietPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fertig'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  final diets = [null, 'standard', 'vegetarian', 'vegan', 'keto', 'paleo', 'mediterranean'];
                  setState(() {
                    _selectedDietType = diets[index];
                  });
                },
                children: const [
                  Center(child: Text('Keine Einschränkungen')),
                  Center(child: Text('Standard')),
                  Center(child: Text('Vegetarisch')),
                  Center(child: Text('Vegan')),
                  Center(child: Text('Ketogen')),
                  Center(child: Text('Paleo')),
                  Center(child: Text('Mediterran')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
