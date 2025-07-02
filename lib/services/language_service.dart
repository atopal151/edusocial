import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      print('Dil yükleme hatası: $e');
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
      
      print('Dil değiştirildi: $languageCode');
    } catch (e) {
      print('Dil değiştirme hatası: $e');
    }
  }

  /// Çeviri dosyasını yükle
  Future<void> _loadTranslations(String languageCode) async {
    try {
      final jsonString = await rootBundle.loadString('assets/translations/$languageCode.json');
      final Map<String, dynamic> loadedTranslations = json.decode(jsonString);
      translations.value = loadedTranslations;
    } catch (e) {
      print('Çeviri dosyası yükleme hatası: $e');
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
      print('Dil kaydetme hatası: $e');
    }
  }

  /// Çeviri al
  String tr(String key) {
    try {
      final keys = key.split('.');
      dynamic value = translations.value;
      
      for (final k in keys) {
        if (value is Map && value.containsKey(k)) {
          value = value[k];
        } else {
          return key; // Anahtar bulunamadıysa anahtarı döndür
        }
      }
      
      return value?.toString() ?? key;
    } catch (e) {
      print('Çeviri hatası ($key): $e');
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
} 