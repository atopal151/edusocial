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
import 'services/verification_service.dart';

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
  
  // VerificationService'i başlat
  Get.put(VerificationService());

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

// GetX çeviri sınıfı - API entegrasyonu ile uyumlu
class GetTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys {
    try {
      final languageService = Get.find<LanguageService>();
      final translations = languageService.translations;
      
      if (translations.isEmpty) {
        debugPrint('⚠️ Çeviriler henüz yüklenmedi, varsayılan çeviriler kullanılıyor');
        return _getDefaultTranslations();
      }
      
      // GetX formatına dönüştür - tüm desteklenen diller için
      Map<String, Map<String, String>> result = {};
      
      // Her desteklenen dil için çeviri haritası oluştur
      for (String langCode in LanguageService.supportedLanguages.keys) {
        result[langCode] = {};
        _flattenMap(translations, '', result, langCode);
      }
      
      debugPrint('✅ GetX çevirileri hazırlandı: ${result.keys.toList()}');
      return result;
    } catch (e) {
      debugPrint('❌ LanguageService bulunamadı, varsayılan çeviriler kullanılıyor: $e');
      return _getDefaultTranslations();
    }
  }
  
  /// Varsayılan çeviri haritası - API'dan veri gelene kadar
  Map<String, Map<String, String>> _getDefaultTranslations() {
    return {
      'en': {
        'loading': 'Loading...',
        'error': 'Error',
        'common.buttons.loading': 'Loading...',
        'common.messages.loading': 'Loading...',
        'common.messages.error': 'Error'
      },
      'tr': {
        'loading': 'Yükleniyor...',
        'error': 'Hata',
        'common.buttons.loading': 'Yükleniyor...',
        'common.messages.loading': 'Yükleniyor...',
        'common.messages.error': 'Hata'
      },  
    };
  }
  
  void _flattenMap(Map<String, dynamic> map, String prefix, Map<String, Map<String, String>> result, String languageCode) {
    map.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';
      
      if (value is Map<String, dynamic>) {
        _flattenMap(value, fullKey, result, languageCode);
      } else {
        try {
          if (!result.containsKey(languageCode)) {
            result[languageCode] = {};
          }
          result[languageCode]![fullKey] = value.toString();
        } catch (e) {
          debugPrint('❌ Çeviri ekleme hatası ($fullKey): $e');
        }
      }
    });
  }
}
