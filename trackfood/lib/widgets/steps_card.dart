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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A1A), // Dark card background start
            const Color(0xFF2A2A2A), // Dark card background middle (lighter)
            const Color(0xFF1A1A1A), // Dark card background end
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.2), // Card border - subtle white border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.white.withValues(alpha: 0.1), // Card glow shadow
            blurRadius: 40,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.8), // Card drop shadow
            blurRadius: 50,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: CupertinoColors.white.withValues(alpha: 0.05), // Card top light shadow
            blurRadius: 80,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.systemOrange.withValues(alpha: 0.4), // Steps circle glow - orange
                  blurRadius: 25,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 10.0,
              percent: progress,
              center: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.systemOrange.withValues(alpha: 0.3), // Steps center icon background gradient start - orange
                      AppColors.systemOrange.withValues(alpha: 0.1), // Steps center icon background gradient end - orange
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppColors.systemOrange.withValues(alpha: 0.4), // Steps center icon border - orange
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.systemOrange.withValues(alpha: 0.5), // Steps center icon glow shadow - orange
                      blurRadius: 15,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Icon(
                  CupertinoIcons.flame_fill,
                  color: CupertinoColors.white, // Steps flame icon color
                  size: 24,
                ),
              ),
              progressColor: AppColors.systemOrange, // Steps progress ring - orange
              backgroundColor: CupertinoColors.white.withValues(alpha: 0.1), // Steps progress background ring - subtle white
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schritte',
                  style: AppTypography.title3.copyWith(
                    color: CupertinoColors.white, // Steps title text color
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: CupertinoColors.white.withValues(alpha: 0.3), // Steps title text shadow
                        blurRadius: 6,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${stepState.steps} / ${stepState.goal}',
                  style: AppTypography.headline.copyWith(
                    color: CupertinoColors.white.withValues(alpha: 0.9), // Steps counter text color
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.systemOrange.withValues(alpha: 0.3), // Add button background gradient start - orange
                  AppColors.systemOrange.withValues(alpha: 0.1), // Add button background gradient end - orange
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.systemOrange.withValues(alpha: 0.4), // Add button border - orange
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.systemOrange.withValues(alpha: 0.3), // Add button glow shadow - orange
                  blurRadius: 15,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.all(12),
              onPressed: () => _showAddStepsDialog(context, ref),
              child: Icon(
                CupertinoIcons.add,
                color: CupertinoColors.white, // Add button plus icon color
                size: 20,
              ),
            ),
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
