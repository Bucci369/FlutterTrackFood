import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to access provider safely in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
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
    final profile = ref.read(profileProvider).profile;

    if (profile != null) {
      _firstNameController.text = profile.firstName ?? '';
      _lastNameController.text = profile.lastName ?? '';
      _ageController.text = profile.age?.toString() ?? '';
      _heightController.text = profile.heightCm?.toString() ?? '';
      _weightController.text = profile.weightKg?.toString() ?? '';
      _targetWeightController.text = profile.targetWeightKg?.toString() ?? '';
      setState(() {
        _selectedGender = profile.gender;
        _selectedActivityLevel = profile.activityLevel;
        _selectedGoal = profile.goal;
        _selectedDietType = profile.dietType;
        _isGlutenfree = profile.isGlutenfree ?? false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileNotifier = ref.read(profileProvider.notifier);

    try {
      // Create a new Profile object with all the updated data
      final currentProfile = ref.read(profileProvider).profile;
      if (currentProfile == null) return;

      final updatedProfile = currentProfile.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        gender: _selectedGender,
        heightCm: double.tryParse(_heightController.text.trim()),
        weightKg: double.tryParse(_weightController.text.trim()),
        targetWeightKg: double.tryParse(_targetWeightController.text.trim()),
        activityLevel: _selectedActivityLevel,
        goal: _selectedGoal,
        dietType: _selectedDietType,
        isGlutenfree: _isGlutenfree,
      );

      await profileNotifier.updateProfile(updatedProfile);

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF6F1E7), // Apple White
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Mein Profil'),
        backgroundColor: const Color(0xFFF6F1E7), // Apple White
        border: null,
        trailing: profileState.isLoading
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
      child: profileState.profile == null
          ? const Center(child: CupertinoActivityIndicator())
          : Form(
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
                      CustomTextField(
                        controller: _ageController,
                        label: 'Alter',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Geschlecht',
                        value: _selectedGender,
                        items: ['Männlich', 'Weiblich', 'Andere'],
                        onChanged: (newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Körperliche Daten',
                    children: [
                      CustomTextField(
                        controller: _heightController,
                        label: 'Größe (cm)',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _weightController,
                        label: 'Gewicht (kg)',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _targetWeightController,
                        label: 'Zielgewicht (kg)',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Ziele & Präferenzen',
                    children: [
                      _buildDropdown(
                        label: 'Hauptziel',
                        value: _selectedGoal,
                        items: [
                          'weight_loss',
                          'weight_gain',
                          'maintain_weight',
                          'muscle_gain',
                        ],
                        itemLabels: {
                          'weight_loss': 'Abnehmen',
                          'weight_gain': 'Zunehmen',
                          'maintain_weight': 'Gewicht halten',
                          'muscle_gain': 'Muskelaufbau',
                        },
                        onChanged: (newValue) {
                          setState(() {
                            _selectedGoal = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Aktivitätslevel',
                        value: _selectedActivityLevel,
                        items: [
                          'sedentary',
                          'lightly_active',
                          'moderately_active',
                          'very_active',
                          'extra_active',
                        ],
                        itemLabels: {
                          'sedentary': 'Sitzend',
                          'lightly_active': 'Leicht aktiv',
                          'moderately_active': 'Mäßig aktiv',
                          'very_active': 'Sehr aktiv',
                          'extra_active': 'Extrem aktiv',
                        },
                        onChanged: (newValue) {
                          setState(() {
                            _selectedActivityLevel = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Ernährungsform',
                        value: _selectedDietType,
                        items: [
                          'balanced',
                          'low_carb',
                          'low_fat',
                          'high_protein',
                          'vegan',
                          'vegetarian',
                        ],
                        itemLabels: {
                          'balanced': 'Ausgewogen',
                          'low_carb': 'Low Carb',
                          'low_fat': 'Low Fat',
                          'high_protein': 'High Protein',
                          'vegan': 'Vegan',
                          'vegetarian': 'Vegetarisch',
                        },
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDietType = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Glutenfrei'),
                          CupertinoSwitch(
                            value: _isGlutenfree,
                            onChanged: (value) {
                              setState(() {
                                _isGlutenfree = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CupertinoColors.separator, width: 1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    Map<String, String>? itemLabels,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        CupertinoButton(
          child: Text(
            (value != null ? (itemLabels?[value] ?? value) : 'Auswählen'),
            style: const TextStyle(color: Color(0xFF34A0A4)),
          ),
          onPressed: () {
            showCupertinoModalPopup(
              context: context,
              builder: (context) => Container(
                height: 200,
                color: CupertinoColors.systemGroupedBackground,
                child: CupertinoPicker(
                  itemExtent: 32,
                  onSelectedItemChanged: (index) {
                    onChanged(items[index]);
                  },
                  children: items
                      .map(
                        (item) =>
                            Center(child: Text(itemLabels?[item] ?? item)),
                      )
                      .toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
