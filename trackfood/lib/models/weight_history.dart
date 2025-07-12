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
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      weightKg: (json['weight_kg'] as num).toDouble(),
      recordedDate: DateTime.parse(json['recorded_date']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'weight_kg': weightKg,
      'recorded_date': recordedDate.toIso8601String().split('T')[0],
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  WeightHistory copyWith({
    String? id,
    String? userId,
    double? weightKg,
    DateTime? recordedDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return WeightHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weightKg: weightKg ?? this.weightKg,
      recordedDate: recordedDate ?? this.recordedDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}