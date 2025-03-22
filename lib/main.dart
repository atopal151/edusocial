import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/login_controller.dart';
import 'controllers/nav_bar_controller.dart';
import 'routes/app_routes.dart'; 

void main() {
  Get.put(LoginController(), permanent: true);
  Get.put(NavigationController());
   
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.main, 
      getPages: Routes.pages, 
    );
  }
}
