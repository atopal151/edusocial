import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../utils/constants.dart';
import '../components/print_full_text.dart';

class LanguageService extends GetxService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';
  
  final RxString currentLanguage = _defaultLanguage.obs;
  final RxMap<String, dynamic> translations = <String, dynamic>{}.obs;
  
  // Desteklenen diller (API ve asset dil dosyaları ile uyumlu)
  static const Map<String, String> supportedLanguages = {
    'tr': 'Türkçe',
    'en': 'English',
    'pl': 'Polski',
    'uk': 'Українська',
  };

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  /// Kaydedilmiş dili yükle
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      
      if (savedLanguage != null) {
        // Local'de kaydedilmiş dil var, onu kullan
        await changeLanguage(savedLanguage);
      } else {
        // Local'de kaydedilmiş dil yok, kullanıcının API'dan dil tercihini kontrol et
        final token = GetStorage().read("token");
        if (token != null) {
          // Kullanıcı giriş yapmış, API'dan dil tercihini al
          final userLanguage = await _getUserLanguageFromAPI();
          if (userLanguage != null && supportedLanguages.containsKey(userLanguage)) {
            await changeLanguage(userLanguage);
          } else {
            await changeLanguage(_defaultLanguage);
          }
        } else {
          // Kullanıcı giriş yapmamış, varsayılan dili kullan
          await changeLanguage(_defaultLanguage);
        }
      }
    } catch (e) {
      debugPrint('Dil yükleme hatası: $e');
      await changeLanguage(_defaultLanguage);
    }
  }

  /// Dili değiştir
  Future<void> changeLanguage(String languageCode) async {
    try {
      // Desteklenen dil mi kontrol et
      if (!supportedLanguages.containsKey(languageCode)) {
        languageCode = _defaultLanguage;
      }

      // Çeviri dosyasını yükle
      await _loadTranslations(languageCode);
      
      // GetX locale'ini güncelle
      final locale = _getLocaleFromCode(languageCode);
      Get.updateLocale(locale);
      
      // Dili kaydet
      currentLanguage.value = languageCode;
      await _saveLanguage(languageCode);
      
      // Kullanıcı giriş yapmışsa API'ya da dil tercihini kaydet
      await _saveLanguageToAPI(languageCode);
      
      debugPrint('Dil değiştirildi: $languageCode');
    } catch (e) {
      debugPrint('Dil değiştirme hatası: $e');
    }
  }

  /// Çeviri dosyasını yükle - API + asset birleştirilir (eksik anahtarlar asset'ten tamamlanır)
  Future<void> _loadTranslations(String languageCode) async {
    try {
      final apiTranslations = await _loadTranslationsFromAPI(languageCode);
      final assetTranslations = await _loadTranslationsFromAssets(languageCode);

      if (apiTranslations != null && apiTranslations.isNotEmpty) {
        if (assetTranslations != null && assetTranslations.isNotEmpty) {
          // API + asset birleştir: API öncelikli, eksik anahtarlar asset'ten eklenir (dil alanı okunabilsin)
          translations.value = _deepMerge(assetTranslations, apiTranslations);
          debugPrint('✅ Çeviriler API + asset birleştirilerek yüklendi: $languageCode');
        } else {
          translations.value = apiTranslations;
          debugPrint('✅ Çeviriler API\'dan yüklendi: $languageCode');
        }
        return;
      }

      if (assetTranslations != null && assetTranslations.isNotEmpty) {
        translations.value = assetTranslations;
        debugPrint('✅ Çeviriler asset\'ten yüklendi: $languageCode');
      } else {
        translations.value = <String, dynamic>{};
      }
    } catch (e) {
      debugPrint('❌ Çeviri yükleme genel hatası: $e');
      translations.value = <String, dynamic>{};
    }
  }

  /// Asset üzerine API değerlerini yazar; API'da yoksa asset değeri kalır (eksik anahtarlar tamamlanır)
  Map<String, dynamic> _deepMerge(Map<String, dynamic> base, Map<String, dynamic> overlay) {
    final result = Map<String, dynamic>.from(base);
    for (final entry in overlay.entries) {
      if (entry.value is Map<String, dynamic> && result[entry.key] is Map<String, dynamic>) {
        result[entry.key] = _deepMerge(
          Map<String, dynamic>.from(result[entry.key] as Map),
          entry.value as Map<String, dynamic>,
        );
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Asset'teki dil dosyasından çeviri yükle (API yapısı ile uyumlu)
  Future<Map<String, dynamic>?> _loadTranslationsFromAssets(String languageCode) async {
    try {
      final path = 'assets/translations/$languageCode.json';
      final String jsonString = await rootBundle.loadString(path);
      //printFullText('📁 [LanguageService] Dil asset ham veri ($path): $jsonString');
      final Map<String, dynamic> data = json.decode(jsonString) as Map<String, dynamic>;
      return data;
    } catch (e) {
      debugPrint('❌ Asset çeviri yükleme hatası ($languageCode): $e');
      if (languageCode != _defaultLanguage) {
        return _loadTranslationsFromAssets(_defaultLanguage);
      }
      return null;
    }
  }

  /// API'dan çeviri verilerini yükle - Timeout ve retry ile
  Future<Map<String, dynamic>?> _loadTranslationsFromAPI(String languageCode) async {
    const int maxRetries = 3;
    const Duration timeout = Duration(seconds: 10);
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('🔄 API çağrısı deneme $attempt/$maxRetries');
        final token = GetStorage().read("token");
        
        http.Response response;
        
        if (token != null) {
          // Kullanıcı girişi var - authenticated API kullan
          debugPrint('🔐 Authenticated kullanıcı için API çağrısı yapılıyor...');
          response = await http.get(
            Uri.parse("${AppConstants.baseUrl}/json-language"),
            headers: {
              "Authorization": "Bearer $token",
              "Accept": "application/json",
            },
          ).timeout(timeout);
        } else {
          // Kullanıcı girişi yok - no-auth API kullan
          debugPrint('🌐 No-auth API çağrısı yapılıyor...');
          response = await http.get(
            Uri.parse("${AppConstants.baseUrl}/json-language-noauth"),
            headers: {
              "Accept": "application/json",
            },
          ).timeout(timeout);
        }
        
        if (response.statusCode == 200) {
          final endpoint = token != null ? 'json-language' : 'json-language-noauth';
          printFullText('🌐 [LanguageService] Dil API ham veri ($endpoint): ${response.body}');
          final jsonData = json.decode(response.body);
          final translations = jsonData['translations'] as Map<String, dynamic>?;
          debugPrint('✅ API\'dan çeviriler başarıyla alındı (deneme $attempt)');
          return translations;
        } else {
          debugPrint('❌ API hatası: ${response.statusCode} (deneme $attempt)');
          if (attempt < maxRetries) {
            await Future.delayed(Duration(seconds: attempt * 2)); // Exponential backoff
          }
        }
      } catch (e) {
        debugPrint('❌ API çağrısı hatası (deneme $attempt): $e');
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2)); // Exponential backoff
        }
      }
    }
    
    debugPrint('❌ $maxRetries deneme sonrası API\'dan çeviri alınamadı');
    return null;
  }


  /// Dil kodundan locale oluştur
  Locale _getLocaleFromCode(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return const Locale('tr', 'TR');
      case 'pl':
        return const Locale('pl', 'PL');
      case 'uk':
        return const Locale('uk', 'UA');
      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }

  /// Dili kaydet
  Future<void> _saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      debugPrint('Dil kaydetme hatası: $e');
    }
  }

  /// API'ya dil tercihini kaydet
  Future<void> _saveLanguageToAPI(String languageCode) async {
    try {
      final token = GetStorage().read("token");
      if (token == null) {
        debugPrint('❌ Token bulunamadı, dil tercihi API\'ya kaydedilemiyor');
        return;
      }

      final response = await http.put(
        Uri.parse("${AppConstants.baseUrl}/profile/language"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "language": languageCode,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Dil tercihi API\'ya kaydedildi: $languageCode');
      } else {
        debugPrint('❌ Dil tercihi API kaydetme hatası: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Dil tercihi API kaydetme hatası: $e');
    }
  }

  /// Çeviri al - Sadece API'dan gelen verilerle
  String tr(String key) {
    try {
      // Çeviriler yüklenmemişse key'i döndür
      if (translations.isEmpty) {
        debugPrint('⚠️ Çeviriler henüz yüklenmedi: $key');
        return key;
      }

      final keys = key.split('.');
      dynamic value = translations;
      
      for (final k in keys) {
        if (value is Map && value.containsKey(k)) {
          value = value[k];
        } else {
          debugPrint('⚠️ Çeviri anahtarı bulunamadı: $key');
          return key; // Anahtar bulunamadıysa anahtarı döndür
        }
      }
      
      return value?.toString() ?? key;
    } catch (e) {
      debugPrint('❌ Çeviri hatası ($key): $e');
      return key;
    }
  }

  /// Mevcut dil adını al
  String getCurrentLanguageName() {
    return supportedLanguages[currentLanguage.value] ?? 'English';
  }

  /// Desteklenen dilleri al
  Map<String, String> getSupportedLanguages() {
    return supportedLanguages;
  }

  /// Kullanıcı profilinden dil kodunu al ve uygula
  Future<void> setLanguageFromProfile(String? profileLanguage) async {
    if (profileLanguage != null && profileLanguage.isNotEmpty) {
      await changeLanguage(profileLanguage);
    } else {
      // Profilde dil yoksa API'dan kullanıcının dil tercihini al
      final userLanguage = await _getUserLanguageFromAPI();
      if (userLanguage != null && userLanguage.isNotEmpty) {
        await changeLanguage(userLanguage);
      } else {
        // API'dan da dil alınamazsa varsayılan dili kullan
        await changeLanguage(_defaultLanguage);
      }
    }
  }

  /// API'dan kullanıcının dil tercihini al
  Future<String?> _getUserLanguageFromAPI() async {
    try {
      final token = GetStorage().read("token");
      if (token == null) {
        debugPrint('❌ Token bulunamadı, kullanıcı dil tercihi alınamıyor');
        return null;
      }

      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/me"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final userData = jsonData['data'] as Map<String, dynamic>?;
        final language = userData?['language'];

        // API dil bilgisi obje { "id", "code", "name" } veya string olabilir
        String? userLanguage;
        if (language is Map && language.containsKey('code')) {
          userLanguage = language['code']?.toString();
        } else if (language is String) {
          userLanguage = language;
        }

        debugPrint('✅ Kullanıcı dil tercihi API\'dan alındı: $userLanguage');
        return userLanguage;
      } else {
        debugPrint('❌ Kullanıcı dil tercihi API hatası: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Kullanıcı dil tercihi alma hatası: $e');
    }
    return null;
  }

  /// API'den desteklenen dilleri çek
  Future<void> fetchLanguagesFromAPI() async {
    try {
      final token = GetStorage().read("token");
      if (token == null) {
        debugPrint('❌ Token bulunamadı, languages API çağrısı yapılamıyor');
        return;
      }

      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/languages"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      //debugPrint('🌐 Languages API Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        printFullText('🌐 Languages API Response: ${response.body}');
        
        // JSON parsing
        try {
          final jsonData = json.decode(response.body);
          printFullText('🌐 Languages API Parsed JSON: ${json.encode(jsonData)}');
        } catch (e) {
          debugPrint('❌ Languages API JSON parsing error: $e');
        }
      } else {
        debugPrint('❌ Languages API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Languages API Exception: $e');
    }
  }

  /// API'den frontend dil verilerini çek
  Future<void> fetchFrontendLanguageFromAPI() async {
    try {
      final token = GetStorage().read("token");
      if (token == null) {
        debugPrint('❌ Token bulunamadı, json-language API çağrısı yapılamıyor');
        return;
      }

      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/json-language"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      //debugPrint('🌐 Frontend Language API Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        printFullText('🌐 Frontend Language API Response: ${response.body}');
        
        // JSON parsing
        try {
          final jsonData = json.decode(response.body);
          printFullText('🌐 Frontend Language API Parsed JSON: ${json.encode(jsonData)}');
        } catch (e) {
          debugPrint('❌ Frontend Language API JSON parsing error: $e');
        }
      } else {
        debugPrint('❌ Frontend Language API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Frontend Language API Exception: $e');
    }
  }

  /// API'den frontend dil verilerini çek (No Auth)
  Future<void> fetchFrontendNoAuthLanguageFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/json-language-noauth"),
        headers: {
          "Accept": "application/json",
        },
      );

      //debugPrint('🌐 Frontend No-Auth Language API Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        printFullText('🌐 Frontend No-Auth Language API Response: ${response.body}');
        
        // JSON parsing
        try {
          final jsonData = json.decode(response.body);
          printFullText('🌐 Frontend No-Auth Language API Parsed JSON: ${json.encode(jsonData)}');
        } catch (e) {
          debugPrint('❌ Frontend No-Auth Language API JSON parsing error: $e');
        }
      } else {
        debugPrint('❌ Frontend No-Auth Language API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Frontend No-Auth Language API Exception: $e');
    }
  }
/*
  /// Her iki API'yi de çağır ve debug et
  Future<void> debugLanguageAPIs() async {
    debugPrint('🚀 Language API Debug başlatılıyor...');
    
    await fetchLanguagesFromAPI();
    await fetchFrontendLanguageFromAPI();
    await fetchFrontendNoAuthLanguageFromAPI();
    
    debuPrint('✅ Language API Debug tamamlandı');
  }*/
} 