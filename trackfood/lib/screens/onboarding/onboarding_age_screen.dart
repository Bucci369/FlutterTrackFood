import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

class OnboardingAgeScreen extends StatefulWidget {
  const OnboardingAgeScreen({super.key});

  @override
  State<OnboardingAgeScreen> createState() => _OnboardingAgeScreenState();
}

class _OnboardingAgeScreenState extends State<OnboardingAgeScreen> {
  final TextEditingController _ageController = TextEditingController();
  String? _error;

  void _handleNext() {
    final age = int.tryParse(_ageController.text);
    if (age == null || age < 13 || age > 120) {
      setState(() =>
          _error = 'Bitte gib ein gültiges Alter zwischen 13 und 120 an.');
      return;
    }
    Provider.of<ProfileProvider>(context, listen: false)
        .updateField('age', age);
    Navigator.of(context).pushNamed('/onboarding/gender');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Wie alt bist du?',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Alter',
                errorText: _error,
              ),
            ),
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
}
