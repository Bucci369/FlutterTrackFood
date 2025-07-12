import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MacroGrid extends StatelessWidget {
  final Map<String, double> macros;

  const MacroGrid({
    super.key,
    required this.macros,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 160,
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
            const Text(
              'Nährstoffe',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildMacroItem(
                    'Protein',
                    '${macros['protein']?.toInt() ?? 0}g',
                    Colors.blue,
                    Icons.fitness_center,
                    0,
                  ),
                  _buildMacroItem(
                    'Carbs',
                    '${macros['carbs']?.toInt() ?? 0}g',
                    Colors.orange,
                    Icons.grain,
                    1,
                  ),
                  _buildMacroItem(
                    'Fett',
                    '${macros['fat']?.toInt() ?? 0}g',
                    Colors.pink,
                    Icons.opacity,
                    2,
                  ),
                  _buildMacroItem(
                    'Ballaststoffe',
                    '${macros['fiber']?.toInt() ?? 0}g',
                    Colors.green,
                    Icons.eco,
                    3,
                  ),
                  _buildMacroItem(
                    'Zucker',
                    '${macros['sugar']?.toInt() ?? 0}g',
                    Colors.purple,
                    Icons.cake,
                    4,
                  ),
                  _buildMacroItem(
                    'Natrium',
                    '${macros['sodium']?.toInt() ?? 0}mg',
                    Colors.yellow.shade700,
                    Icons.scatter_plot,
                    5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(
    String label,
    String value,
    Color color,
    IconData icon,
    int index,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    )
    .animate(delay: Duration(milliseconds: 100 * index))
    .fadeIn(duration: 400.ms)
    .scale(begin: const Offset(0.8, 0.8));
  }
}