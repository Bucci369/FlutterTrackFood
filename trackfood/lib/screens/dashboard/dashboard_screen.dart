import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/progress_rings.dart';
import 'widgets/macro_grid.dart';
import 'widgets/recent_activities.dart';
import 'widgets/recent_meals.dart';
import 'widgets/fasting_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _pullRefreshController;
  final ScrollController _scrollController = ScrollController();
  
  bool _isRefreshing = false;
  DateTime _selectedDate = DateTime.now();
  
  // Dashboard data
  double _dailyCalories = 0;
  double _calorieGoal = 2000;
  double _waterIntake = 0;
  double _waterGoal = 8; // glasses
  
  Map<String, double> _macros = {
    'protein': 0,
    'carbs': 0,
    'fat': 0,
    'fiber': 0,
    'sugar': 0,
    'sodium': 0,
  };

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _pullRefreshController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _backgroundController.repeat();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _pullRefreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
      if (profile != null) {
        // Calculate calorie goal based on profile
        _calorieGoal = _calculateCalorieGoal(profile);
        
        // Load today's data from Supabase
        await _loadTodaysNutrition();
        await _loadWaterIntake();
        
        if (mounted) setState(() {});
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  double _calculateCalorieGoal(profile) {
    // Simplified BMR calculation (Mifflin-St Jeor)
    double bmr;
    if (profile.gender == 'male') {
      bmr = 88.362 + (13.397 * profile.weightKg) + (4.799 * profile.heightCm) - (5.677 * profile.age);
    } else {
      bmr = 447.593 + (9.247 * profile.weightKg) + (3.098 * profile.heightCm) - (4.330 * profile.age);
    }
    
    // Activity multiplier
    double activityMultiplier = 1.2; // sedentary default
    switch (profile.activityLevel) {
      case 'lightly_active': activityMultiplier = 1.375; break;
      case 'moderately_active': activityMultiplier = 1.55; break;
      case 'very_active': activityMultiplier = 1.725; break;
      case 'extremely_active': activityMultiplier = 1.9; break;
    }
    
    double tdee = bmr * activityMultiplier;
    
    // Adjust for goal
    switch (profile.goal) {
      case 'weight_loss': return tdee - 500; // 0.5kg per week
      case 'weight_gain': return tdee + 500;
      default: return tdee; // maintain weight
    }
  }

  Future<void> _loadTodaysNutrition() async {
    // This would load from diary_entries table when implemented
    // For now, using sample data
    setState(() {
      _dailyCalories = 1250;
      _macros = {
        'protein': 85,
        'carbs': 120,
        'fat': 45,
        'fiber': 25,
        'sugar': 30,
        'sodium': 1800,
      };
    });
  }

  Future<void> _loadWaterIntake() async {
    // This would load from water_intake table when implemented
    setState(() {
      _waterIntake = 6;
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    _pullRefreshController.forward();
    
    await _loadDashboardData();
    await Future.delayed(const Duration(milliseconds: 500));
    
    _pullRefreshController.reverse();
    setState(() => _isRefreshing = false);
    
    HapticFeedback.lightImpact();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Gute Nacht';
    if (hour < 12) return 'Guten Morgen';
    if (hour < 18) return 'Guten Tag';
    if (hour < 22) return 'Guten Abend';
    return 'Gute Nacht';
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context).profile;
    
    return Scaffold(
      body: Container(
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
            // Animated gradient overlay
            AnimatedBuilder(
              animation: _backgroundController,
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
                      transform: GradientRotation(_backgroundController.value * 2 * 3.14159),
                    ),
                  ),
                );
              },
            ),
            
            SafeArea(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                backgroundColor: Colors.white,
                color: const Color(0xFF34A0A4),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Dashboard Header
                    SliverToBoxAdapter(
                      child: DashboardHeader(
                        greeting: _getGreeting(),
                        userName: profile?.name.split(' ').first ?? 'User',
                        date: _selectedDate,
                        calorieProgress: _dailyCalories / _calorieGoal,
                        waterProgress: _waterIntake / _waterGoal,
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.3, end: 0),
                    ),
                    
                    // Progress Rings
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ProgressRings(
                          calorieProgress: _dailyCalories / _calorieGoal,
                          caloriesCurrent: _dailyCalories,
                          caloriesGoal: _calorieGoal,
                          waterProgress: _waterIntake / _waterGoal,
                          waterCurrent: _waterIntake,
                          waterGoal: _waterGoal,
                        )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                      ),
                    ),
                    
                    // Macro Grid
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: MacroGrid(macros: _macros)
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                      ),
                    ),
                    
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    
                    // Recent Activities
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
                    
                    // Recent Meals
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
                    
                    // Fasting Card
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
            
            // Pull refresh indicator
            if (_isRefreshing)
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
              )
              .animate()
              .fadeIn(duration: 200.ms)
              .slideY(begin: -1, end: 0),
          ],
        ),
      ),
    );
  }
}