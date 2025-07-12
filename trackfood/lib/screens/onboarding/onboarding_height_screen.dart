import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

class OnboardingHeightScreen extends StatefulWidget {
  const OnboardingHeightScreen({super.key});

  @override
  State<OnboardingHeightScreen> createState() => _OnboardingHeightScreenState();
}

class _OnboardingHeightScreenState extends State<OnboardingHeightScreen> {
  final TextEditingController _heightController = TextEditingController();
  String? _error;

  void _handleNext() {
    final height = double.tryParse(_heightController.text);
    if (height == null || height < 100 || height > 250) {
      setState(
          () => _error = 'Bitte gib eine Größe zwischen 100 und 250 cm an.');
      return;
    }
    Provider.of<ProfileProvider>(context, listen: false)
        .updateField('heightCm', height);
    Navigator.of(context).pushNamed('/onboarding/weight');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Wie groß bist du?',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Größe in cm',
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
