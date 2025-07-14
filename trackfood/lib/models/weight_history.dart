class WeightHistory {
  final String id;
  final String userId;
  final double weightKg;
  final DateTime recordedDate;
  final String? notes;
  final DateTime createdAt;

  WeightHistory({
    required this.id,
    required this.userId,
    required this.weightKg,
    required this.recordedDate,
    this.notes,
    required this.createdAt,
  });

  factory WeightHistory.fromJson(Map<String, dynamic> json) {
    return WeightHistory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      weightKg: (json['weight_kg'] as num).toDouble(),
      recordedDate: DateTime.parse(json['recorded_date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'weight_kg': weightKg,
      'recorded_date': recordedDate.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}