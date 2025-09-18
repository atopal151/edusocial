import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  
  // Desteklenen diller
  static const Map<String, String> supportedLanguages = {
    'tr': 'Türkçe',
    'en': 'English',
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
      final savedLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
      await changeLanguage(savedLanguage);
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
      
      debugPrint('Dil değiştirildi: $languageCode');
    } catch (e) {
      debugPrint('Dil değiştirme hatası: $e');
    }
  }

  /// Çeviri dosyasını yükle
  Future<void> _loadTranslations(String languageCode) async {
    try {
      final jsonString = await rootBundle.loadString('assets/translations/$languageCode.json');
      final Map<String, dynamic> loadedTranslations = json.decode(jsonString);
      translations.value = loadedTranslations;
    } catch (e) {
      debugPrint('Çeviri dosyası yükleme hatası: $e');
      // Hata durumunda varsayılan dili yükle
      if (languageCode != _defaultLanguage) {
        await _loadTranslations(_defaultLanguage);
      }
    }
  }

  /// Dil kodundan locale oluştur
  Locale _getLocaleFromCode(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return const Locale('tr', 'TR');
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

  /// Çeviri al
  String tr(String key) {
    try {
      final keys = key.split('.');
      dynamic value = translations;
      
      for (final k in keys) {
        if (value is Map && value.containsKey(k)) {
          value = value[k];
        } else {
          return key; // Anahtar bulunamadıysa anahtarı döndür
        }
      }
      
      return value?.toString() ?? key;
    } catch (e) {
      debugPrint('Çeviri hatası ($key): $e');
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
      // Profilde dil yoksa varsayılan dili kullan
      await changeLanguage(_defaultLanguage);
    }
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

      debugPrint('🌐 Languages API Status Code: ${response.statusCode}');
      
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

      debugPrint('🌐 Frontend Language API Status Code: ${response.statusCode}');
      
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

  /// Her iki API'yi de çağır ve debug et
  Future<void> debugLanguageAPIs() async {
    debugPrint('🚀 Language API Debug başlatılıyor...');
    
    await fetchLanguagesFromAPI();
    await fetchFrontendLanguageFromAPI();
    
    debugPrint('✅ Language API Debug tamamlandı');
  }
} 