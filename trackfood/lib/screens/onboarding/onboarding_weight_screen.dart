import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

class OnboardingWeightScreen extends StatefulWidget {
  const OnboardingWeightScreen({super.key});

  @override
  State<OnboardingWeightScreen> createState() => _OnboardingWeightScreenState();
}

class _OnboardingWeightScreenState extends State<OnboardingWeightScreen> {
  final TextEditingController _weightController = TextEditingController();
  String? _error;

  void _handleNext() {
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight < 30 || weight > 300) {
      setState(() => _error =
          'Bitte gib ein realistisches Gewicht zwischen 30 und 300 kg an.');
      return;
    }
    Provider.of<ProfileProvider>(context, listen: false)
        .updateField('weightKg', weight);
    Navigator.of(context).pushNamed('/onboarding/activity');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Wie viel wiegst du?',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Gewicht in kg',
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
