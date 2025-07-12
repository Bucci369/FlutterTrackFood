import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RecentMeals extends StatelessWidget {
  const RecentMeals({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - would come from Supabase diary_entries table
    final meals = [
      {
        'name': 'Haferflocken mit Beeren',
        'calories': 320,
        'time': '08:30',
        'type': 'Frühstück',
        'emoji': '🥣',
      },
      {
        'name': 'Gegrilltes Hähnchen mit Gemüse',
        'calories': 485,
        'time': '12:45',
        'type': 'Mittagessen',
        'emoji': '🍗',
      },
      {
        'name': 'Griechischer Joghurt',
        'calories': 150,
        'time': '15:20',
        'type': 'Snack',
        'emoji': '🥛',
      },
    ];

    return GlassmorphicContainer(
      width: double.infinity,
      height: 200,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mahlzeiten',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to diary screen
                  },
                  child: Text(
                    'Tagebuch öffnen',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: meals.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: meals.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final meal = meals[index];
                        return _buildMealItem(meal, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(Map<String, dynamic> meal, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                meal['emoji'],
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${meal['type']} • ${meal['calories']} kcal',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            meal['time'],
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    )
    .animate(delay: Duration(milliseconds: 100 * index))
    .fadeIn(duration: 400.ms)
    .slideX(begin: 0.3, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.restaurant,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Noch keine Mahlzeiten',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Füge deine erste Mahlzeit hinzu!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}