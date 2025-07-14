import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trackfood/models/diary_entry.dart';
import 'package:trackfood/models/fasting_session.dart';
import 'package:trackfood/models/food_item.dart'; // Import FoodItem model
import 'package:trackfood/models/profile.dart';
import 'package:trackfood/models/water_intake.dart';
import 'package:trackfood/models/recipe.dart';
import 'package:trackfood/models/weight_history.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  // Getter for current user
  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => client.auth.currentUser?.id;

  // Get profile by userId
  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Profile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // === Fasting Sessions ===

  /// Fetches the latest active fasting session for the current user.
  Future<FastingSession?> getLatestFastingSession() async {
    if (currentUserId == null) return null;
    try {
      final response = await client
          .from('fasting_sessions')
          .select()
          .eq('user_id', currentUserId!)
          .eq('is_active', true)
          .order('start_time', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return FastingSession.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Starts a new fasting session.
  Future<FastingSession?> startFasting(
    String fastingTypeKey,
    String planName,
    Duration duration,
  ) async {
    if (currentUserId == null) return null;
    try {
      final response = await client
          .from('fasting_sessions')
          .insert({
            'user_id': currentUserId!,
            'plan': planName,
            'fasting_type': fastingTypeKey,
            'target_duration_hours': duration.inHours,
            'start_time': DateTime.now()
                .toUtc()
                .toIso8601String(), // Save as UTC
            'is_active': true,
            'status': 'active',
          })
          .select()
          .single();

      return FastingSession.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Stops (completes) a fasting session.
  Future<void> stopFasting(String sessionId) async {
    try {
      await client
          .from('fasting_sessions')
          .update({
            'end_time': DateTime.now().toIso8601String(),
            'is_active': false,
            'status': 'completed',
          })
          .eq('id', sessionId);
    } catch (e) {
      // Handle error silently
    }
  }

  // === Diary Entries (Meals) ===

  /// Fetches the most recent meals for the current user for today.
  Future<List<DiaryEntry>> getRecentMeals({int limit = 3}) async {
    if (currentUserId == null) return [];
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(
        today.year,
        today.month,
        today.day,
      ).toIso8601String();

      final response = await client
          .from('diary_entries')
          .select()
          .eq('user_id', currentUserId!)
          .gte('entry_date', startOfDay)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => DiaryEntry.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetches all diary entries for the current user for a specific date.
  Future<List<DiaryEntry>> getEntriesForDate(DateTime date) async {
    if (currentUserId == null) return [];
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await client
          .from('diary_entries')
          .select()
          .eq('user_id', currentUserId!)
          .gte('created_at', '${dateStr}T00:00:00Z')
          .lt('created_at', '${dateStr}T23:59:59Z')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DiaryEntry.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Add a new diary entry
  Future<void> addDiaryEntry({
    required String userId,
    required String mealType,
    required String foodName,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double quantity,
    String? productCode,
    double fiber = 0.0,
    double sugar = 0.0,
    double sodium = 0.0,
  }) async {
    final newEntry = {
      'user_id': userId,
      'meal_type': mealType,
      'food_name': foodName,
      'calories': calories,
      'protein_g': protein,
      'carb_g': carbs,
      'fat_g': fat,
      'fiber_g': fiber,
      'sugar_g': sugar,
      'sodium_mg': sodium,
      'quantity': quantity,
      'unit': 'g', // Assuming grams for now
      'entry_date': DateTime.now().toIso8601String(),
      'product_code': productCode,
    };

    try {
      await client.from('diary_entries').insert(newEntry);
    } on PostgrestException catch (e) {
      // Handle potential database errors gracefully
      throw Exception('Failed to add diary entry: ${e.message}');
    } catch (e) {
      // Handle other generic errors
      throw Exception(
        'An unexpected error occurred while adding a diary entry.',
      );
    }
  }

  // Delete a diary entry
  Future<void> deleteDiaryEntry(String entryId) async {
    final response = await client
        .from('diary_entries')
        .delete()
        .eq('id', entryId);

    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }

  // === Activities ===

  /// Fetches all activities for the current user for a specific date.
  Future<List<Map<String, dynamic>>> getActivitiesForDate(DateTime date) async {
    if (currentUserId == null) return [];
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await client
          .from('user_activities')
          .select('*') // Select all columns for now
          .eq('user_id', currentUserId!)
          .gte('activity_date', '${dateStr}T00:00:00Z')
          .lt('activity_date', '${dateStr}T23:59:59Z')
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // === Water Intake ===

  /// Fetches or creates water intake for a specific date.
  Future<WaterIntake> getWaterIntakeForDate(
    String userId,
    DateTime date,
  ) async {
    final dateStr = date.toIso8601String().split('T')[0];

    try {
      final data = await client
          .from('water_intake') // Corrected table name
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .maybeSingle();

      if (data != null) {
        return WaterIntake.fromJson(data);
      } else {
        // No entry for today, create one
        final newIntake = {
          'user_id': userId,
          'date': dateStr,
          'amount_ml': 0,
          'daily_goal_ml': 3000, // Default goal
        };
        final createResponse = await client
            .from('water_intake') // Corrected table name
            .insert(newIntake)
            .select()
            .single();

        return WaterIntake.fromJson(createResponse);
      }
    } on PostgrestException catch (e) {
      // Handle specific Postgrest errors if needed
      throw Exception('Failed to get or create water intake: ${e.message}');
    } catch (e) {
      // Handle other generic errors
      throw Exception('An unexpected error occurred.');
    }
  }

  /// Adds a specific amount of water to the intake for a given ID.
  Future<WaterIntake> addWater(String intakeId, int amountToAdd) async {
    try {
      // 1. Fetch the current amount of water
      final currentIntakeData = await client
          .from('water_intake')
          .select('amount_ml')
          .eq('id', intakeId)
          .single();

      final currentAmount = currentIntakeData['amount_ml'] as int;
      final newAmount = currentAmount + amountToAdd;

      // 2. Update the record with the new amount
      final updatedData = await client
          .from('water_intake')
          .update({'amount_ml': newAmount})
          .eq('id', intakeId)
          .select()
          .single();

      // 3. Return the updated water intake object
      return WaterIntake.fromJson(updatedData);
    } on PostgrestException catch (e) {
      throw Exception('Failed to add water: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred while adding water.');
    }
  }

  // === Product Search ===

  /// Searches for products in the local Supabase DB using a more sophisticated search logic.
  Future<List<FoodItem>> searchProducts(String query) async {
    if (query.trim().length < 3) return [];
    try {
      // Split the query into words and create a search pattern for each word
      final searchTerms = query
          .split(' ')
          .where((s) => s.isNotEmpty)
          .map((s) => '%$s%')
          .toList();

      var request = client.from('products').select();

      // Chain `ilike` filters for each search term
      for (final term in searchTerms) {
        request = request.ilike('name', term);
      }

      final response = await request;

      return (response as List).map((json) => FoodItem.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // === Profile with Image ===

  /// Updates profile with image URL
  Future<void> updateProfileImage(String userId, String imageUrl) async {
    try {
      await client
          .from('profiles')
          .update({'image_url': imageUrl})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile image');
    }
  }

  /// Gets profile image URL
  Future<String?> getProfileImageUrl(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select('image_url')
          .eq('id', userId)
          .single();
      return response['image_url'] as String?;
    } catch (e) {
      return null;
    }
  }

  // === Step Counter ===

  /// Fetches the total steps for a specific date.
  Future<int> getStepsForDate(String userId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await client
          .from('user_steps')
          .select('steps')
          .eq('user_id', userId)
          .eq('date', dateStr);

      if (response.isEmpty) {
        return 0;
      }

      // Sum up all entries for the day (sensor + manual)
      int totalSteps = 0;
      for (var record in response) {
        totalSteps += (record['steps'] as int?) ?? 0;
      }
      return totalSteps;
    } catch (e) {
      return 0;
    }
  }

  /// Adds a step entry (either from sensor or manual input).
  Future<void> addSteps({
    required String userId,
    required int steps,
    required String source,
    required DateTime date,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      await client.from('user_steps').insert({
        'user_id': userId,
        'date': dateStr,
        'steps': steps,
        'source': source,
      });
    } catch (e) {
      throw Exception('Failed to add steps: $e');
    }
  }

  // === Historical Data ===
  
  Future<List<DiaryEntry>> getDiaryEntriesForDateRange(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final response = await client
          .from('diary_entries')
          .select()
          .eq('user_id', userId)
          .gte('entry_date', startDate.toIso8601String())
          .lte('entry_date', endDate.toIso8601String())
          .order('entry_date', ascending: true);
      
      return (response as List)
          .map((json) => DiaryEntry.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<List<WeightHistory>> getWeightHistoryForDateRange(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final response = await client
          .from('weight_history')
          .select()
          .eq('user_id', userId)
          .gte('recorded_date', startDate.toIso8601String())
          .lte('recorded_date', endDate.toIso8601String())
          .order('recorded_date', ascending: true);
      
      return (response as List)
          .map((json) => WeightHistory.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getUserActivitiesForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate
  ) async {
    try {
      final response = await client
          .from('user_activities')
          .select('activity_date, calories')
          .eq('user_id', userId)
          .gte('activity_date', startDate.toIso8601String())
          .lte('activity_date', endDate.toIso8601String())
          .order('activity_date', ascending: true);
      
      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // === Recipes ===

  Future<List<Recipe>> getRecipes({
    int limit = 20,
    int offset = 0,
    String? query,
    String? category,
  }) async {
    try {
      var request = client.from('recipes').select();

      if (query != null && query.isNotEmpty) {
        request = request.ilike('title', '%$query%');
      }
      if (category != null && category.isNotEmpty) {
        request = request.eq('category', category);
      }

      final response = await request
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return (response as List).map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecipeCategories() async {
    try {
      // Fetch ALL categories using batching like the webapp does
      final List<Map<String, dynamic>> allCategories = [];
      int from = 0;
      const int batchSize = 1000;
      
      while (true) {
        final response = await client
            .from('recipes')
            .select('category')
            .not('category', 'is', null)
            .range(from, from + batchSize - 1);
            
        if (response.isEmpty) break;
        
        allCategories.addAll(response);
        
        if (response.length < batchSize) break;
        from += batchSize;
      }

      // Count categories on client side like the webapp does
      final Map<String, int> categoryCounts = {};
      for (final row in allCategories) {
        final category = row['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
        }
      }

      // Convert to list and sort by count (descending)
      final categories = categoryCounts.entries
          .map((entry) => {
                'category': entry.key,
                'count': entry.value,
              })
          .toList();

      // Sort by count descending, like the webapp
      categories.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      return categories;
    } catch (e) {
      return [];
    }
  }
}

/// Provider to make the SupabaseService instance available to the rest of the app.
final supabaseServiceProvider = Provider((ref) => SupabaseService());
