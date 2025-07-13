import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../services/supabase_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../activities/activities_screen.dart';

class RecentActivities extends StatefulWidget {
  const RecentActivities({super.key});

  @override
  State<RecentActivities> createState() => _RecentActivitiesState();
}

class _RecentActivitiesState extends State<RecentActivities> {
  List<Map<String, dynamic>> activities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
      if (profile?.id == null) return;

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final yesterdayString = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      final response = await SupabaseService().client
          .from('user_activities')
          .select('activity_name, emoji, duration_min, calories, activity_date, created_at')
          .eq('user_id', profile!.id)
          .gte('activity_date', yesterdayString)
          .lte('activity_date', todayString)
          .order('created_at', ascending: false)
          .limit(10);

      setState(() {
        activities = response.map<Map<String, dynamic>>((activity) {
          final activityDate = DateTime.parse(activity['activity_date']);
          final isToday = activityDate.day == today.day && 
                         activityDate.month == today.month && 
                         activityDate.year == today.year;
          
          final createdAt = DateTime.parse(activity['created_at']);
          final timeString = isToday 
              ? '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}'
              : 'Gestern';

          return {
            'emoji': activity['emoji'] ?? '🏃‍♂️',
            'name': activity['activity_name'] ?? 'Aktivität',
            'duration': '${activity['duration_min'] ?? 0} min',
            'calories': activity['calories'] ?? 0,
            'time': timeString,
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading activities: $e');
      setState(() {
        activities = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280, // Increased height for more activities
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF6F1E7), // Apple White
        border: Border.all(
          color: AppColors.separator,
          width: 1,
        ),
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
                style: AppTypography.headline.copyWith(
                  color: AppColors.label,
                ),
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
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? _buildLoadingState()
                : activities.isEmpty
                    ? _buildEmptyState()
                    : CupertinoScrollbar(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: activities.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final activity = activities[index];
                            return _buildActivityItem(activity, index);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.background,
        border: Border.all(
          color: AppColors.separator,
          width: 1,
        ),
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
    .slideX(begin: 0.3, end: 0);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Lade Aktivitäten...',
            style: AppTypography.body.copyWith(
              color: AppColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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