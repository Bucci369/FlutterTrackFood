import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/providers/dashboard_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../activities/activities_screen.dart';

class RecentActivities extends ConsumerWidget {
  const RecentActivities({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return Container(
      width: double.infinity,
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF6F1E7),
        border: Border.all(color: AppColors.separator, width: 1),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aktivitäten',
                style: AppTypography.headline.copyWith(color: AppColors.label),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const ActivitiesScreen(),
                    ),
                  );
                },
                child: Text(
                  'Alle anzeigen',
                  style: AppTypography.body.copyWith(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: activitiesAsync.when(
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (err, stack) => Center(child: Text('Fehler: $err')),
              data: (activities) {
                if (activities.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return _buildActivityRow(activity, index, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(
    Map<String, dynamic> activity,
    int index,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // Add padding to the bottom
      child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.background,
              border: Border.all(color: AppColors.separator, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.2),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      activity['emoji'],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['name'],
                        style: AppTypography.body.copyWith(
                          color: AppColors.label,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${activity['duration']} • ${activity['calories']} kcal',
                        style: AppTypography.body.copyWith(
                          color: AppColors.secondaryLabel,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  activity['time'],
                  style: AppTypography.body.copyWith(
                    color: AppColors.secondaryLabel,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
          .animate(delay: Duration(milliseconds: 100 * index))
          .fadeIn(duration: 400.ms)
          .slideX(begin: 0.3, end: 0),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.2),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Icon(
              CupertinoIcons.sportscourt,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Keine Aktivitäten heute',
            style: AppTypography.body.copyWith(
              color: AppColors.label,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Starte dein erstes Workout!',
            style: AppTypography.body.copyWith(
              color: AppColors.secondaryLabel,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            color: AppColors.primary,
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => const ActivitiesScreen(),
                ),
              );
            },
            child: const Text(
              'Aktivität hinzufügen',
              style: TextStyle(color: CupertinoColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
