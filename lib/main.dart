import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/aignup_binding.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginView()),
        GetPage(
          name: '/signup',
          page: () => SignupView(),
          binding: SignupBinding(), // Controller burada enjekte edilecek
        ),
      ],
    );
  }
}
