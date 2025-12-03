import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bling_azkar/src/domain/models/tasbih_type.dart';
import 'package:bling_azkar/src/data/repositories/tasbih_repository.dart';
import 'package:bling_azkar/src/presentation/state/tasbih_counter_state.dart';

void main() {
  late TasbihRepository repository;
  late TasbihCounterNotifier notifier;

  setUp(() async {
    // Initialize SharedPreferences with mock values
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = TasbihRepository(prefs);
    notifier = TasbihCounterNotifier(
      repository,
      TasbihTypes.subhanallah,
      hapticEnabled: false, // Disable haptic for tests
    );
  });

  group('TasbihCounterNotifier - Increment Tests', () {
    test('increment increases count by 1', () {
      // Arrange
      expect(notifier.state.currentCount, 0);

      // Act
      notifier.increment();

      // Assert
      expect(notifier.state.currentCount, 1);
      expect(notifier.state.isCompleted, false);
    });

    test('multiple increments increase count correctly', () {
      // Act
      notifier.increment();
      notifier.increment();
      notifier.increment();

      // Assert
      expect(notifier.state.currentCount, 3);
    });

    test('increment at target-1 marks as completed', () {
      // Arrange - Set count to target - 1
      for (int i = 0; i < TasbihTypes.subhanallah.defaultTarget - 1; i++) {
        notifier.increment();
      }
      expect(notifier.state.currentCount, TasbihTypes.subhanallah.defaultTarget - 1);
      expect(notifier.state.isCompleted, false);

      // Act - Final increment
      notifier.increment();

      // Assert
      expect(notifier.state.currentCount, TasbihTypes.subhanallah.defaultTarget);
      expect(notifier.state.isCompleted, true);
      expect(notifier.state.completedAt, isNotNull);
    });

    test('cannot increment beyond target', () {
      // Arrange - Reach target
      for (int i = 0; i < TasbihTypes.subhanallah.defaultTarget; i++) {
        notifier.increment();
      }
      expect(notifier.state.isCompleted, true);
      final countAtTarget = notifier.state.currentCount;

      // Act - Try to increment further
      notifier.increment();

      // Assert - Count should not change
      expect(notifier.state.currentCount, countAtTarget);
      expect(notifier.state.canIncrement, false);
    });

    test('canIncrement returns false at target', () {
      // Arrange - Reach target
      for (int i = 0; i < TasbihTypes.subhanallah.defaultTarget; i++) {
        notifier.increment();
      }

      // Assert
      expect(notifier.state.canIncrement, false);
    });

    test('canIncrement returns true below target', () {
      // Arrange
      notifier.increment();

      // Assert
      expect(notifier.state.canIncrement, true);
    });
  });

  group('TasbihCounterNotifier - Decrement Tests', () {
    test('decrement decreases count by 1', () {
      // Arrange
      notifier.increment();
      notifier.increment();
      notifier.increment();
      expect(notifier.state.currentCount, 3);

      // Act
      notifier.decrement();

      // Assert
      expect(notifier.state.currentCount, 2);
    });

    test('cannot decrement below zero', () {
      // Arrange
      expect(notifier.state.currentCount, 0);

      // Act
      notifier.decrement();

      // Assert
      expect(notifier.state.currentCount, 0);
      expect(notifier.state.canDecrement, false);
    });

    test('decrement clears completion status', () {
      // Arrange - Reach completion
      for (int i = 0; i < TasbihTypes.subhanallah.defaultTarget; i++) {
        notifier.increment();
      }
      expect(notifier.state.isCompleted, true);

      // Act
      notifier.decrement();

      // Assert
      expect(notifier.state.isCompleted, false);
      expect(notifier.state.completedAt, null);
    });

    test('canDecrement returns false at zero', () {
      // Assert
      expect(notifier.state.canDecrement, false);
    });

    test('canDecrement returns true above zero', () {
      // Arrange
      notifier.increment();

      // Assert
      expect(notifier.state.canDecrement, true);
    });
  });

  group('TasbihCounterNotifier - Reset Tests', () {
    test('reset returns count to zero', () {
      // Arrange
      notifier.increment();
      notifier.increment();
      notifier.increment();
      expect(notifier.state.currentCount, 3);

      // Act
      notifier.reset();

      // Assert
      expect(notifier.state.currentCount, 0);
      expect(notifier.state.isCompleted, false);
      expect(notifier.state.completedAt, null);
    });

    test('reset clears completion status', () {
      // Arrange - Complete session
      for (int i = 0; i < TasbihTypes.subhanallah.defaultTarget; i++) {
        notifier.increment();
      }
      expect(notifier.state.isCompleted, true);

      // Act
      notifier.reset();

      // Assert
      expect(notifier.state.currentCount, 0);
      expect(notifier.state.isCompleted, false);
    });

    test('can increment again after reset', () {
      // Arrange - Complete and reset
      for (int i = 0; i < TasbihTypes.subhanallah.defaultTarget; i++) {
        notifier.increment();
      }
      notifier.reset();

      // Act
      notifier.increment();

      // Assert
      expect(notifier.state.currentCount, 1);
      expect(notifier.state.canIncrement, true);
    });
  });

  group('TasbihCounterNotifier - Progress Tests', () {
    test('progress is 0.0 at start', () {
      expect(notifier.state.progress, 0.0);
    });

    test('progress is 0.5 at half', () {
      // Arrange - Increment to half
      for (int i = 0; i < (TasbihTypes.subhanallah.defaultTarget / 2).round(); i++) {
        notifier.increment();
      }

      // Assert
      expect(notifier.state.progress, closeTo(0.5, 0.05));
    });

    test('progress is 1.0 at target', () {
      // Arrange - Complete
      for (int i = 0; i < TasbihTypes.subhanallah.defaultTarget; i++) {
        notifier.increment();
      }

      // Assert
      expect(notifier.state.progress, 1.0);
    });
  });

  group('TasbihCounterNotifier - SetCount Tests', () {
    test('setCount updates count correctly', () {
      // Act
      notifier.setCount(15);

      // Assert
      expect(notifier.state.currentCount, 15);
    });

    test('setCount marks completed if at target', () {
      // Act
      notifier.setCount(TasbihTypes.subhanallah.defaultTarget);

      // Assert
      expect(notifier.state.isCompleted, true);
    });

    test('setCount rejects negative values', () {
      // Act
      notifier.setCount(-5);

      // Assert
      expect(notifier.state.currentCount, 0);
    });

    test('setCount rejects values above target', () {
      // Act
      notifier.setCount(TasbihTypes.subhanallah.defaultTarget + 10);

      // Assert
      expect(notifier.state.currentCount, 0);
    });
  });

  group('TasbihCounterNotifier - SetTarget Tests', () {
    test('setTarget updates target correctly', () {
      // Act
      notifier.setTarget(50);

      // Assert
      expect(notifier.state.targetCount, 50);
    });

    test('setTarget marks completed if current >= new target', () {
      // Arrange
      notifier.increment();
      notifier.increment();
      notifier.increment();
      notifier.increment();
      notifier.increment();
      expect(notifier.state.currentCount, 5);

      // Act - Set target to 3 (below current)
      notifier.setTarget(3);

      // Assert
      expect(notifier.state.isCompleted, true);
    });

    test('setTarget rejects zero or negative', () {
      final originalTarget = notifier.state.targetCount;

      // Act
      notifier.setTarget(0);

      // Assert
      expect(notifier.state.targetCount, originalTarget);

      // Act
      notifier.setTarget(-5);

      // Assert
      expect(notifier.state.targetCount, originalTarget);
    });
  });

  group('TasbihCounterNotifier - Persistence Tests', () {
    test('session is persisted after increment', () async {
      // Act
      notifier.increment();

      // Assert - Check repository has saved data
      final savedSession = repository.getSession(TasbihTypes.subhanallah.id);
      expect(savedSession, isNotNull);
      expect(savedSession!.currentCount, 1);
    });

    test('session is persisted after reset', () async {
      // Arrange
      notifier.increment();
      notifier.increment();

      // Act
      notifier.reset();

      // Assert
      final savedSession = repository.getSession(TasbihTypes.subhanallah.id);
      expect(savedSession, isNotNull);
      expect(savedSession!.currentCount, 0);
    });

    test('loads existing session from repository', () async {
      // Arrange - Create a new notifier (should load from storage)
      final newNotifier = TasbihCounterNotifier(
        repository,
        TasbihTypes.subhanallah,
        hapticEnabled: false,
      );

      // Assert - Should load the session we just saved
      expect(newNotifier.state.currentCount, 0);
    });
  });

  group('TasbihSession Model Tests', () {
    test('progress calculation is correct', () {
      final session = notifier.state;
      
      expect(session.progress, 0.0);
      
      notifier.setCount(16); // Half of 33 (rounded)
      expect(notifier.state.progress, closeTo(0.48, 0.02));
      
      notifier.setCount(33);
      expect(notifier.state.progress, 1.0);
    });

    test('canIncrement is correct at boundaries', () {
      expect(notifier.state.canIncrement, true);
      
      notifier.setCount(TasbihTypes.subhanallah.defaultTarget);
      expect(notifier.state.canIncrement, false);
    });

    test('canDecrement is correct at boundaries', () {
      expect(notifier.state.canDecrement, false);
      
      notifier.increment();
      expect(notifier.state.canDecrement, true);
    });
  });
}

