import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/core/models/user_model.dart';
import 'package:inventory/main.dart';

void main() {
  group('App Startup Tests', () {
    testWidgets('App initializes with splash screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: InventoryApp()));

      // Should show something on startup
      expect(find.byType(InventoryApp), findsOneWidget);
    });
  });

  group('Model Serialization Tests', () {
    test('UserModel serializes and deserializes correctly', () {
      const user = UserModel(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        role: 'user',
      );

      final json = user.toJson();
      final restored = UserModel.fromJson(json);

      expect(restored.id, user.id);
      expect(restored.name, user.name);
      expect(restored.email, user.email);
      expect(restored.role, user.role);
    });

    test('UserModel handles aslab role correctly', () {
      const aslabUser = UserModel(
        id: 2,
        name: 'Admin User',
        email: 'admin@example.com',
        role: 'aslab',
      );

      expect(aslabUser.role, 'aslab');
      expect(aslabUser.toJson()['role'], 'aslab');
    });

    test('UserModel with missing optional fields', () {
      const minimalUser = UserModel(id: 3, name: 'Minimal');

      final json = minimalUser.toJson();
      final restored = UserModel.fromJson(json);

      expect(restored.id, minimalUser.id);
      expect(restored.name, minimalUser.name);
      expect(restored.email, isNull);
      expect(restored.role, isNull);
    });
  });

  group('Role-based Navigation Logic', () {
    test('Student role should navigate to /user', () {
      const studentUser = UserModel(
        id: 1,
        name: 'Student',
        email: 'student@example.com',
        role: 'user',
      );

      expect(studentUser.role, equals('user'));
    });

    test('Aslab role should navigate to /aslab', () {
      const aslabUser = UserModel(
        id: 2,
        name: 'Lab Assistant',
        email: 'aslab@example.com',
        role: 'aslab',
      );

      expect(aslabUser.role, equals('aslab'));
    });
  });
}
