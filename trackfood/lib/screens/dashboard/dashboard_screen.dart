import 'dashboard_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../diary/diary_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';

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
  final DateTime _selectedDate = DateTime.now();

  // Dashboard data
  double _dailyCalories = 0;
  double _calorieGoal = 2000;
  double _waterIntake = 0;
  final double _waterGoal = 8; // glasses

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
      final profile =
          Provider.of<ProfileProvider>(context, listen: false).profile;
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
      bmr = 88.362 +
          (13.397 * profile.weightKg) +
          (4.799 * profile.heightCm) -
          (5.677 * profile.age);
    } else {
      bmr = 447.593 +
          (9.247 * profile.weightKg) +
          (3.098 * profile.heightCm) -
          (4.330 * profile.age);
    }

    // Activity multiplier
    double activityMultiplier = 1.2; // sedentary default
    switch (profile.activityLevel) {
      case 'lightly_active':
        activityMultiplier = 1.375;
        break;
      case 'moderately_active':
        activityMultiplier = 1.55;
        break;
      case 'very_active':
        activityMultiplier = 1.725;
        break;
      case 'extremely_active':
        activityMultiplier = 1.9;
        break;
    }

    double tdee = bmr * activityMultiplier;

    // Adjust for goal
    switch (profile.goal) {
      case 'weight_loss':
        return tdee - 500; // 0.5kg per week
      case 'weight_gain':
        return tdee + 500;
      default:
        return tdee; // maintain weight
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

  int _selectedIndex = 0;

  List<Widget> get _screens => [
        DashboardContent(
          backgroundController: _backgroundController,
          pullRefreshController: _pullRefreshController,
          scrollController: _scrollController,
          isRefreshing: _isRefreshing,
          selectedDate: _selectedDate,
          dailyCalories: _dailyCalories,
          calorieGoal: _calorieGoal,
          waterIntake: _waterIntake,
          waterGoal: _waterGoal,
          macros: _macros,
          handleRefresh: _handleRefresh,
          getGreeting: _getGreeting,
        ),
        DiaryScreen(),
        ChatScreen(),
        ProfileScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          activeColor: const Color(0xFF34A0A4),
          inactiveColor: CupertinoColors.systemGrey,
          backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house_fill),
              activeIcon: Icon(CupertinoIcons.house_fill),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.book),
              activeIcon: Icon(CupertinoIcons.book_fill),
              label: 'Tagebuch',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble),
              activeIcon: Icon(CupertinoIcons.chat_bubble_fill),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_fill),
              label: 'Profil',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (context) => _screens[index],
          );
        },
      ),
    );
  }
}
