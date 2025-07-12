class UserActivity {
  final String id;
  final String userId;
  final String activityId;
  final String activityName;
  final String emoji;
  final double met;
  final int durationMin;
  final double weightKg;
  final double calories;
  final String? note;
  final DateTime activityDate;
  final DateTime createdAt;

  UserActivity({
    required this.id,
    required this.userId,
    required this.activityId,
    required this.activityName,
    required this.emoji,
    required this.met,
    required this.durationMin,
    required this.weightKg,
    required this.calories,
    this.note,
    required this.activityDate,
    required this.createdAt,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) => UserActivity(
    id: json['id'],
    userId: json['user_id'],
    activityId: json['activity_id'],
    activityName: json['activity_name'],
    emoji: json['emoji'],
    met: (json['met'] as num).toDouble(),
    durationMin: json['duration_min'],
    weightKg: (json['weight_kg'] as num).toDouble(),
    calories: (json['calories'] as num).toDouble(),
    note: json['note'],
    activityDate: DateTime.parse(json['activity_date']),
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'activity_id': activityId,
    'activity_name': activityName,
    'emoji': emoji,
    'met': met,
    'duration_min': durationMin,
    'weight_kg': weightKg,
    'calories': calories,
    'note': note,
    'activity_date': activityDate.toIso8601String().split('T')[0],
    'created_at': createdAt.toIso8601String(),
  };
}