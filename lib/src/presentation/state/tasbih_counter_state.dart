import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../domain/models/tasbih_session.dart';
import '../../domain/models/tasbih_type.dart';
import '../../data/repositories/tasbih_repository.dart';

/// StateNotifier for managing a single Tasbih counter session
/// This replaces setState() with immutable state updates
class TasbihCounterNotifier extends StateNotifier<TasbihSession> {
  final TasbihRepository _repository;
  final bool _hapticEnabled;

  TasbihCounterNotifier(
    this._repository,
    TasbihType tasbihType, {
    bool hapticEnabled = true,
  })  : _hapticEnabled = hapticEnabled,
        super(
          _repository.getSession(tasbihType.id) ??
              TasbihSession(
                tasbihTypeId: tasbihType.id,
                currentCount: 0,
                targetCount: tasbihType.defaultTarget,
                isCompleted: false,
              ),
        ) {
    // Save initial session
    _repository.saveSession(state);
  }

  /// Increment the counter by 1
  void increment() {
    if (!state.canIncrement) {
      // Already at target, cannot increment
      return;
    }

    final newCount = state.currentCount + 1;
    final isCompleted = newCount >= state.targetCount;

    if (_hapticEnabled) {
      HapticFeedback.lightImpact();
    }

    state = state.copyWith(
      currentCount: newCount,
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
    );

    _repository.saveSession(state);
  }

  /// Decrement the counter by 1
  void decrement() {
    if (!state.canDecrement) {
      return;
    }

    if (_hapticEnabled) {
      HapticFeedback.selectionClick();
    }

    final newSession = TasbihSession(
      tasbihTypeId: state.tasbihTypeId,
      currentCount: state.currentCount - 1,
      targetCount: state.targetCount,
      isCompleted: false,
      completedAt: null,
    );

    state = newSession;
    _repository.saveSession(state);
  }

  /// Set the counter to a specific value
  void setCount(int value) {
    if (value < 0 || value > state.targetCount) {
      return;
    }

    if (_hapticEnabled) {
      HapticFeedback.mediumImpact();
    }

    final isCompleted = value >= state.targetCount;

    state = state.copyWith(
      currentCount: value,
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
    );

    _repository.saveSession(state);
  }

  /// Reset the counter to 0
  void reset() {
    if (_hapticEnabled) {
      HapticFeedback.heavyImpact();
    }

    state = state.copyWith(
      currentCount: 0,
      isCompleted: false,
      completedAt: null,
    );

    _repository.saveSession(state);
  }

  /// Update the target count
  void setTarget(int target) {
    if (target <= 0) return;

    final isCompleted = state.currentCount >= target;

    state = state.copyWith(
      targetCount: target,
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
    );

    _repository.saveSession(state);
  }

  /// Clear the session from storage
  void clearSession() {
    _repository.clearSession(state.tasbihTypeId);
  }
}

