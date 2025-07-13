import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/profile_provider.dart';
import '../../services/supabase_service.dart';

class OnboardingGoalScreen extends StatefulWidget {
  const OnboardingGoalScreen({super.key});

  @override
  State<OnboardingGoalScreen> createState() => _OnboardingGoalScreenState();
}

class _OnboardingGoalScreenState extends State<OnboardingGoalScreen> {
  String? _selectedGoal;
  String? _error;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _goals = [
    {
      'key': 'weight_loss',
      'title': 'Gewichtsverlust',
      'description': 'Erreiche dein Wunschgewicht',
      'icon': CupertinoIcons.arrow_down_circle,
    },
    {
      'key': 'weight_gain',
      'title': 'Gewichtszunahme',
      'description': 'Gesund zunehmen',
      'icon': CupertinoIcons.arrow_up_circle,
    },
    {
      'key': 'maintain_weight',
      'title': 'Gewicht halten',
      'description': 'Aktuelles Gewicht beibehalten',
      'icon': CupertinoIcons.arrow_right,
    },
    {
      'key': 'muscle_gain',
      'title': 'Muskelaufbau',
      'description': 'Muskeln aufbauen',
      'icon': CupertinoIcons.sportscourt,
    },
    {
      'key': 'improved_health',
      'title': 'Gesundheit verbessern',
      'description': 'Allgemeine Gesundheit',
      'icon': CupertinoIcons.heart,
    },
    {
      'key': 'more_energy',
      'title': 'Mehr Energie',
      'description': 'Mehr Vitalität im Alltag',
      'icon': CupertinoIcons.bolt,
    },
  ];

  Future<void> _handleNext() async {
    if (_selectedGoal == null) {
      setState(() => _error = 'Bitte wähle dein Ziel aus.');
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      
      // Update local state
      provider.updateField('goal', _selectedGoal);
      
      // Save to Supabase incrementally
      final supabaseService = SupabaseService();
      final userId = supabaseService.currentUserId;
      
      if (userId != null) {
        await supabaseService.client
            .from('profiles')
            .update({'goal': _selectedGoal})
            .eq('id', userId);
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/onboarding/summary');
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Fehler beim Speichern. Versuche es erneut.');
        HapticFeedback.heavyImpact();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CupertinoColors.systemBlue.withOpacity(0.1),
              CupertinoColors.systemBackground,
              CupertinoColors.systemGreen.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).pop(),
                          child: Icon(
                            CupertinoIcons.back,
                            color: CupertinoColors.systemBlue,
                            size: 24,
                          ),
                        ),
                        Text(
                          'Schritt 6 von 6',
                          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                          child: Icon(
                            CupertinoIcons.xmark,
                            color: CupertinoColors.systemGrey,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: CupertinoColors.systemGrey5,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 6.0 / 6.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: CupertinoScrollbar(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Title
                        Text(
                          'Was ist dein Ziel?',
                          style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.label,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Wähle dein Hauptziel für eine personalisierte Beratung',
                          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            fontSize: 16,
                            color: CupertinoColors.secondaryLabel,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // DEBUG INFO
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemYellow.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'DEBUG INFO:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Selected Goal: ${_selectedGoal ?? "NONE"}'),
                              Text('Button Active: ${_selectedGoal != null && !_isLoading}'),
                            ],
                          ),
                        ),
                        
                        // Simple Column Layout für Goals
                        Column(
                          children: _goals.map((goal) => _buildSimpleGoalCard(goal)).toList(),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Error message
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: CupertinoColors.systemRed.withOpacity(0.3)),
                            ),
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: CupertinoColors.systemRed,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton.filled(
                    onPressed: _selectedGoal != null && !_isLoading ? _handleNext : null,
                    child: _isLoading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CupertinoActivityIndicator(color: CupertinoColors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Speichert...',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Fertigstellen',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleGoalCard(Map<String, dynamic> goal) {
    final isSelected = _selectedGoal == goal['key'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          print('CLICKED: ${goal['key']}'); // Debug print
          setState(() {
            _selectedGoal = goal['key'];
            _error = null;
          });
          HapticFeedback.selectionClick();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected
                ? CupertinoColors.systemBlue.withOpacity(0.1)
                : CupertinoColors.systemGrey6,
            border: Border.all(
              color: isSelected
                  ? CupertinoColors.systemBlue
                  : CupertinoColors.separator,
              width: isSelected ? 2 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? CupertinoColors.systemBlue.withOpacity(0.15)
                      : CupertinoColors.systemGrey5,
                ),
                child: Icon(
                  goal['icon'],
                  color: isSelected
                      ? CupertinoColors.systemBlue
                      : CupertinoColors.secondaryLabel,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal['title'],
                      style: TextStyle(
                        color: isSelected
                            ? CupertinoColors.systemBlue
                            : CupertinoColors.label,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal['description'],
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: CupertinoColors.systemBlue,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}