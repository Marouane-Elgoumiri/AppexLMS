import 'package:flutter_test/flutter_test.dart';
import 'package:appex/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AppexLMS());
    await tester.pump();
    expect(find.text('AppexLMS'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
