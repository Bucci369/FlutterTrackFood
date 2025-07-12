import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

class OnboardingNameScreen extends StatefulWidget {
  const OnboardingNameScreen({super.key});

  @override
  State<OnboardingNameScreen> createState() => _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends State<OnboardingNameScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _error;

  void _handleNext() {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      setState(() => _error = 'Bitte gib Vor- und Nachname ein.');
      return;
    }
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    provider.updateField('firstName', _firstNameController.text.trim());
    provider.updateField('lastName', _lastNameController.text.trim());
    Navigator.of(context).pushNamed('/onboarding/age');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Wie ist dein Name?',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                hintText: 'Vorname',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                hintText: 'Nachname',
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
