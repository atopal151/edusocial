import 'package:edusocial/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/aignup_binding.dart';
import 'bindings/login_binding.dart';
import 'bindings/onboarding_binding.dart';
import 'controllers/login_controller.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/step1_screen.dart';

void main() {
  Get.put(LoginController(), permanent: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
  debugShowCheckedModeBanner: false,
  initialRoute: '/step1',
  getPages: [
    GetPage(
      name: '/login',
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: '/signup',
      page: () => SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: '/step1',
      page: () => Step1View(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: '/home',
      page: () => HomeScreen(),
    ),
  ],
  
);

  }
}
