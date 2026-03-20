import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:inventory/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches and reaches initial auth flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: InventoryApp()));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final hasLoginCta = find.text('Login').evaluate().isNotEmpty;
    final hasSplashTitle = find
        .text('Inventory Desk Tracking')
        .evaluate()
        .isNotEmpty;

    expect(hasLoginCta || hasSplashTitle, isTrue);
  });
}
