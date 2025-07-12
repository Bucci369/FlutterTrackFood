import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

class OnboardingGenderScreen extends StatefulWidget {
  const OnboardingGenderScreen({super.key});

  @override
  State<OnboardingGenderScreen> createState() => _OnboardingGenderScreenState();
}

class _OnboardingGenderScreenState extends State<OnboardingGenderScreen> {
  String? _selectedGender;
  String? _error;

  void _handleNext() {
    if (_selectedGender == null) {
      setState(() => _error = 'Bitte wähle ein Geschlecht aus.');
      return;
    }
    Provider.of<ProfileProvider>(context, listen: false)
        .updateField('gender', _selectedGender);
    Navigator.of(context).pushNamed('/onboarding/height');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welches Geschlecht hast du?',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGenderButton('male', 'Männlich'),
                const SizedBox(width: 16),
                _buildGenderButton('female', 'Weiblich'),
                const SizedBox(width: 16),
                _buildGenderButton('other', 'Divers'),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _handleNext,
              child: const Text('Weiter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderButton(String genderKey, String label) {
    final isSelected = _selectedGender == genderKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = genderKey),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: isSelected ? Colors.green : Colors.grey[300]!),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 18,
                color: isSelected ? Colors.green[800] : Colors.black)),
      ),
    );
  }
}
