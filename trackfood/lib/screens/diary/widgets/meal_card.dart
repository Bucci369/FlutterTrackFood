import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/diary_entry.dart';
import '../../../models/meal_type.dart';

class MealCard extends StatelessWidget {
  final MealType mealType;
  final List<DiaryEntry> entries;
  final int recommendedCalories;
  final VoidCallback onEntryAdded;

  const MealCard({
    super.key,
    required this.mealType,
    required this.entries,
    required this.recommendedCalories,
    required this.onEntryAdded,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = entries.fold<double>(0, (sum, entry) => sum + entry.calories);
    final progress = totalCalories / recommendedCalories;
    
    return GlassmorphicContainer(
      width: double.infinity,
      height: entries.isEmpty ? 140 : 140 + (entries.length * 50.0),
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          mealType.gradientColors[0].withValues(alpha: 0.3),
          mealType.gradientColors[1].withValues(alpha: 0.1),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          mealType.gradientColors[0].withValues(alpha: 0.4),
          mealType.gradientColors[1].withValues(alpha: 0.2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: mealType.gradientColors,
                    ),
                  ),
                  child: Icon(
                    mealType.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalCalories.toInt()} / $recommendedCalories kcal',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Add button
                GestureDetector(
                  onTap: () => _addFood(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress bar
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 1.0 ? Colors.orange : Colors.white,
              ),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
            
            const SizedBox(height: 16),
            
            // Food entries
            if (entries.isEmpty)
              _buildEmptyState()
            else
              ...entries.take(3).map((entry) => _buildFoodEntry(entry)).toList(),
              
            // Show more indicator
            if (entries.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${entries.length - 3} weitere Einträge',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 50,
      child: Center(
        child: Text(
          'Noch keine Einträge für ${mealType.displayName.toLowerCase()}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildFoodEntry(DiaryEntry entry) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.foodName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${entry.quantity.toInt()}${entry.unit}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.calories.toInt()} kcal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 300.ms)
    .slideX(begin: 0.3, end: 0);
  }

  void _addFood(BuildContext context) {
    // TODO: Navigate to food selection screen
    // Navigator.of(context).pushNamed('/diary/add', arguments: mealType);
    
    // For now, show a placeholder dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${mealType.displayName} hinzufügen'),
        content: const Text('Food-Auswahl wird in der nächsten Version implementiert.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}