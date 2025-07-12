import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class DateNavigator extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DateNavigator({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final canGoNext = selectedDate.isBefore(DateTime(today.year, today.month, today.day));
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 80,
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous day button
              IconButton(
                onPressed: () {
                  final previousDay = selectedDate.subtract(const Duration(days: 1));
                  onDateChanged(previousDay);
                },
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              
              // Date display
              Expanded(
                child: GestureDetector(
                  onTap: () => _showDatePicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatDate(selectedDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getDateLabel(selectedDate),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Next day button
              IconButton(
                onPressed: canGoNext ? () {
                  final nextDay = selectedDate.add(const Duration(days: 1));
                  onDateChanged(nextDay);
                } : null,
                icon: Icon(
                  Icons.chevron_right,
                  color: canGoNext ? Colors.white : Colors.white.withValues(alpha: 0.3),
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    final months = ['Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'];
    
    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];
    
    return '$weekday, $day. $month';
  }

  String _getDateLabel(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Heute';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Gestern';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Morgen';
    }
    
    return '${date.year}';
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(today.year - 1),
      lastDate: today,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF34A0A4),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }
}