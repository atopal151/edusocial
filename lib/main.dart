import 'dart:io';
import 'package:edusocial/controllers/appbar_controller.dart';
import 'package:edusocial/controllers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'bindings/initial_bindings.dart';
import 'controllers/login_controller.dart';
import 'controllers/nav_bar_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/social/match_controller.dart';
import 'routes/app_routes.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  final box = GetStorage();
  final token = box.read('token');
  Get.put(LoginController(), permanent: true);
  Get.put(NavigationController(), permanent: true);
  Get.put(MatchController(), permanent: true);
  Get.put(AppBarController());
  Get.put(ProfileController(), permanent: true);
  Get.put(OnboardingController());
  

  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp(initialRoute: token != null ? Routes.main : Routes.login));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: InitialBindings(),
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: Routes.pages,
    );
  }
}
