import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class QuickActions extends StatelessWidget {
  final Function(String) onActionTap;
  final List<String> actions;

  const QuickActions({
    super.key,
    required this.onActionTap,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schnellaktionen:',
            style: AppTypography.headline.copyWith(
              color: AppColors.label,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                actions.map((action) => _buildActionChip(action)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(String action) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(20),
      onPressed: () => onActionTap(action),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          action,
          style: AppTypography.body.copyWith(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
