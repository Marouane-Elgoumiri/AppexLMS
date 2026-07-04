import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:appex/app/supabase_config.dart';
import 'package:appex/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Supabase.initialize() requires SharedPreferencesAsync; mock it.
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
      );
    } on AssertionError {
      // already initialized
    } catch (_) {
      // tolerate all other init hiccups in tests
    }
  });

  testWidgets('App launches and shows splash screen', (tester) async {
    await tester.pumpWidget(const AppexLMS());
    await tester.pump();
    expect(find.text('AppexLMS'), findsOneWidget);

    // Drive the in-app 2s splash timer so the test doesn't hang on the
    // pending Timer we see in the trace. We don't care which route it
    // lands on; just that the splash started.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }, skip: false);
}

