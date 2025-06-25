import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';

class TranslationService extends GetxService {
  static TranslationService get to => Get.find();
  
  Map<String, String> _translations = {};
  String _currentLanguage = 'tr'; // Default language
  bool _isLoaded = false;
  
  // Observable for UI updates
  final RxBool isLoading = false.obs;
  
  /// Get translation for a key
  String t(String key) {
    return _translations[key] ?? key;
  }
  
  /// Get current language
  String get currentLanguage => _currentLanguage;
  
  /// Check if translations are loaded
  bool get isLoaded => _isLoaded;
  
  /// Load translations from API
  Future<void> loadTranslations(String languageCode) async {
    if (_currentLanguage == languageCode && _isLoaded) return;
    
    isLoading.value = true;
    
    debugPrint('🌍 [TranslationService] loadTranslations başlatıldı - Dil: $languageCode');
    
    try {
      final authService = Get.find<AuthService>();
      final token = authService.getToken();
      
      if (token == null) {
        debugPrint('❌ [TranslationService] Token bulunamadı');
        return;
      }
      
      debugPrint('🔑 [TranslationService] Token alındı: ${token.substring(0, 20)}...');
      
      // Farklı endpoint'leri dene
      final possibleEndpoints = [
        '/json-language',
        '/languages/json',
        '/translations',
        '/frontend-language',
        '/language/translations',
      ];
      
      bool success = false;
      
      for (String endpoint in possibleEndpoints) {
        debugPrint('🌐 [TranslationService] Denenen endpoint: ${AppConstants.baseUrl}$endpoint');
        
        try {
          final response = await http.get(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Accept-Language': languageCode,
            },
          );
          
          debugPrint('📊 [TranslationService] Status Code: ${response.statusCode}');
          //debugPrint('📊 [TranslationService] Response Headers: ${response.headers}');
          //debugPrint('📊 [TranslationService] Response Body: ${response.body}');
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            debugPrint('📊 [TranslationService] Parsed Data: $data');
            
            // API response formatını kontrol et
            if (data['translations'] != null) {
              // Yeni format: {"locale": "en", "translations": {...}}
              _translations = Map<String, String>.from(data['translations']);
              _currentLanguage = data['locale'] ?? languageCode;
              _isLoaded = true;
              debugPrint('✅ [TranslationService] Çeviriler yüklendi - Endpoint: $endpoint, Dil: $_currentLanguage, Sayı: ${_translations.length}');
              
              // İlk 5 çeviriyi göster
              int count = 0;
              _translations.forEach((key, value) {
                if (count < 5) {
                  debugPrint('🔑 [TranslationService] "$key": "$value"');
                  count++;
                }
              });
              success = true;
              break;
            } else if (data['status'] == true && data['data'] != null) {
              // Eski format: {"status": true, "data": {...}}
              _translations = Map<String, String>.from(data['data']);
              _currentLanguage = languageCode;
              _isLoaded = true;
              debugPrint('✅ [TranslationService] Çeviriler yüklendi (eski format) - Endpoint: $endpoint, Dil: $languageCode, Sayı: ${_translations.length}');
              
              // İlk 5 çeviriyi göster
              int count = 0;
              _translations.forEach((key, value) {
                if (count < 5) {
                  debugPrint('🔑 [TranslationService] "$key": "$value"');
                  count++;
                }
              });
              success = true;
              break;
            } else {
             // debugPrint('❌ [TranslationService] Geçersiz response formatı - Endpoint: $endpoint');
              debugPrint('📊 [TranslationService] Available keys: ${data.keys.toList()}');
            }
          } else {
            //debugPrint('❌ [TranslationService] HTTP Error: ${response.statusCode} - Endpoint: $endpoint');
            //debugPrint('❌ [TranslationService] Error Body: ${response.body}');
            
            // Error response'u parse etmeye çalış
            try {
              final errorData = jsonDecode(response.body);
              debugPrint('❌ [TranslationService] Error Message: ${errorData['message']}');
              debugPrint('❌ [TranslationService] Error Exception: ${errorData['exception']}');
            } catch (e) {
              //debugPrint('❌ [TranslationService] Error response parse edilemedi: $e');
            }
          }
        } catch (e) {
          //debugPrint('❌ [TranslationService] Endpoint $endpoint için exception: $e');
        }
      }
      
      if (!success) {
        //debugPrint('❌ [TranslationService] Hiçbir endpoint başarılı olmadı');
      }
      
    } catch (e) {
      //debugPrint('❌ [TranslationService] Exception: $e');
      //debugPrint('❌ [TranslationService] Exception Type: ${e.runtimeType}');
    } finally {
      isLoading.value = false;
      debugPrint('🏁 [TranslationService] loadTranslations tamamlandı');
    }
  }
  
  /// Change language and reload translations
  Future<void> changeLanguage(String languageCode) async {
    await loadTranslations(languageCode);
    // Trigger UI update
    Get.updateLocale(Locale(languageCode));
  }
  
  /// Get all available translations
  Map<String, String> get translations => _translations;
  
  /// Check if a key exists
  bool hasKey(String key) => _translations.containsKey(key);
  
  /// Get translation with fallback
  String tWithFallback(String key, String fallback) {
    return _translations[key] ?? fallback;
  }

  /// Fetch and debug print the frontend language endpoint data (for debug only)
  Future<void> debugFetchFrontendLanguage([String languageCode = 'tr']) async {
    debugPrint('🔍 [debugFetchFrontendLanguage] Başlatıldı - Dil: $languageCode');
    
    try {
      final authService = Get.find<AuthService>();
      final token = authService.getToken();
      if (token == null) {
        debugPrint('❌ [debugFetchFrontendLanguage] Token bulunamadı');
        return;
      }
      
      debugPrint('🔑 [debugFetchFrontendLanguage] Token: ${token.substring(0, 20)}...');
      
      // Farklı endpoint'leri dene
      final possibleEndpoints = [
        '/json-language',
        '/languages/json',
        '/translations',
        '/frontend-language',
        '/language/translations',
      ];
      
      for (String endpoint in possibleEndpoints) {
        debugPrint('🌐 [debugFetchFrontendLanguage] Denenen endpoint: ${AppConstants.baseUrl}$endpoint');
        
        try {
          final response = await http.get(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Accept-Language': languageCode,
            },
          );
          
          debugPrint('📊 [debugFetchFrontendLanguage] Status: ${response.statusCode}');
          debugPrint('📊 [debugFetchFrontendLanguage] Headers: ${response.headers}');
          debugPrint('📊 [debugFetchFrontendLanguage] Body: ${response.body}');
          
          if (response.statusCode == 200) {
            debugPrint('✅ [debugFetchFrontendLanguage] Başarılı endpoint bulundu: $endpoint');
            break;
          } else {
            try {
              final errorData = jsonDecode(response.body);
              debugPrint('❌ [debugFetchFrontendLanguage] Error Message: ${errorData['message']}');
              debugPrint('❌ [debugFetchFrontendLanguage] Error Exception: ${errorData['exception']}');
            } catch (e) {
              //debugPrint('❌ [debugFetchFrontendLanguage] Error parse edilemedi: $e');
            }
          }
        } catch (e) {
          //debugPrint('❌ [debugFetchFrontendLanguage] Endpoint $endpoint için exception: $e');
        }
      }
    } catch (e) {
      //debugPrint('❌ [debugFetchFrontendLanguage] Exception: $e');
      //debugPrint('❌ [debugFetchFrontendLanguage] Exception Type: ${e.runtimeType}');
    }
  }

  /// Debug method to test if translations are loaded
  void debugTranslations() {
    debugPrint('🔍 [TranslationService] Debug Translations:');
    debugPrint('📊 [TranslationService] Is Loaded: $_isLoaded');
    debugPrint('📊 [TranslationService] Current Language: $_currentLanguage');
    debugPrint('📊 [TranslationService] Translation Count: ${_translations.length}');
    
    if (_translations.isNotEmpty) {
      debugPrint('📊 [TranslationService] First 5 translations:');
      int count = 0;
      _translations.forEach((key, value) {
        if (count < 5) {
          debugPrint('   "$key": "$value"');
          count++;
        }
      });
    } else {
      //debugPrint('❌ [TranslationService] No translations loaded!');
    }
  }
}

// Extension for easy access
extension TranslationExtension on String {
  String get tr => TranslationService.to.t(this);
  String trWithFallback(String fallback) => TranslationService.to.tWithFallback(this, fallback);
} 