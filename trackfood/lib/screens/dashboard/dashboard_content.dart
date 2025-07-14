import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/providers/diary_provider.dart';
import 'package:trackfood/providers/profile_provider.dart' as profile_provider;
import 'package:trackfood/providers/water_provider.dart';
import 'package:trackfood/providers/dashboard_providers.dart'; // Import dashboard providers
import 'package:trackfood/utils/nutrition_utils.dart';
import 'package:trackfood/widgets/steps_card.dart';
import '../../theme/app_colors.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/progress_rings.dart';
import 'widgets/macro_grid.dart';
import 'widgets/recent_activities.dart';
import 'widgets/recent_meals.dart';
import 'widgets/fasting_card.dart';

// Function to get a greeting based on the time of day
String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Guten Morgen';
  }
  if (hour < 18) {
    return 'Guten Tag';
  }
  return 'Guten Abend';
}

class DashboardContent extends ConsumerWidget {
  final AnimationController? backgroundController;
  final AnimationController? pullRefreshController;
  final ScrollController? scrollController;
  final bool? isRefreshing;
  final DateTime? selectedDate;
  final Future<void> Function()? handleRefresh;

  const DashboardContent({
    super.key,
    this.backgroundController,
    this.pullRefreshController,
    this.scrollController,
    this.isRefreshing,
    this.selectedDate,
    this.handleRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profile_provider.profileProvider);
    final waterIntakeAsync = ref.watch(waterIntakeProvider);
    final diaryState = ref.watch(diaryProvider);
    final burnedCaloriesAsync = ref.watch(dailyBurnedCaloriesProvider);

    final profile = profileState.profile;
    final dailyCalories = diaryState.totalCalories;
    final calorieGoal = profile != null
        ? calculateDailyCalorieGoal(profile).toDouble()
        : 2000.0;
    final macros = {
      'protein': diaryState.totalProtein,
      'carbs': diaryState.totalCarbs,
      'fat': diaryState.totalFat,
      'fiber': diaryState.totalFiber,
      'sugar': diaryState.totalSugar,
      'sodium': diaryState.totalSodium,
    };

    if (profileState.isLoading && profile == null) {
      return const Center(child: CupertinoActivityIndicator());
    }

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
                // Handle loading and error states for header and progress rings section
                if (waterIntakeAsync.isLoading ||
                    burnedCaloriesAsync.isLoading) // Check loading for both
                  SliverToBoxAdapter(
                    child: Container(
                      height: 250,
                      child: Center(child: CupertinoActivityIndicator()),
                    ),
                  )
                else if (waterIntakeAsync.hasError ||
                    burnedCaloriesAsync.hasError) // Check errors for both
                  SliverToBoxAdapter(
                    child: Center(child: Text('Fehler beim Laden der Daten')),
                  )
                else // Both have data
                  SliverList(
                    delegate: SliverChildListDelegate([
                      DashboardHeader(
                        greeting: getGreeting(),
                        userName: profile?.firstName ?? 'User',
                        date: selectedDate ?? DateTime.now(),
                        calorieProgress: calorieGoal > 0
                            ? (dailyCalories / calorieGoal)
                            : 0.0,
                        waterProgress: waterIntakeAsync.value!.dailyGoalMl > 0
                            ? (waterIntakeAsync.value!.amountMl /
                                  waterIntakeAsync.value!.dailyGoalMl)
                            : 0.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ProgressRings(
                          calorieProgress: calorieGoal > 0
                              ? (dailyCalories / calorieGoal)
                              : 0.0,
                          caloriesCurrent: dailyCalories,
                          caloriesGoal: calorieGoal,
                          waterProgress: waterIntakeAsync.value!.dailyGoalMl > 0
                              ? (waterIntakeAsync.value!.amountMl /
                                    waterIntakeAsync.value!.dailyGoalMl)
                              : 0.0,
                          waterCurrent: waterIntakeAsync.value!.amountMl
                              .toDouble(),
                          waterGoal: waterIntakeAsync.value!.dailyGoalMl
                              .toDouble(),
                          burnedCalories: burnedCaloriesAsync.value!,
                        ),
                      ),
                    ]),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: MacroGrid(macros: macros),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: StepsCard(),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    border: Border.all(color: AppColors.separator, width: 1),
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
