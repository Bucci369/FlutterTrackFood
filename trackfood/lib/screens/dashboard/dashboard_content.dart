import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/providers/diary_provider.dart';
import 'package:trackfood/providers/profile_provider.dart' as profile_provider;
import 'package:trackfood/providers/water_provider.dart';
import 'package:trackfood/utils/nutrition_utils.dart';
import '../../theme/app_colors.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/progress_rings.dart';
import 'widgets/macro_grid.dart';
import 'widgets/recent_activities.dart';
import 'widgets/recent_meals.dart';
import 'widgets/fasting_card.dart';

class DashboardContent extends ConsumerWidget {
  final AnimationController? backgroundController;
  final AnimationController? pullRefreshController;
  final ScrollController? scrollController;
  final bool? isRefreshing;
  final DateTime? selectedDate;
  final Future<void> Function()? handleRefresh;
  final String Function()? getGreeting;

  const DashboardContent({
    super.key,
    this.backgroundController,
    this.pullRefreshController,
    this.scrollController,
    this.isRefreshing,
    this.selectedDate,
    this.handleRefresh,
    this.getGreeting,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profile_provider.profileProvider);
    final waterIntakeAsync = ref.watch(waterIntakeProvider);
    final diaryState = ref.watch(diaryProvider);

    if (profileAsync.isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }
    
    if (profileAsync.error != null) {
      return Center(child: Text('Fehler: ${profileAsync.error}'));
    }
    
    final profile = profileAsync.profile;
    final dailyCalories = diaryState.totalCalories;
    final calorieGoal = profile != null
        ? calculateDailyCalorieGoal(profile).toDouble()
        : 2000.0;
        final macros = {
          'protein': diaryState.totalProtein,
          'carbs': diaryState.totalCarbs,
          'fat': diaryState.totalFat,
        };

        return Container(
          color: const Color(0xFFF6F1E7),
          child: Stack(
            children: [
              SafeArea(
                child: CustomScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: handleRefresh ?? () async {},
                    ),
                    waterIntakeAsync.when(
                      data: (intake) => SliverToBoxAdapter(
                        child: DashboardHeader(
                          greeting: getGreeting != null ? getGreeting!() : '',
                          userName: profile?.firstName ?? 'User',
                          date: selectedDate ?? DateTime.now(),
                          calorieProgress: calorieGoal > 0
                              ? (dailyCalories / calorieGoal)
                              : 0.0,
                          waterProgress: intake.dailyGoalMl > 0
                              ? (intake.amountMl / intake.dailyGoalMl)
                              : 0.0,
                        ),
                      ),
                      loading: () =>
                          SliverToBoxAdapter(child: Container(height: 120)),
                      error: (err, stack) => SliverToBoxAdapter(
                        child: Center(child: Text('Header-Fehler')),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: waterIntakeAsync.when(
                          data: (intake) => ProgressRings(
                            calorieProgress: calorieGoal > 0
                                ? (dailyCalories / calorieGoal)
                                : 0.0,
                            caloriesCurrent: dailyCalories,
                            caloriesGoal: calorieGoal,
                            waterProgress: intake.dailyGoalMl > 0
                                ? (intake.amountMl / intake.dailyGoalMl)
                                : 0.0,
                            waterCurrent: intake.amountMl.toDouble(),
                            waterGoal: intake.dailyGoalMl.toDouble(),
                          ),
                          loading: () =>
                              const Center(child: CupertinoActivityIndicator()),
                          error: (err, stack) => Text('Error: $err'),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: MacroGrid(macros: macros),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: RecentActivities(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: RecentMeals(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: FastingCard(),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
              if (isRefreshing ?? false)
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F1E7), // Apple White
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.separator,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CupertinoActivityIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Aktualisiere...',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.41,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
  }
}
