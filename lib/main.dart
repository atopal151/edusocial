import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'bindings/initial_bindings.dart';
import 'routes/app_routes.dart';
import 'services/translation_service.dart';
import 'services/auth_service.dart';

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

  HttpOverrides.global = MyHttpOverrides();

  // AuthService'i önce başlat
  Get.put(AuthService());
  
  // TranslationService'i başlat ve Türkçe çevirileri yükle
  final translationService = Get.put(TranslationService());
  await translationService.loadTranslations('tr');
  
  // Debug: Çevirilerin yüklenip yüklenmediğini kontrol et
  translationService.debugTranslations();

  runApp(MyApp(initialRoute: Routes.main));
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
