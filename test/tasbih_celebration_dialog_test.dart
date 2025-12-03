import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bling_azkar/src/domain/models/tasbih_type.dart';
import 'package:bling_azkar/src/data/repositories/tasbih_repository.dart';
import 'package:bling_azkar/src/presentation/widgets/tasbih_celebration_dialog.dart';

void main() {
  group('TasbihCelebrationDialog Widget Tests', () {
    testWidgets('dialog displays correctly', (WidgetTester tester) async {
      // Arrange
      bool restartCalled = false;
      bool doneCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TasbihCelebrationDialog(
              tasbihType: TasbihTypes.subhanallah,
              count: 33,
              onRestart: () => restartCalled = true,
              onDone: () => doneCalled = true,
            ),
          ),
        ),
      );

      // Let animations complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Assert - Check key elements are present
      expect(find.textContaining('Mabruk'), findsWidgets);
      expect(find.textContaining('مبروك'), findsWidgets);
      expect(find.text('33×'), findsOneWidget);
      expect(find.text(TasbihTypes.subhanallah.dhikrText), findsOneWidget);
    });

    testWidgets('restart button triggers callback', (WidgetTester tester) async {
      // Arrange
      bool restartCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TasbihCelebrationDialog(
              tasbihType: TasbihTypes.subhanallah,
              count: 33,
              onRestart: () => restartCalled = true,
              onDone: () {},
            ),
          ),
        ),
      );

      // Wait for all animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Act - Tap restart button by icon
      final restartIcon = find.byIcon(Icons.refresh);
      expect(restartIcon, findsOneWidget);
      
      await tester.tap(restartIcon);
      await tester.pump();

      // Assert
      expect(restartCalled, true);
    });

    testWidgets('done button triggers callback', (WidgetTester tester) async {
      // Arrange
      bool doneCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TasbihCelebrationDialog(
              tasbihType: TasbihTypes.subhanallah,
              count: 33,
              onRestart: () {},
              onDone: () => doneCalled = true,
            ),
          ),
        ),
      );

      // Wait for all animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Act - Tap done button by icon
      final doneIcon = find.byIcon(Icons.check);
      expect(doneIcon, findsOneWidget);
      
      await tester.tap(doneIcon);
      await tester.pump();

      // Assert
      expect(doneCalled, true);
    });

    testWidgets('dialog displays correct count', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TasbihCelebrationDialog(
              tasbihType: TasbihTypes.allahuAkbar,
              count: 34,
              onRestart: () {},
              onDone: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('34×'), findsOneWidget);
    });

    testWidgets('dialog displays correct dhikr type', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TasbihCelebrationDialog(
              tasbihType: TasbihTypes.alhamdulillah,
              count: 33,
              onRestart: () {},
              onDone: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text(TasbihTypes.alhamdulillah.dhikrText), findsOneWidget);
    });

    testWidgets('dialog has celebration icon', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TasbihCelebrationDialog(
              tasbihType: TasbihTypes.subhanallah,
              count: 33,
              onRestart: () {},
              onDone: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.celebration), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('dialog shows benefit text', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TasbihCelebrationDialog(
              tasbihType: TasbihTypes.astaghfirullah,
              count: 100,
              onRestart: () {},
              onDone: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Benefit should be displayed
      expect(
        find.text(TasbihTypes.astaghfirullah.benefitEn),
        findsOneWidget,
      );
    });

    testWidgets('dialog animation runs smoothly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TasbihCelebrationDialog(
              tasbihType: TasbihTypes.subhanallah,
              count: 33,
              onRestart: () {},
              onDone: () {},
            ),
          ),
        ),
      );

      // Initial state (animating in)
      await tester.pump();
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(ScaleTransition), findsWidgets);

      // Complete animation
      await tester.pumpAndSettle();

      // Assert - Dialog is fully visible
      expect(find.text('Mabruk!'), findsOneWidget);
    });
  });

  group('TasbihTypes Model Tests', () {
    test('all types have valid data', () {
      for (final type in TasbihTypes.all) {
        expect(type.id, isNotEmpty);
        expect(type.nameEn, isNotEmpty);
        expect(type.nameAr, isNotEmpty);
        expect(type.dhikrText, isNotEmpty);
        expect(type.meaningEn, isNotEmpty);
        expect(type.meaningAr, isNotEmpty);
        expect(type.benefitEn, isNotEmpty);
        expect(type.benefitAr, isNotEmpty);
        expect(type.defaultTarget, greaterThan(0));
      }
    });

    test('getById returns correct type', () {
      final type = TasbihTypes.getById('subhanallah');
      expect(type, isNotNull);
      expect(type, equals(TasbihTypes.subhanallah));
    });

    test('getById returns null for invalid id', () {
      final type = TasbihTypes.getById('invalid_id');
      expect(type, isNull);
    });

    test('all types have unique ids', () {
      final ids = TasbihTypes.all.map((t) => t.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, equals(uniqueIds.length));
    });

    test('correct number of types defined', () {
      expect(TasbihTypes.all.length, 6);
    });
  });

  group('TasbihRepository Tests', () {
    test('saves and retrieves last selected type', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = TasbihRepository(prefs);

      // Act
      await repo.saveLastSelectedType('subhanallah');
      final result = repo.getLastSelectedType();

      // Assert
      expect(result, 'subhanallah');
    });

    test('animations preference saves and retrieves', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = TasbihRepository(prefs);

      // Act
      await repo.setAnimationsEnabled(false);
      final result = repo.getAnimationsEnabled();

      // Assert
      expect(result, false);
    });

    test('haptic preference defaults to true', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = TasbihRepository(prefs);

      // Assert
      expect(repo.getHapticEnabled(), true);
    });
  });
}

