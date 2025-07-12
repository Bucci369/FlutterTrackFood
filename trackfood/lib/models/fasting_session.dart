class FastingSession {
  final String id;
  final String userId;
  final String plan; // e.g., "16:8", "18:6", "20:4"
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;
  final String status; // 'active', 'completed', 'cancelled'
  final int? targetDurationHours;
  final String? fastingType; // 'intermittent', 'extended', 'custom'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  FastingSession({
    required this.id,
    required this.userId,
    required this.plan,
    required this.startTime,
    this.endTime,
    required this.isActive,
    required this.status,
    this.targetDurationHours,
    this.fastingType,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FastingSession.fromJson(Map<String, dynamic> json) => FastingSession(
    id: json['id'],
    userId: json['user_id'],
    plan: json['plan'],
    startTime: DateTime.parse(json['start_time']),
    endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
    isActive: json['is_active'] ?? false,
    status: json['status'] ?? 'active',
    targetDurationHours: json['target_duration_hours'],
    fastingType: json['fasting_type'],
    notes: json['notes'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'plan': plan,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime?.toIso8601String(),
    'is_active': isActive,
    'status': status,
    'target_duration_hours': targetDurationHours,
    'fasting_type': fastingType,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  // Utility methods
  Duration get elapsedTime {
    final now = DateTime.now();
    return now.difference(startTime);
  }

  Duration? get remainingTime {
    if (targetDurationHours == null) return null;
    final targetDuration = Duration(hours: targetDurationHours!);
    final elapsed = elapsedTime;
    final remaining = targetDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  double get progressPercentage {
    if (targetDurationHours == null) return 0.0;
    final targetMinutes = targetDurationHours! * 60;
    final elapsedMinutes = elapsedTime.inMinutes;
    return (elapsedMinutes / targetMinutes).clamp(0.0, 1.0);
  }

  bool get isCompleted => status == 'completed' || 
      (targetDurationHours != null && elapsedTime.inHours >= targetDurationHours!);
}