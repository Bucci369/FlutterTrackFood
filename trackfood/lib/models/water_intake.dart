class WaterIntake {
  final String id;
  final String userId;
  final DateTime date;
  final int amountMl;
  final int dailyGoalMl;
  final DateTime createdAt;
  final DateTime updatedAt;

  WaterIntake({
    required this.id,
    required this.userId,
    required this.date,
    required this.amountMl,
    required this.dailyGoalMl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WaterIntake.fromJson(Map<String, dynamic> json) => WaterIntake(
    id: json['id'],
    userId: json['user_id'],
    date: DateTime.parse(json['date']),
    amountMl: json['amount_ml'],
    dailyGoalMl: json['daily_goal_ml'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'date': date.toIso8601String().split('T')[0],
    'amount_ml': amountMl,
    'daily_goal_ml': dailyGoalMl,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}