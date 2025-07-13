import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_providers.dart';
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
  final double? dailyCalories;
  final double? calorieGoal;
  final double? waterIntake;
  final double? waterGoal;
  final Map<String, double>? macros;
  final Future<void> Function()? handleRefresh;
  final String Function()? getGreeting;

  const DashboardContent({
    Key? key,
    this.backgroundController,
    this.pullRefreshController,
    this.scrollController,
    this.isRefreshing,
    this.selectedDate,
    this.dailyCalories,
    this.calorieGoal,
    this.waterIntake,
    this.waterGoal,
    this.macros,
    this.handleRefresh,
    this.getGreeting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).profile;
    return Container(
      color: const Color(0xFFF6F1E7), // Apple White background
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
                SliverToBoxAdapter(
                  child: DashboardHeader(
                    greeting: getGreeting != null ? getGreeting!() : '',
                    userName: profile?.firstName ?? 'User',
                    date: selectedDate ?? DateTime.now(),
                    calorieProgress: (dailyCalories ?? 0) / (calorieGoal ?? 1),
                    waterProgress: (waterIntake ?? 0) / (waterGoal ?? 1),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ProgressRings(
                      calorieProgress:
                          (dailyCalories ?? 0) / (calorieGoal ?? 1),
                      caloriesCurrent: dailyCalories ?? 0,
                      caloriesGoal: calorieGoal ?? 0,
                      waterProgress: (waterIntake ?? 0) / (waterGoal ?? 1),
                      waterCurrent: waterIntake ?? 0,
                      waterGoal: waterGoal ?? 0,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: MacroGrid(macros: macros ?? {}),
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
