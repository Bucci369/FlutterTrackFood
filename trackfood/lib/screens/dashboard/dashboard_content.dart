import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/progress_rings.dart';
import 'widgets/macro_grid.dart';
import 'widgets/recent_activities.dart';
import 'widgets/recent_meals.dart';
import 'widgets/fasting_card.dart';

class DashboardContent extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context).profile;
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/background2.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black26,
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          if (backgroundController != null)
            AnimatedBuilder(
              animation: backgroundController!,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF99D98C).withValues(alpha: 0.7),
                        const Color(0xFF76C893).withValues(alpha: 0.6),
                        const Color(0xFF52B69A).withValues(alpha: 0.7),
                        const Color(0xFF34A0A4).withValues(alpha: 0.8),
                      ],
                      transform: GradientRotation(
                          backgroundController!.value * 2 * 3.14159),
                    ),
                  ),
                );
              },
            ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: handleRefresh ?? () async {},
              backgroundColor: Colors.white,
              color: const Color(0xFF34A0A4),
              child: CustomScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: DashboardHeader(
                      greeting: getGreeting != null ? getGreeting!() : '',
                      userName: profile?.name.split(' ').first ?? 'User',
                      date: selectedDate ?? DateTime.now(),
                      calorieProgress:
                          (dailyCalories ?? 0) / (calorieGoal ?? 1),
                      waterProgress: (waterIntake ?? 0) / (waterGoal ?? 1),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.3, end: 0),
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
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MacroGrid(macros: macros ?? {})
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const RecentActivities()
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const RecentMeals()
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const FastingCard()
                          .animate()
                          .fadeIn(delay: 1000.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Color(0xFF34A0A4),
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Aktualisiere...',
                        style: TextStyle(
                          color: Color(0xFF34A0A4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: -1, end: 0),
        ],
      ),
    );
  }
}
