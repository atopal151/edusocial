import 'package:edusocial/controllers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/login_controller.dart';
import 'controllers/nav_bar_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/social/match_controller.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(LoginController(), permanent: true);
  Get.put(NavigationController(), permanent: true);
  Get.put(MatchController(), permanent: true); 
   Get.put(ProfileController(), permanent: true); 
  Get.put(OnboardingController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.login,
      getPages: Routes.pages,
    );
  }
}
