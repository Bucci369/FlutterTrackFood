import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:trackfood/providers/step_provider.dart';
import 'package:trackfood/theme/app_colors.dart';
import 'package:trackfood/theme/app_typography.dart';

class StepsCard extends ConsumerWidget {
  const StepsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepState = ref.watch(stepProvider);
    final progress = (stepState.goal > 0)
        ? (stepState.steps / stepState.goal).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1E7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.separator, width: 1),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 8.0,
            percent: progress,
            center: const Icon(
              CupertinoIcons.flame_fill,
              color: AppColors.systemOrange,
            ),
            progressColor: AppColors.systemOrange,
            backgroundColor: AppColors.tertiarySystemFill,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Schritte', style: AppTypography.title3),
                Text(
                  '${stepState.steps} / ${stepState.goal}',
                  style: AppTypography.headline.copyWith(
                    color: AppColors.label,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            onPressed: () => _showAddStepsDialog(context, ref),
            child: const Icon(CupertinoIcons.add),
          ),
        ],
      ),
    );
  }

  void _showAddStepsDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Schritte manuell hinzufügen'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Anzahl der Schritte',
            keyboardType: TextInputType.number,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              final int? steps = int.tryParse(controller.text);
              if (steps != null && steps > 0) {
                ref.read(stepProvider.notifier).addManualSteps(steps);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }
}
