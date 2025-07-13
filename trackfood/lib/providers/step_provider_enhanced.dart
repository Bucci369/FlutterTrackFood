import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackfood/services/supabase_service.dart';
import 'package:trackfood/services/permission_service.dart';
import 'package:trackfood/providers/profile_provider.dart';
import 'package:trackfood/models/step_data.dart';

class EnhancedStepState {
  final DailyStepSummary? dailySummary;
  final bool isLoading;
  final bool isListening;
  final String? error;
  final bool hasPermissions;
  final DateTime lastUpdate;

  EnhancedStepState({
    this.dailySummary,
    this.isLoading = false,
    this.isListening = false,
    this.error,
    this.hasPermissions = false,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();

  EnhancedStepState copyWith({
    DailyStepSummary? dailySummary,
    bool? isLoading,
    bool? isListening,
    String? error,
    bool? hasPermissions,
    DateTime? lastUpdate,
  }) {
    return EnhancedStepState(
      dailySummary: dailySummary ?? this.dailySummary,
      isLoading: isLoading ?? this.isLoading,
      isListening: isListening ?? this.isListening,
      error: error ?? this.error,
      hasPermissions: hasPermissions ?? this.hasPermissions,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  // Quick access to current values
  int get steps => dailySummary?.totalSteps ?? 0;
  int get goal => dailySummary?.goal ?? 10000;
  double get progress => dailySummary?.progress ?? 0.0;
  bool get goalAchieved => dailySummary?.goalAchieved ?? false;
}

class EnhancedStepNotifier extends StateNotifier<EnhancedStepState> {
  final SupabaseService _supabaseService;
  final String? _userId;
  
  StreamSubscription<StepCount>? _stepCountSubscription;
  Timer? _saveTimer;
  
  // Keys for SharedPreferences
  static const String _keyDailyBaseline = 'daily_step_baseline';
  static const String _keyLastResetDate = 'last_reset_date';
  static const String _keyStepGoal = 'step_goal';

  int _dailyBaseline = 0;
  DateTime _lastResetDate = DateTime.now();

  EnhancedStepNotifier(this._supabaseService, this._userId) : super(EnhancedStepState()) {
    if (_userId != null) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Check permissions first
      final hasPermissions = await PermissionService.hasAllStepCountingPermissions();
      state = state.copyWith(hasPermissions: hasPermissions);
      
      if (!hasPermissions) {
        state = state.copyWith(
          isLoading: false,
          error: 'Berechtigung für Schrittzähler erforderlich',
        );
        return;
      }

      // Load saved data
      await _loadSavedData();
      
      // Load steps from database
      await _loadTodaysSteps();
      
      // Start sensor if permissions granted
      await _startSensorListening();
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Initialisierung fehlgeschlagen: $e',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _dailyBaseline = prefs.getInt(_keyDailyBaseline) ?? 0;
    
    final lastResetDateStr = prefs.getString(_keyLastResetDate);
    if (lastResetDateStr != null) {
      _lastResetDate = DateTime.parse(lastResetDateStr);
    }
    
    // Check if we need to reset for new day
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];
    final lastResetStr = _lastResetDate.toIso8601String().split('T')[0];
    
    if (todayStr != lastResetStr) {
      // New day - reset baseline
      _dailyBaseline = 0;
      _lastResetDate = today;
      await _saveDailyData();
    }
  }

  Future<void> _saveDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDailyBaseline, _dailyBaseline);
    await prefs.setString(_keyLastResetDate, _lastResetDate.toIso8601String());
  }

  Future<void> _loadTodaysSteps() async {
    if (_userId == null) return;
    
    try {
      final today = DateTime.now();
      final totalSteps = await _supabaseService.getStepsForDate(_userId!, today);
      
      // Get step goal from preferences or use default
      final prefs = await SharedPreferences.getInstance();
      final goal = prefs.getInt(_keyStepGoal) ?? 10000;
      
      // Calculate breakdown (this is simplified - in real app you'd query by source)
      final summary = DailyStepSummary(
        date: today,
        totalSteps: totalSteps,
        sensorSteps: totalSteps, // Simplified
        manualSteps: 0, // Simplified
        goal: goal,
      );
      
      state = state.copyWith(dailySummary: summary);
    } catch (e) {
      state = state.copyWith(error: 'Fehler beim Laden der Schritte: $e');
    }
  }

  Future<void> _startSensorListening() async {
    if (!state.hasPermissions) return;
    
    try {
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        (StepCount event) async {
          await _handleSensorData(event);
        },
        onError: (error) {
          state = state.copyWith(
            isListening: false,
            error: 'Sensor-Fehler: $error',
          );
        },
      );
      
      state = state.copyWith(isListening: true);
      
      // Set up periodic saving
      _saveTimer = Timer.periodic(Duration(minutes: 5), (_) {
        _saveSensorStepsToDatabase();
      });
      
    } catch (e) {
      state = state.copyWith(
        isListening: false,
        error: 'Sensor konnte nicht gestartet werden: $e',
      );
    }
  }

  Future<void> _handleSensorData(StepCount stepCount) async {
    final totalStepsSinceBoot = stepCount.steps;
    
    // If baseline is 0 or higher than current (device reboot), set new baseline
    if (_dailyBaseline == 0 || _dailyBaseline > totalStepsSinceBoot) {
      _dailyBaseline = totalStepsSinceBoot;
      await _saveDailyData();
    }
    
    // Calculate today's steps
    final todaysSteps = totalStepsSinceBoot - _dailyBaseline;
    
    // Update state
    final currentSummary = state.dailySummary;
    if (currentSummary != null) {
      final updatedSummary = DailyStepSummary(
        date: currentSummary.date,
        totalSteps: todaysSteps + currentSummary.manualSteps,
        sensorSteps: todaysSteps,
        manualSteps: currentSummary.manualSteps,
        goal: currentSummary.goal,
      );
      
      state = state.copyWith(
        dailySummary: updatedSummary,
        lastUpdate: DateTime.now(),
      );
    }
  }

  Future<void> _saveSensorStepsToDatabase() async {
    if (_userId == null || state.dailySummary == null) return;
    
    try {
      final sensorSteps = state.dailySummary!.sensorSteps;
      if (sensorSteps > 0) {
        await _supabaseService.addSteps(
          userId: _userId!,
          steps: sensorSteps,
          source: 'sensor',
          date: DateTime.now(),
        );
      }
    } catch (e) {
      // Silent fail for background save
      print('Failed to save sensor steps: $e');
    }
  }

  /// Request permissions for step counting
  Future<void> requestPermissions() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final granted = await PermissionService.requestAllStepCountingPermissions();
      
      if (granted) {
        state = state.copyWith(hasPermissions: true, error: null);
        await _startSensorListening();
        await _loadTodaysSteps();
      } else {
        state = state.copyWith(
          hasPermissions: false,
          error: 'Berechtigung wurde verweigert. Bitte in den Einstellungen erlauben.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        hasPermissions: false,
        error: 'Fehler bei Berechtigung: $e',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Add manual steps
  Future<void> addManualSteps(int steps) async {
    if (_userId == null || steps <= 0) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      // Save to database
      await _supabaseService.addSteps(
        userId: _userId!,
        steps: steps,
        source: 'manual',
        date: DateTime.now(),
      );
      
      // Update local state
      final currentSummary = state.dailySummary;
      if (currentSummary != null) {
        final updatedSummary = DailyStepSummary(
          date: currentSummary.date,
          totalSteps: currentSummary.totalSteps + steps,
          sensorSteps: currentSummary.sensorSteps,
          manualSteps: currentSummary.manualSteps + steps,
          goal: currentSummary.goal,
        );
        
        state = state.copyWith(
          dailySummary: updatedSummary,
          lastUpdate: DateTime.now(),
        );
      }
      
    } catch (e) {
      state = state.copyWith(error: 'Fehler beim Hinzufügen: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Update step goal
  Future<void> updateGoal(int newGoal) async {
    if (newGoal <= 0) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyStepGoal, newGoal);
      
      final currentSummary = state.dailySummary;
      if (currentSummary != null) {
        final updatedSummary = DailyStepSummary(
          date: currentSummary.date,
          totalSteps: currentSummary.totalSteps,
          sensorSteps: currentSummary.sensorSteps,
          manualSteps: currentSummary.manualSteps,
          goal: newGoal,
        );
        
        state = state.copyWith(dailySummary: updatedSummary);
      }
    } catch (e) {
      state = state.copyWith(error: 'Fehler beim Aktualisieren des Ziels: $e');
    }
  }

  /// Refresh data from database
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadTodaysSteps();
    state = state.copyWith(isLoading: false);
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    _saveTimer?.cancel();
    
    // Save final sensor data
    if (state.isListening && state.dailySummary?.sensorSteps != null) {
      _saveSensorStepsToDatabase();
    }
    
    super.dispose();
  }
}

/// Enhanced step provider with full functionality
final enhancedStepProvider = StateNotifierProvider<EnhancedStepNotifier, EnhancedStepState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final userId = ref.watch(profileProvider).profile?.id;
  return EnhancedStepNotifier(supabaseService, userId);
});

/// Simple provider for backward compatibility
final stepProvider = Provider<EnhancedStepState>((ref) {
  return ref.watch(enhancedStepProvider);
});