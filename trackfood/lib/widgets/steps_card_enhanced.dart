import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:trackfood/providers/step_provider_enhanced.dart';
import 'package:trackfood/theme/app_colors.dart';
import 'package:trackfood/theme/app_typography.dart';
import 'package:trackfood/services/permission_service.dart';

class EnhancedStepsCard extends ConsumerWidget {
  const EnhancedStepsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepState = ref.watch(enhancedStepProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1E7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.separator, width: 1),
      ),
      child: Column(
        children: [
          // Main content
          Row(
            children: [
              _buildProgressIndicator(stepState),
              const SizedBox(width: 16),
              Expanded(child: _buildStepInfo(stepState)),
              _buildActionButton(context, ref, stepState),
            ],
          ),

          // Status indicator
          if (stepState.error != null)
            _buildErrorBar(context, ref, stepState)
          else if (!stepState.hasPermissions)
            _buildPermissionBar(context, ref)
          else if (stepState.isListening)
            _buildStatusBar('🟢 Live Tracking aktiv', AppColors.systemGreen)
          else
            _buildStatusBar('⚪ Manueller Modus', AppColors.secondaryLabel),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(EnhancedStepState stepState) {
    Color progressColor = AppColors.systemOrange;

    // Change color based on progress
    if (stepState.progress >= 1.0) {
      progressColor = AppColors.systemGreen;
    } else if (stepState.progress >= 0.75) {
      progressColor = AppColors.systemBlue;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        CircularPercentIndicator(
          radius: 40.0,
          lineWidth: 8.0,
          percent: stepState.progress,
          center: stepState.goalAchieved
              ? const Icon(
                  CupertinoIcons.checkmark,
                  color: AppColors.systemGreen,
                  size: 32,
                )
              : const Icon(
                  CupertinoIcons.flame_fill,
                  color: AppColors.systemOrange,
                  size: 28,
                ),
          progressColor: progressColor,
          backgroundColor: AppColors.tertiarySystemFill,
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 500,
        ),
        if (stepState.isLoading) const CupertinoActivityIndicator(),
      ],
    );
  }

  Widget _buildStepInfo(EnhancedStepState stepState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Schritte', style: AppTypography.title3),
        Text(
          stepState.steps.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          ),
          style: AppTypography.largeTitle.copyWith(color: AppColors.label),
        ),
        Text(
          'Ziel: ${stepState.goal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
          style: AppTypography.caption1.copyWith(
            color: AppColors.secondaryLabel,
          ),
        ),
        if (stepState.dailySummary != null &&
            stepState.dailySummary!.remainingSteps > 0)
          Text(
            'Noch ${stepState.dailySummary!.remainingSteps} Schritte',
            style: AppTypography.caption1.copyWith(
              color: AppColors.tertiaryLabel,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    EnhancedStepState stepState,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showOptionsMenu(context, ref, stepState),
      child: const Icon(CupertinoIcons.ellipsis_circle, size: 28),
    );
  }

  Widget _buildErrorBar(
    BuildContext context,
    WidgetRef ref,
    EnhancedStepState stepState,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.systemRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            color: AppColors.systemRed,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              stepState.error!,
              style: AppTypography.caption1.copyWith(
                color: AppColors.systemRed,
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => ref.read(enhancedStepProvider.notifier).refresh(),
            child: Icon(
              CupertinoIcons.refresh,
              color: AppColors.systemRed,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionBar(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.systemYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.lock_shield,
            color: AppColors.systemYellow,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Berechtigung für automatisches Tracking erforderlich',
              style: AppTypography.caption1.copyWith(
                color: AppColors.systemYellow,
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () =>
                ref.read(enhancedStepProvider.notifier).requestPermissions(),
            child: Text(
              'Erlauben',
              style: AppTypography.caption1.copyWith(
                color: AppColors.systemYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Text(text, style: AppTypography.caption1.copyWith(color: color)),
    );
  }

  void _showOptionsMenu(
    BuildContext context,
    WidgetRef ref,
    EnhancedStepState stepState,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Schrittzähler Optionen'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showAddStepsDialog(context, ref);
            },
            child: const Text('Schritte manuell hinzufügen'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showGoalDialog(context, ref, stepState);
            },
            child: const Text('Ziel ändern'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(enhancedStepProvider.notifier).refresh();
            },
            child: const Text('Aktualisieren'),
          ),
          if (!stepState.hasPermissions)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                ref.read(enhancedStepProvider.notifier).requestPermissions();
              },
              child: const Text('Berechtigung anfordern'),
            ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              PermissionService.openAppSettings();
            },
            child: const Text('App Einstellungen öffnen'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
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
                ref.read(enhancedStepProvider.notifier).addManualSteps(steps);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }

  void _showGoalDialog(
    BuildContext context,
    WidgetRef ref,
    EnhancedStepState stepState,
  ) {
    final TextEditingController controller = TextEditingController(
      text: stepState.goal.toString(),
    );
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Schritt-Ziel ändern'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Tägliches Ziel',
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
              final int? goal = int.tryParse(controller.text);
              if (goal != null && goal > 0) {
                ref.read(enhancedStepProvider.notifier).updateGoal(goal);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}
