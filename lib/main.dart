import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:appex/app/supabase_config.dart';
import 'package:appex/app/theme/app_theme.dart';
import 'package:appex/app/routes/app_routes.dart';
import 'package:appex/app/routes/app_pages.dart';
import 'package:appex/app/bindings/initial_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  runApp(const AppexLMS());
}

class AppexLMS extends StatelessWidget {
  const AppexLMS({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AppexLMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.login,
      initialBinding: InitialBinding(),
      getPages: AppPages.pages,
    );
  }
}
