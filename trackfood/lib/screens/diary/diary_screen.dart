import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/supabase_service.dart';
import '../../models/diary_entry.dart';
import '../../models/meal_type.dart';
import '../../models/water_intake.dart';
import 'widgets/date_navigator.dart';
import 'widgets/water_tracker_card.dart';
import 'widgets/meal_card.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  final ScrollController _scrollController = ScrollController();
  
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  
  // Daily nutrition data
  double _dailyCalorieGoal = 2000;
  Map<MealType, List<DiaryEntry>> _mealEntries = {};
  WaterIntake? _waterIntake;
  
  // Daily totals
  double _totalCalories = 0;
  double _totalProtein = 0;
  double _totalCarbs = 0;
  double _totalFat = 0;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _backgroundController.repeat();
    _loadDiaryData();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDiaryData() async {
    setState(() => _isLoading = true);
    
    try {
      final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
      if (profile != null) {
        _dailyCalorieGoal = _calculateDailyCalorieGoal(profile);
      }
      
      await Future.wait([
        _loadDiaryEntries(),
        _loadWaterIntake(),
      ]);
      
      _calculateDailyTotals();
    } catch (e) {
      print('Error loading diary data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double _calculateDailyCalorieGoal(profile) {
    // BMR calculation (Mifflin-St Jeor)
    double bmr;
    if (profile.gender == 'male') {
      bmr = 88.362 + (13.397 * profile.weightKg) + (4.799 * profile.heightCm) - (5.677 * profile.age);
    } else {
      bmr = 447.593 + (9.247 * profile.weightKg) + (3.098 * profile.heightCm) - (4.330 * profile.age);
    }
    
    // Activity multiplier
    double activityMultiplier = 1.2;
    switch (profile.activityLevel) {
      case 'lightly_active': activityMultiplier = 1.375; break;
      case 'moderately_active': activityMultiplier = 1.55; break;
      case 'very_active': activityMultiplier = 1.725; break;
      case 'extremely_active': activityMultiplier = 1.9; break;
    }
    
    double tdee = bmr * activityMultiplier;
    
    // Goal adjustment
    switch (profile.goal) {
      case 'lose_weight': return tdee - 500;
      case 'gain_weight': return tdee + 500;
      default: return tdee;
    }
  }

  Future<void> _loadDiaryEntries() async {
    try {
      final supabaseService = SupabaseService();
      final userId = supabaseService.currentUserId;
      
      if (userId == null) return;
      
      final dateString = _selectedDate.toIso8601String().split('T')[0];
      
      final response = await supabaseService.client
          .from('diary_entries')
          .select()
          .eq('user_id', userId)
          .eq('entry_date', dateString)
          .order('created_at');
      
      final entries = (response as List)
          .map((json) => DiaryEntry.fromJson(json))
          .toList();
      
      // Group entries by meal type
      final groupedEntries = <MealType, List<DiaryEntry>>{};
      for (final mealType in MealType.values) {
        groupedEntries[mealType] = entries
            .where((entry) => entry.mealType == mealType)
            .toList();
      }
      
      setState(() {
        _mealEntries = groupedEntries;
      });
    } catch (e) {
      print('Error loading diary entries: $e');
    }
  }

  Future<void> _loadWaterIntake() async {
    try {
      final supabaseService = SupabaseService();
      final userId = supabaseService.currentUserId;
      
      if (userId == null) return;
      
      final dateString = _selectedDate.toIso8601String().split('T')[0];
      
      final response = await supabaseService.client
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', dateString)
          .maybeSingle();
      
      if (response != null) {
        setState(() {
          _waterIntake = WaterIntake.fromJson(response);
        });
      }
    } catch (e) {
      print('Error loading water intake: $e');
    }
  }

  void _calculateDailyTotals() {
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    
    for (final entries in _mealEntries.values) {
      for (final entry in entries) {
        calories += entry.calories;
        protein += entry.proteinG;
        carbs += entry.carbG;
        fat += entry.fatG;
      }
    }
    
    setState(() {
      _totalCalories = calories;
      _totalProtein = protein;
      _totalCarbs = carbs;
      _totalFat = fat;
    });
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    await _loadDiaryData();
  }

  void _changeDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    _loadDiaryData();
  }

  @override
  Widget build(BuildContext context) {
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
                    // Date Navigator
                    SliverToBoxAdapter(
                      child: DateNavigator(
                        selectedDate: _selectedDate,
                        onDateChanged: _changeDate,
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.3, end: 0),
                    ),
                    
                    // Daily Overview
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildDailyOverview()
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                      ),
                    ),
                    
                    // Water Tracker
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: WaterTrackerCard(
                          waterIntake: _waterIntake,
                          selectedDate: _selectedDate,
                          onWaterAdded: () => _loadWaterIntake(),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                      ),
                    ),
                    
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    
                    // Meal Cards
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final mealType = MealType.values[index];
                          final entries = _mealEntries[mealType] ?? [];
                          final recommendedCalories = (_dailyCalorieGoal * mealType.calorieDistribution).round();
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: MealCard(
                              mealType: mealType,
                              entries: entries,
                              recommendedCalories: recommendedCalories,
                              onEntryAdded: () => _loadDiaryData(),
                            )
                            .animate(delay: Duration(milliseconds: 600 + (index * 100)))
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.3, end: 0),
                          );
                        },
                        childCount: MealType.values.length,
                      ),
                    ),
                    
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
            ),
            
            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyOverview() {
    final calorieProgress = _totalCalories / _dailyCalorieGoal;
    final remainingCalories = (_dailyCalorieGoal - _totalCalories).round();
    
    return GlassmorphicContainer(
      width: double.infinity,
      height: 120,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.1),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tagesübersicht',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_totalCalories.toInt()} / ${_dailyCalorieGoal.toInt()} kcal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: calorieProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                calorieProgress > 1.0 ? Colors.orange : const Color(0xFF99D98C),
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMacroInfo('Protein', '${_totalProtein.toInt()}g', Colors.blue),
                _buildMacroInfo('Carbs', '${_totalCarbs.toInt()}g', Colors.orange),
                _buildMacroInfo('Fett', '${_totalFat.toInt()}g', Colors.pink),
                _buildMacroInfo(
                  remainingCalories > 0 ? 'Übrig' : 'Über',
                  '${remainingCalories.abs()} kcal',
                  remainingCalories > 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}