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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF000000), // Pure black background start - Apple sharp
            const Color(0xFF1C1C1E), // Dark gray background middle - iOS system
            const Color(0xFF000000), // Pure black background end - Apple sharp
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.glassWhite, // Card border - glass effect
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.vibrantOrange.withValues(alpha: 0.08), // Card accent glow - vibrant orange (reduced)
            blurRadius: 40,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: AppColors.deepBlack.withValues(alpha: 0.9), // Card deep drop shadow - pure black
            blurRadius: 40,
            offset: const Offset(0, 25),
          ),
          BoxShadow(
            color: AppColors.pureWhite.withValues(alpha: 0.08), // Card top rim light - crisp white
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glassmorphism overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: AppColors.glassGradient, // Glass overlay gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.vibrantOrange.withValues(alpha: 0.3), // Steps circle glow - vibrant orange (reduced)
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppColors.vibrantOrange.withValues(alpha: 0.15), // Steps circle inner glow - vibrant orange (reduced)
                  blurRadius: 10,
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
                    colors: AppColors.vibrantOrangeGradient, // Steps center icon background - vibrant gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppColors.vibrantOrange.withValues(alpha: 0.8), // Steps center icon border - vibrant orange
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.vibrantOrange.withValues(alpha: 0.4), // Steps center icon glow shadow - vibrant orange (reduced)
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  CupertinoIcons.flame_fill,
                  color: CupertinoColors.white, // Steps flame icon color
                  size: 24,
                ),
              ),
              progressColor: AppColors.vibrantOrange, // Steps progress ring - vibrant orange
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
                colors: AppColors.vibrantOrangeGradient, // Add button background - vibrant gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.pureWhite.withValues(alpha: 0.3), // Add button border - crisp white
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.vibrantOrange.withValues(alpha: 0.25), // Add button glow shadow - vibrant orange (reduced)
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppColors.vibrantOrange.withValues(alpha: 0.1), // Add button inner glow - vibrant orange (reduced)
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.all(8),
              onPressed: () => _showAddStepsDialog(context, ref),
              child: Icon(
                CupertinoIcons.add,
                color: CupertinoColors.white, // Add button plus icon color
                size: 18,
              ),
            ),
          ),
              ],
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
