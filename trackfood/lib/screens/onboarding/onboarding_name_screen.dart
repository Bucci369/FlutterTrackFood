import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

class OnboardingNameScreen extends StatefulWidget {
  const OnboardingNameScreen({super.key});

  @override
  State<OnboardingNameScreen> createState() => _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends State<OnboardingNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _error;

  void _handleNext() {
    if (_nameController.text.isEmpty) {
      setState(() => _error = 'Bitte gib deinen Namen ein.');
      return;
    }
    Provider.of<ProfileProvider>(context, listen: false)
        .updateField('name', _nameController.text);
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
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Name',
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
