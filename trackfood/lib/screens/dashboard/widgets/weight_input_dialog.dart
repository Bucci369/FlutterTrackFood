import 'package:flutter/cupertino.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../services/supabase_service.dart';

class WeightInputDialog extends StatefulWidget {
  final double? currentWeight;
  final Function(double) onWeightSaved;

  const WeightInputDialog({
    super.key,
    this.currentWeight,
    required this.onWeightSaved,
  });

  @override
  State<WeightInputDialog> createState() => _WeightInputDialogState();
}

class _WeightInputDialogState extends State<WeightInputDialog> {
  late TextEditingController _weightController;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.currentWeight?.toStringAsFixed(1) ?? '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveWeight() async {
    final weightText = _weightController.text;
    if (weightText.isEmpty) return;

    final weight = double.tryParse(weightText);
    if (weight == null || weight <= 0) {
      _showError('Bitte geben Sie ein gültiges Gewicht ein');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = SupabaseService();
      final userId = supabaseService.currentUserId;
      
      if (userId == null) {
        _showError('Benutzer nicht angemeldet');
        return;
      }

      // Add weight entry to database
      await supabaseService.client.from('weight_history').insert({
        'user_id': userId,
        'weight_kg': weight,
        'recorded_date': _selectedDate.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      widget.onWeightSaved(weight);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Fehler beim Speichern: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Fehler'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(
        'Gewicht eingeben',
        style: AppTypography.title3.copyWith(
          color: AppColors.label,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          
          // Date picker
          Row(
            children: [
              Text(
                'Datum: ',
                style: AppTypography.body.copyWith(
                  color: AppColors.label,
                ),
              ),
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) => Container(
                        height: 250,
                        color: CupertinoColors.systemBackground,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: _selectedDate,
                          maximumDate: DateTime.now(),
                          onDateTimeChanged: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Text(
                    '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                    style: AppTypography.body.copyWith(
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Weight input
          CupertinoTextField(
            controller: _weightController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            placeholder: 'Gewicht in kg',
            suffix: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                'kg',
                style: AppTypography.body.copyWith(
                  color: AppColors.secondaryLabel,
                ),
              ),
            ),
            style: AppTypography.body.copyWith(
              color: AppColors.label,
            ),
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Abbrechen'),
        ),
        CupertinoDialogAction(
          onPressed: _isLoading ? null : _saveWeight,
          child: _isLoading
              ? CupertinoActivityIndicator()
              : Text('Speichern'),
        ),
      ],
    );
  }
}

// Helper function to show the dialog
void showWeightInputDialog({
  required BuildContext context,
  double? currentWeight,
  required Function(double) onWeightSaved,
}) {
  showCupertinoDialog(
    context: context,
    builder: (context) => WeightInputDialog(
      currentWeight: currentWeight,
      onWeightSaved: onWeightSaved,
    ),
  );
}