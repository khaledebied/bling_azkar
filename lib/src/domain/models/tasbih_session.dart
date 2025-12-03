/// Represents an active or completed Tasbih counting session
class TasbihSession {
  final String tasbihTypeId;
  final int currentCount;
  final int targetCount;
  final bool isCompleted;
  final DateTime? completedAt;

  const TasbihSession({
    required this.tasbihTypeId,
    required this.currentCount,
    required this.targetCount,
    required this.isCompleted,
    this.completedAt,
  });

  TasbihSession copyWith({
    String? tasbihTypeId,
    int? currentCount,
    int? targetCount,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return TasbihSession(
      tasbihTypeId: tasbihTypeId ?? this.tasbihTypeId,
      currentCount: currentCount ?? this.currentCount,
      targetCount: targetCount ?? this.targetCount,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Get progress as a value between 0.0 and 1.0
  double get progress {
    if (targetCount == 0) return 0.0;
    return (currentCount / targetCount).clamp(0.0, 1.0);
  }

  /// Check if can increment (not at target yet)
  bool get canIncrement => currentCount < targetCount;

  /// Check if can decrement (above 0)
  bool get canDecrement => currentCount > 0;

  Map<String, dynamic> toJson() {
    return {
      'tasbihTypeId': tasbihTypeId,
      'currentCount': currentCount,
      'targetCount': targetCount,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TasbihSession.fromJson(Map<String, dynamic> json) {
    return TasbihSession(
      tasbihTypeId: json['tasbihTypeId'] as String,
      currentCount: json['currentCount'] as int,
      targetCount: json['targetCount'] as int,
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TasbihSession &&
          runtimeType == other.runtimeType &&
          tasbihTypeId == other.tasbihTypeId &&
          currentCount == other.currentCount &&
          targetCount == other.targetCount &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      tasbihTypeId.hashCode ^
      currentCount.hashCode ^
      targetCount.hashCode ^
      isCompleted.hashCode;
}

