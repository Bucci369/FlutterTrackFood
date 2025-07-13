/// Model for step tracking data
class StepData {
  final String id;
  final String userId;
  final DateTime date;
  final int steps;
  final String source; // 'sensor' or 'manual'
  final DateTime createdAt;

  StepData({
    required this.id,
    required this.userId,
    required this.date,
    required this.steps,
    required this.source,
    required this.createdAt,
  });

  factory StepData.fromJson(Map<String, dynamic> json) {
    return StepData(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      steps: json['steps'],
      source: json['source'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'steps': steps,
      'source': source,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Helper class for daily step calculations
class DailyStepSummary {
  final DateTime date;
  final int totalSteps;
  final int sensorSteps;
  final int manualSteps;
  final int goal;
  final double progress;

  DailyStepSummary({
    required this.date,
    required this.totalSteps,
    required this.sensorSteps,
    required this.manualSteps,
    required this.goal,
  }) : progress = goal > 0 ? (totalSteps / goal).clamp(0.0, 1.0) : 0.0;

  bool get goalAchieved => totalSteps >= goal;
  int get remainingSteps => (goal - totalSteps).clamp(0, goal);
}