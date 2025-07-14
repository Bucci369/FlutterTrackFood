import '../models/diary_entry.dart';
import '../models/user_activity.dart';
import '../models/water_intake.dart';
import 'supabase_service.dart';

class NutritionContextService {
  final SupabaseService _supabaseService = SupabaseService();

  Future<String> generateNutritionContext(String userId, {int days = 7}) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      // Fetch comprehensive user data
      final profile = await _fetchUserProfile(userId);
      final diaryEntries = await _fetchDiaryEntries(userId, startDate, endDate);
      final activities = await _fetchUserActivities(userId, startDate, endDate);
      final waterIntakes = await _fetchWaterIntakes(userId, startDate, endDate);
      final fastingSessions =
          await _fetchFastingSessions(userId, startDate, endDate);
      final weightHistory =
          await _fetchWeightHistory(userId, startDate, endDate);

      // Generate comprehensive context string
      return _buildAdvancedNutritionContext(profile, diaryEntries, activities,
          waterIntakes, fastingSessions, weightHistory, days);
    } catch (e) {
      return 'Ernährungsdaten konnten nicht geladen werden: $e';
    }
  }

  Future<List<DiaryEntry>> _fetchDiaryEntries(
      String userId, DateTime start, DateTime end) async {
    try {
      final response = await _supabaseService.client
          .from('diary_entries')
          .select()
          .eq('user_id', userId)
          .gte('entry_date', start.toIso8601String().split('T')[0])
          .lte('entry_date', end.toIso8601String().split('T')[0])
          .order('entry_date', ascending: false);

      return (response as List<dynamic>)
          .map((json) => DiaryEntry.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<UserActivity>> _fetchUserActivities(
      String userId, DateTime start, DateTime end) async {
    try {
      final response = await _supabaseService.client
          .from('user_activities')
          .select()
          .eq('user_id', userId)
          .gte('activity_date', start.toIso8601String().split('T')[0])
          .lte('activity_date', end.toIso8601String().split('T')[0])
          .order('activity_date', ascending: false);

      return (response as List<dynamic>)
          .map((json) => UserActivity.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<WaterIntake>> _fetchWaterIntakes(
      String userId, DateTime start, DateTime end) async {
    try {
      final response = await _supabaseService.client
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .gte('date', start.toIso8601String().split('T')[0])
          .lte('date', end.toIso8601String().split('T')[0])
          .order('date', ascending: false);

      return (response as List<dynamic>)
          .map((json) => WaterIntake.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> _fetchUserProfile(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFastingSessions(
      String userId, DateTime start, DateTime end) async {
    try {
      final response = await _supabaseService.client
          .from('fasting_sessions')
          .select()
          .eq('user_id', userId)
          .gte('start_time', start.toIso8601String())
          .lte('start_time', end.toIso8601String())
          .order('start_time', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchWeightHistory(
      String userId, DateTime start, DateTime end) async {
    try {
      final response = await _supabaseService.client
          .from('weight_history')
          .select()
          .eq('user_id', userId)
          .gte('recorded_date', start.toIso8601String().split('T')[0])
          .lte('recorded_date', end.toIso8601String().split('T')[0])
          .order('recorded_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  String _buildAdvancedNutritionContext(
    Map<String, dynamic>? profile,
    List<DiaryEntry> diaryEntries,
    List<UserActivity> activities,
    List<WaterIntake> waterIntakes,
    List<Map<String, dynamic>> fastingSessions,
    List<Map<String, dynamic>> weightHistory,
    int days,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('🧑‍⚕️ VOLLSTÄNDIGE NUTZERDATEN-ANALYSE ($days Tage):');
    buffer.writeln('=' * 50);

    // User Profile Analysis
    if (profile != null) {
      buffer.writeln('👤 BENUTZERPROFIL:');
      buffer.writeln('- Alter: ${profile['age'] ?? 'nicht angegeben'} Jahre');
      buffer.writeln('- Geschlecht: ${profile['gender'] ?? 'nicht angegeben'}');
      buffer
          .writeln('- Größe: ${profile['height_cm'] ?? 'nicht angegeben'} cm');
      buffer.writeln(
          '- Aktuelles Gewicht: ${profile['weight_kg'] ?? 'nicht angegeben'} kg');
      buffer.writeln(
          '- Zielgewicht: ${profile['target_weight_kg'] ?? 'nicht angegeben'} kg');
      buffer.writeln(
          '- Aktivitätslevel: ${profile['activity_level'] ?? 'nicht angegeben'}');
      buffer.writeln('- Hauptziel: ${profile['goal'] ?? 'nicht angegeben'}');

      final goals = profile['goals'] as List<dynamic>?;
      if (goals != null && goals.isNotEmpty) {
        buffer.writeln('- Spezifische Ziele: ${goals.join(', ')}');
      }

      buffer.writeln(
          '- Diät-Typ: ${profile['diet_type'] ?? 'keine Einschränkungen'}');
      buffer.writeln(
          '- Unverträglichkeiten: ${profile['intolerances'] ?? 'keine bekannten'}');
      buffer.writeln(
          '- Glutenfrei: ${profile['is_glutenfree'] == true ? 'Ja' : 'Nein'}');

      // Calculate BMI if possible
      if (profile['height_cm'] != null && profile['weight_kg'] != null) {
        final height = profile['height_cm'] / 100.0;
        final weight = profile['weight_kg'];
        final bmi = weight / (height * height);
        buffer.writeln(
            '- BMI: ${bmi.toStringAsFixed(1)} (${_getBMICategory(bmi)})');
      }
      buffer.writeln();
    }

    // Weight Progress Analysis
    if (weightHistory.isNotEmpty) {
      buffer.writeln('⚖️ GEWICHTSVERLAUF:');
      final weightTrend = _analyzeWeightTrend(weightHistory);
      buffer.writeln('- Messungen: ${weightHistory.length}');
      buffer.writeln('- Trend: ${weightTrend['trend']}');
      buffer.writeln('- Veränderung: ${weightTrend['change']}');
      buffer.writeln();
    }

    // Advanced Nutrition Analysis
    final nutritionSummary = _calculateNutritionSummary(diaryEntries, days);
    buffer.writeln('🍽️ ERWEITERTE MAKRONÄHRSTOFF-ANALYSE:');
    buffer.writeln(
        '- Gesamtkalorien: ${nutritionSummary['totalCalories']?.toInt() ?? 0} kcal (⌀ ${nutritionSummary['avgCaloriesPerDay']?.toInt() ?? 0} kcal/Tag)');

    // Calculate daily calorie needs
    if (profile != null) {
      final dailyNeeds = _calculateDailyCalorieNeeds(profile);
      final calorieBalance =
          (nutritionSummary['avgCaloriesPerDay'] ?? 0) - dailyNeeds;
      buffer.writeln('- Geschätzter Bedarf: ${dailyNeeds.toInt()} kcal/Tag');
      buffer.writeln(
          '- Kalorien-Bilanz: ${calorieBalance > 0 ? '+' : ''}${calorieBalance.toInt()} kcal/Tag (${calorieBalance > 0 ? 'Überschuss' : 'Defizit'})');
    }

    buffer.writeln(
        '- Protein: ${nutritionSummary['totalProtein']?.toStringAsFixed(1) ?? '0.0'}g (${nutritionSummary['proteinPercent']?.toStringAsFixed(1) ?? '0.0'}% der Kalorien)');
    buffer.writeln(
        '- Kohlenhydrate: ${nutritionSummary['totalCarbs']?.toStringAsFixed(1) ?? '0.0'}g (${nutritionSummary['carbPercent']?.toStringAsFixed(1) ?? '0.0'}% der Kalorien)');
    buffer.writeln(
        '- Fett: ${nutritionSummary['totalFat']?.toStringAsFixed(1) ?? '0.0'}g (${nutritionSummary['fatPercent']?.toStringAsFixed(1) ?? '0.0'}% der Kalorien)');
    buffer.writeln(
        '- Ballaststoffe: ${nutritionSummary['totalFiber']?.toStringAsFixed(1) ?? '0.0'}g (⌀ ${nutritionSummary['avgFiberPerDay']?.toStringAsFixed(1) ?? '0.0'}g/Tag)');
    buffer.writeln(
        '- Zucker: ${nutritionSummary['totalSugar']?.toStringAsFixed(1) ?? '0.0'}g (⌀ ${nutritionSummary['avgSugarPerDay']?.toStringAsFixed(1) ?? '0.0'}g/Tag)');
    buffer.writeln();

    // Meal Timing and Patterns
    final mealTimings = _analyzeMealTimings(diaryEntries);
    final mealPatterns = _analyzeMealPatterns(diaryEntries);
    buffer.writeln('🕐 MAHLZEITEN-TIMING & MUSTER:');
    mealPatterns.forEach((mealType, data) {
      buffer.writeln(
          '- $mealType: ${data['count']} Einträge, ⌀ ${data['avgCalories']?.toInt() ?? 0} kcal');
    });

    if (mealTimings.isNotEmpty) {
      buffer.writeln(
          '- Essens-Zeitfenster: ${mealTimings['firstMeal']} bis ${mealTimings['lastMeal']}');
      buffer.writeln('- Eating Window: ${mealTimings['eatingWindow']} Stunden');
    }
    buffer.writeln();

    // Behavioral Patterns
    final behaviorPatterns = _analyzeBehaviorPatterns(diaryEntries, activities);
    buffer.writeln('🧠 VERHALTENS-MUSTER:');
    for (var pattern in behaviorPatterns) {
      buffer.writeln('- $pattern');
    }
    buffer.writeln();

    // Fasting Analysis
    if (fastingSessions.isNotEmpty) {
      final fastingAnalysis = _analyzeFastingSessions(fastingSessions);
      buffer.writeln('⏰ FASTEN-ANALYSE:');
      buffer.writeln('- Fasten-Sessions: ${fastingSessions.length}');
      buffer.writeln(
          '- Durchschnittliche Dauer: ${fastingAnalysis['avgDuration']} Stunden');
      buffer.writeln('- Häufigster Typ: ${fastingAnalysis['mostCommonType']}');
      buffer.writeln('- Erfolgsrate: ${fastingAnalysis['successRate']}%');
      buffer.writeln();
    }

    // Activity Integration
    if (activities.isNotEmpty) {
      final activityAnalysis =
          _calculateAdvancedActivitySummary(activities, nutritionSummary);
      buffer.writeln('💪 FITNESS & TRAININGS-INTEGRATION:');
      buffer.writeln('- Trainings-Sessions: ${activities.length}');
      buffer.writeln(
          '- Verbrannte Kalorien: ${activityAnalysis['totalCaloriesBurned']?.toInt() ?? 0} kcal');
      buffer.writeln(
          '- Training-Nutrition Ratio: ${activityAnalysis['trainingNutritionRatio']}');
      buffer.writeln('- Aktivste Zeiten: ${activityAnalysis['peakTimes']}');
      buffer.writeln('- Recovery-Bedarf: ${activityAnalysis['recoveryNeeds']}');
      buffer.writeln();
    }

    // Hydration Analysis
    if (waterIntakes.isNotEmpty) {
      final hydrationAnalysis = _analyzeHydrationPatterns(waterIntakes);
      buffer.writeln('💧 HYDRATION-ANALYSE:');
      buffer.writeln(
          '- Durchschnittliche Aufnahme: ${hydrationAnalysis['avgDaily']}ml/Tag');
      buffer
          .writeln('- Zielerfüllung: ${hydrationAnalysis['goalAchievement']}%');
      buffer.writeln('- Hydration-Timing: ${hydrationAnalysis['timing']}');
      buffer.writeln();
    }

    // Food Quality Assessment
    final foodQuality = _assessFoodQuality(diaryEntries);
    buffer.writeln('🥗 LEBENSMITTEL-QUALITÄT:');
    buffer.writeln('- Verarbeitungsgrad: ${foodQuality['processingLevel']}');
    buffer.writeln('- Nährstoffdichte: ${foodQuality['nutrientDensity']}');
    buffer.writeln('- Vielfalt Score: ${foodQuality['varietyScore']}/10');
    buffer.writeln();

    // Advanced Health Insights
    final advancedInsights = _generateAdvancedHealthInsights(
        profile, nutritionSummary, mealPatterns, behaviorPatterns, days);
    if (advancedInsights.isNotEmpty) {
      buffer.writeln('🔬 ERWEITERTE GESUNDHEITS-INSIGHTS:');
      for (var insight in advancedInsights) {
        buffer.writeln('- $insight');
      }
      buffer.writeln();
    }

    // Optimization Opportunities
    final optimizations = _identifyOptimizationOpportunities(
        profile, nutritionSummary, mealPatterns, activities);
    buffer.writeln('🎯 OPTIMIERUNGS-MÖGLICHKEITEN:');
    for (var optimization in optimizations) {
      buffer.writeln('- $optimization');
    }

    return buffer.toString();
  }

  Map<String, double> _calculateNutritionSummary(
      List<DiaryEntry> entries, int days) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;
    double totalSugar = 0;

    for (final entry in entries) {
      totalCalories += entry.calories;
      totalProtein += entry.proteinG;
      totalCarbs += entry.carbG;
      totalFat += entry.fatG;
      totalFiber += entry.fiberG;
      totalSugar += entry.sugarG;
    }

    final proteinCalories = totalProtein * 4;
    final carbCalories = totalCarbs * 4;
    final fatCalories = totalFat * 9;

    return {
      'totalCalories': totalCalories,
      'avgCaloriesPerDay': totalCalories / days,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'totalFiber': totalFiber,
      'totalSugar': totalSugar,
      'avgFiberPerDay': totalFiber / days,
      'avgSugarPerDay': totalSugar / days,
      'proteinPercent':
          totalCalories > 0 ? (proteinCalories / totalCalories) * 100 : 0,
      'carbPercent':
          totalCalories > 0 ? (carbCalories / totalCalories) * 100 : 0,
      'fatPercent': totalCalories > 0 ? (fatCalories / totalCalories) * 100 : 0,
    };
  }

  Map<String, Map<String, dynamic>> _analyzeMealPatterns(
      List<DiaryEntry> entries) {
    final patterns = <String, Map<String, dynamic>>{};

    for (final entry in entries) {
      final mealType = entry.mealType.toString();
      if (!patterns.containsKey(mealType)) {
        patterns[mealType] = {'count': 0, 'totalCalories': 0.0};
      }
      patterns[mealType]!['count']++;
      patterns[mealType]!['totalCalories'] += entry.calories;
    }

    patterns.forEach((key, value) {
      value['avgCalories'] = value['totalCalories'] / value['count'];
    });

    return patterns;
  }





  // Advanced Analysis Helper Methods
  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Untergewicht';
    if (bmi < 25) return 'Normalgewicht';
    if (bmi < 30) return 'Übergewicht';
    return 'Adipositas';
  }

  double _calculateDailyCalorieNeeds(Map<String, dynamic> profile) {
    final age = profile['age'] ?? 25;
    final gender = profile['gender'] ?? 'male';
    final weight = profile['weight_kg'] ?? 70.0;
    final height = profile['height_cm'] ?? 170.0;
    final activityLevel = profile['activity_level'] ?? 'moderate';

    // Harris-Benedict Formula
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    // Activity multipliers
    final activityMultipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };

    return bmr * (activityMultipliers[activityLevel] ?? 1.55);
  }

  Map<String, dynamic> _analyzeWeightTrend(
      List<Map<String, dynamic>> weightHistory) {
    if (weightHistory.length < 2) {
      return {'trend': 'Unzureichende Daten', 'change': 'N/A'};
    }

    final sorted = weightHistory
      ..sort((a, b) => DateTime.parse(a['recorded_date'])
          .compareTo(DateTime.parse(b['recorded_date'])));

    final firstWeight = sorted.first['weight_kg'];
    final lastWeight = sorted.last['weight_kg'];
    final change = lastWeight - firstWeight;

    String trend;
    if (change > 0.5) {
      trend = 'Gewichtszunahme';
    } else if (change < -0.5) {
      trend = 'Gewichtsverlust';
    } else {
      trend = 'Stabil';
    }

    return {
      'trend': trend,
      'change': '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} kg'
    };
  }

  Map<String, dynamic> _analyzeMealTimings(List<DiaryEntry> entries) {
    if (entries.isEmpty) return {};

    final times = entries
        .map((e) => e.createdAt.hour + e.createdAt.minute / 60.0)
        .toList();
    times.sort();

    return {
      'firstMeal':
          '${times.first.toInt()}:${((times.first % 1) * 60).toInt().toString().padLeft(2, '0')}',
      'lastMeal':
          '${times.last.toInt()}:${((times.last % 1) * 60).toInt().toString().padLeft(2, '0')}',
      'eatingWindow': (times.last - times.first).toStringAsFixed(1),
    };
  }

  List<String> _analyzeBehaviorPatterns(
      List<DiaryEntry> entries, List<UserActivity> activities) {
    final patterns = <String>[];

    // Weekend vs Weekday patterns
    final weekendEntries =
        entries.where((e) => e.entryDate.weekday >= 6).length;
    final weekdayEntries = entries.where((e) => e.entryDate.weekday < 6).length;

    if (weekendEntries > 0 && weekdayEntries > 0) {
      final weekendAvgCalories = entries
              .where((e) => e.entryDate.weekday >= 6)
              .map((e) => e.calories)
              .reduce((a, b) => a + b) /
          weekendEntries;
      final weekdayAvgCalories = entries
              .where((e) => e.entryDate.weekday < 6)
              .map((e) => e.calories)
              .reduce((a, b) => a + b) /
          weekdayEntries;

      if ((weekendAvgCalories - weekdayAvgCalories).abs() > 200) {
        patterns
            .add('Unterschiedliche Essgewohnheiten: Wochenende vs. Wochentage');
      }
    }

    // Activity correlation
    if (activities.isNotEmpty) {
      patterns.add(
          'Trainingstage: ${activities.length} von ${entries.map((e) => e.entryDate).toSet().length} Tagen');
    }

    // Meal frequency
    final daysWithData = entries
        .map((e) => e.entryDate.toIso8601String().split('T')[0])
        .toSet()
        .length;
    if (daysWithData > 0) {
      final avgMealsPerDay = entries.length / daysWithData;
      if (avgMealsPerDay < 3) {
        patterns.add(
            'Wenige Mahlzeiten pro Tag (⌀ ${avgMealsPerDay.toStringAsFixed(1)})');
      } else if (avgMealsPerDay > 5) {
        patterns.add(
            'Häufige kleine Mahlzeiten (⌀ ${avgMealsPerDay.toStringAsFixed(1)})');
      }
    }

    return patterns;
  }

  Map<String, dynamic> _analyzeFastingSessions(
      List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) return {};

    final durations = sessions.map((s) {
      final start = DateTime.parse(s['start_time']);
      final end = s['end_time'] != null
          ? DateTime.parse(s['end_time'])
          : DateTime.now();
      return end.difference(start).inHours;
    }).toList();

    final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
    final successfulSessions =
        sessions.where((s) => s['status'] == 'completed').length;
    final successRate = (successfulSessions / sessions.length * 100).round();

    final types =
        sessions.map((s) => s['fasting_type'] ?? 'intermittent').toList();
    final mostCommonType = types.isNotEmpty ? types.first : 'intermittent';

    return {
      'avgDuration': avgDuration.round(),
      'successRate': successRate,
      'mostCommonType': mostCommonType,
    };
  }

  Map<String, dynamic> _calculateAdvancedActivitySummary(
      List<UserActivity> activities, Map<String, double> nutritionSummary) {
    double totalCaloriesBurned = 0;
    final times = <int>[];

    for (final activity in activities) {
      totalCaloriesBurned += activity.calories;
      times.add(activity.activityDate.hour);
    }

    final avgCaloriesConsumed = nutritionSummary['avgCaloriesPerDay'] ?? 0;
    final trainingNutritionRatio = totalCaloriesBurned > 0
        ? (avgCaloriesConsumed / (totalCaloriesBurned / activities.length))
            .toStringAsFixed(1)
        : 'N/A';

    final peakHour = times.isNotEmpty
        ? times
            .fold<Map<int, int>>({}, (map, hour) {
              map[hour] = (map[hour] ?? 0) + 1;
              return map;
            })
            .entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key
        : 0;

    return {
      'totalCaloriesBurned': totalCaloriesBurned,
      'trainingNutritionRatio': trainingNutritionRatio,
      'peakTimes': '$peakHour:00 Uhr',
      'recoveryNeeds': totalCaloriesBurned > 500 ? 'Hoch' : 'Moderat',
    };
  }

  Map<String, dynamic> _analyzeHydrationPatterns(
      List<WaterIntake> waterIntakes) {
    final totalWater =
        waterIntakes.fold<int>(0, (sum, intake) => sum + intake.amountMl);
    final uniqueDays = waterIntakes
        .map((w) => w.date.toIso8601String().split('T')[0])
        .toSet()
        .length;
    final avgDaily = uniqueDays > 0 ? (totalWater / uniqueDays).round() : 0;

    final goalAchievement = waterIntakes.isNotEmpty
        ? ((waterIntakes.where((w) => w.amountMl >= w.dailyGoalMl).length /
                    waterIntakes.length) *
                100)
            .round()
        : 0;

    return {
      'avgDaily': avgDaily,
      'goalAchievement': goalAchievement,
      'timing': 'Gleichmäßig über den Tag verteilt', // Simplified for now
    };
  }

  Map<String, dynamic> _assessFoodQuality(List<DiaryEntry> entries) {
    // Simplified food quality assessment
    final processedFoods = entries
        .where((e) =>
            e.foodName.toLowerCase().contains('fertig') ||
            e.foodName.toLowerCase().contains('instant') ||
            e.foodName.toLowerCase().contains('dose'))
        .length;

    final processingLevel =
        processedFoods / entries.length > 0.3 ? 'Hoch' : 'Niedrig';

    final uniqueFoods = entries.map((e) => e.foodName).toSet().length;
    final varietyScore =
        (uniqueFoods / entries.length * 10).clamp(0, 10).round();

    return {
      'processingLevel': processingLevel,
      'nutrientDensity': 'Moderat', // Would need more detailed food data
      'varietyScore': varietyScore,
    };
  }

  List<String> _generateAdvancedHealthInsights(
      Map<String, dynamic>? profile,
      Map<String, double> nutritionSummary,
      Map<String, Map<String, dynamic>> mealPatterns,
      List<String> behaviorPatterns,
      int days) {
    final insights = <String>[];

    // Metabolic insights
    final proteinPercent = nutritionSummary['proteinPercent'] ?? 0;
    if (proteinPercent < 15) {
      insights.add(
          'Niedriger Proteinanteil kann Muskelerhaltung und Sättigung beeinträchtigen');
    }

    // Meal timing insights
    if (mealPatterns.containsKey('snack') &&
        mealPatterns['snack']!['count'] > days * 2) {
      insights.add('Häufiges Snacken könnte Insulinresistenz fördern');
    }

    // Behavior-based insights
    if (behaviorPatterns.any((p) => p.contains('Wochenende'))) {
      insights.add(
          'Inkonsistente Wochenend-Ernährung kann Fortschritt verlangsamen');
    }

    return insights;
  }

  List<String> _identifyOptimizationOpportunities(
      Map<String, dynamic>? profile,
      Map<String, double> nutritionSummary,
      Map<String, Map<String, dynamic>> mealPatterns,
      List<UserActivity> activities) {
    final optimizations = <String>[];

    // Macro optimization
    final proteinPercent = nutritionSummary['proteinPercent'] ?? 0;
    if (proteinPercent < 20 && activities.isNotEmpty) {
      optimizations
          .add('Protein erhöhen für bessere Regeneration nach dem Training');
    }

    // Meal timing optimization
    if (activities.isNotEmpty && !mealPatterns.containsKey('post_workout')) {
      optimizations
          .add('Post-Workout Nutrition implementieren für optimale Recovery');
    }

    // Hydration optimization
    if (nutritionSummary['avgCaloriesPerDay'] != null &&
        nutritionSummary['avgCaloriesPerDay']! > 2000) {
      optimizations.add(
          'Wasseraufnahme überprüfen - könnte bei höherer Kalorienzufuhr unzureichend sein');
    }

    return optimizations;
  }
}
