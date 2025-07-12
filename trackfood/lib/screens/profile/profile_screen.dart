import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/profile.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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
        firstName: _firstNameController.text.trim().isEmpty ? null : _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
        age: _ageController.text.trim().isEmpty ? null : int.tryParse(_ageController.text),
        gender: _selectedGender,
      );

      await profileProvider.updatePhysicalStats(
        heightCm: _heightController.text.trim().isEmpty ? null : double.tryParse(_heightController.text),
        weightKg: _weightController.text.trim().isEmpty ? null : double.tryParse(_weightController.text),
        targetWeightKg: _targetWeightController.text.trim().isEmpty ? null : double.tryParse(_targetWeightController.text),
      );

      await profileProvider.updateGoalsAndPreferences(
        goal: _selectedGoal,
        activityLevel: _selectedActivityLevel,
        dietType: _selectedDietType,
        isGlutenfree: _isGlutenfree,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil erfolgreich aktualisiert'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Speichern: $e'),
            backgroundColor: Colors.red,
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Mein Profil'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Speichern',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'Geschlecht',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'male', child: Text('Männlich')),
                              DropdownMenuItem(value: 'female', child: Text('Weiblich')),
                              DropdownMenuItem(value: 'other', child: Text('Divers')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
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
                              if (height == null || height < 100 || height > 250) {
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
                              if (weight == null || weight < 30 || weight > 300) {
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
                    DropdownButtonFormField<String>(
                      value: _selectedGoal,
                      decoration: const InputDecoration(
                        labelText: 'Hauptziel',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'lose_weight', child: Text('Abnehmen')),
                        DropdownMenuItem(value: 'maintain_weight', child: Text('Gewicht halten')),
                        DropdownMenuItem(value: 'gain_weight', child: Text('Zunehmen')),
                        DropdownMenuItem(value: 'build_muscle', child: Text('Muskeln aufbauen')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedGoal = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedActivityLevel,
                      decoration: const InputDecoration(
                        labelText: 'Aktivitätslevel',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'sedentary', child: Text('Wenig aktiv')),
                        DropdownMenuItem(value: 'light', child: Text('Leicht aktiv')),
                        DropdownMenuItem(value: 'moderate', child: Text('Mäßig aktiv')),
                        DropdownMenuItem(value: 'active', child: Text('Sehr aktiv')),
                        DropdownMenuItem(value: 'very_active', child: Text('Extrem aktiv')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedActivityLevel = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildSection(
                  title: 'Ernährungspräferenzen',
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedDietType,
                      decoration: const InputDecoration(
                        labelText: 'Ernährungsform',
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Keine Einschränkungen')),
                        DropdownMenuItem(value: 'vegetarian', child: Text('Vegetarisch')),
                        DropdownMenuItem(value: 'vegan', child: Text('Vegan')),
                        DropdownMenuItem(value: 'keto', child: Text('Ketogen')),
                        DropdownMenuItem(value: 'paleo', child: Text('Paleo')),
                        DropdownMenuItem(value: 'mediterranean', child: Text('Mediterran')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedDietType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Glutenfrei'),
                      value: _isGlutenfree,
                      onChanged: (value) {
                        setState(() {
                          _isGlutenfree = value ?? false;
                        });
                      },
                      activeColor: Colors.green,
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

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              color: Colors.black87,
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
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gesundheitsdaten',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
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
                  profile.isOnboardingComplete ? 'Vollständig' : 'Unvollständig',
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
      ],
    );
  }
}