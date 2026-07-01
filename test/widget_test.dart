import 'package:flutter_test/flutter_test.dart';
import 'package:appex/main.dart';

void main() {
  testWidgets('App launches with AuthScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const AppexLMS());
    await tester.pumpAndSettle();
    expect(find.text('Auth'), findsOneWidget);
  });
}
