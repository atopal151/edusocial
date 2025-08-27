import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';   
import 'bindings/initial_bindings.dart';
import 'routes/app_routes.dart';
import 'services/language_service.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/onesignal_service.dart';
import 'services/socket_services.dart';
import 'services/pin_message_service.dart';

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

  // ApiService'i başlat
  Get.put(ApiService());
  
  // AuthService'i başlat
  Get.put(AuthService());
  
  // LanguageService'i put ile başlat
  Get.put(LanguageService());
  
  // OneSignalService'i başlat
  Get.put(OneSignalService());
  
  // SocketService'i başlat
  Get.put(SocketService());
  
  // PinMessageService'i başlat
  Get.put(PinMessageService());

  // SocketService'i al ve bağlantı kur
  final socketService = Get.find<SocketService>();
  final token = GetStorage().read('token');
  if (token != null) {
    socketService.connect(token);
  }
  
  // Debug: Dil servisinin yüklenip yüklenmediğini kontrol et
  final languageService = Get.find<LanguageService>();
  debugPrint('Mevcut dil: ${languageService.currentLanguage.value}');

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
      // Dil desteği için locale ayarları
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      translations: GetTranslations(),
    );
  }
}

// GetX çeviri sınıfı
class GetTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys {
    try {
      final languageService = Get.find<LanguageService>();
      final translations = languageService.translations;
      
      // GetX formatına dönüştür
      Map<String, Map<String, String>> result = {};
      _flattenMap(translations, '', result);
      
      return result;
    } catch (e) {
      debugPrint('LanguageService bulunamadı, varsayılan çeviriler kullanılıyor: $e');
      // Varsayılan boş çeviriler döndür
      return {
        'en': {},
        'tr': {},  
      };
    }
  }
  
  void _flattenMap(Map<String, dynamic> map, String prefix, Map<String, Map<String, String>> result) {
    map.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';
      
      if (value is Map<String, dynamic>) {
        _flattenMap(value, fullKey, result);
      } else {
        try {
          final languageCode = Get.find<LanguageService>().currentLanguage.value;
          if (!result.containsKey(languageCode)) {
            result[languageCode] = {};
          }
          result[languageCode]![fullKey] = value.toString();
        } catch (e) {
          debugPrint('Çeviri hatası: $e');
        }
      }
    });
  }
}
