import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

class OnboardingActivityScreen extends StatefulWidget {
  const OnboardingActivityScreen({super.key});

  @override
  State<OnboardingActivityScreen> createState() =>
      _OnboardingActivityScreenState();
}

class _OnboardingActivityScreenState extends State<OnboardingActivityScreen> {
  String? _selectedActivity;
  String? _error;

  void _handleNext() {
    if (_selectedActivity == null) {
      setState(() => _error = 'Bitte wähle dein Aktivitätslevel aus.');
      return;
    }
    Provider.of<ProfileProvider>(context, listen: false)
        .updateField('activityLevel', _selectedActivity);
    Navigator.of(context).pushNamed('/onboarding/goal');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Wie aktiv bist du?',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Column(
              children: [
                _buildActivityButton('low', 'Wenig aktiv'),
                const SizedBox(height: 16),
                _buildActivityButton('medium', 'Mittel aktiv'),
                const SizedBox(height: 16),
                _buildActivityButton('high', 'Sehr aktiv'),
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

  Widget _buildActivityButton(String key, String label) {
    final isSelected = _selectedActivity == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedActivity = key),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 18,
                color: isSelected ? Colors.blue[800] : Colors.black)),
      ),
    );
  }
}
