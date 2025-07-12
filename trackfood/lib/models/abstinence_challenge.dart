class AbstinenceChallenge {
  final String id;
  final String userId;
  final String challengeType;
  final String challengeName;
  final DateTime startDate;
  final DateTime? lastResetDate;
  final int currentStreakDays;
  final int longestStreakDays;
  final int totalAttempts;
  final bool isActive;
  final String status;
  final int? targetDays;
  final String? rewardMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  AbstinenceChallenge({
    required this.id,
    required this.userId,
    required this.challengeType,
    required this.challengeName,
    required this.startDate,
    this.lastResetDate,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.totalAttempts,
    required this.isActive,
    required this.status,
    this.targetDays,
    this.rewardMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AbstinenceChallenge.fromJson(Map<String, dynamic> json) {
    return AbstinenceChallenge(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      challengeType: json['challenge_type'] ?? '',
      challengeName: json['challenge_name'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      lastResetDate: json['last_reset_date'] != null 
          ? DateTime.parse(json['last_reset_date']) 
          : null,
      currentStreakDays: json['current_streak_days'] ?? 0,
      longestStreakDays: json['longest_streak_days'] ?? 0,
      totalAttempts: json['total_attempts'] ?? 0,
      isActive: json['is_active'] ?? false,
      status: json['status'] ?? 'active',
      targetDays: json['target_days'],
      rewardMessage: json['reward_message'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'challenge_type': challengeType,
      'challenge_name': challengeName,
      'start_date': startDate.toIso8601String(),
      'last_reset_date': lastResetDate?.toIso8601String(),
      'current_streak_days': currentStreakDays,
      'longest_streak_days': longestStreakDays,
      'total_attempts': totalAttempts,
      'is_active': isActive,
      'status': status,
      'target_days': targetDays,
      'reward_message': rewardMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Utility methods
  bool get isCompleted => targetDays != null && currentStreakDays >= targetDays!;
  
  double get progressPercentage {
    if (targetDays == null || targetDays == 0) return 0.0;
    return (currentStreakDays / targetDays!).clamp(0.0, 1.0);
  }
  
  int get daysUntilTarget {
    if (targetDays == null) return 0;
    return (targetDays! - currentStreakDays).clamp(0, targetDays!);
  }
}