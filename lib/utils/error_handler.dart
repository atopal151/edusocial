import 'dart:io';
import 'dart:convert'; // Added for json.decode
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorHandler {
  /// 🚨 Global hata yakalayıcı
  static void handleError(dynamic error, {String? userMessage, bool showSnackbar = true}) {
    final errorMessage = _getErrorMessage(error);
    final displayMessage = userMessage ?? errorMessage;
    
    debugPrint('❌ Error caught: $error');
    debugPrint('🔍 Error type: ${error.runtimeType}');
    
    if (showSnackbar && Get.context != null) {
      _showErrorSnackbar(displayMessage);
    }
  }

  /// 🌐 API hata yönetimi
  static void handleApiError(int? statusCode, String? responseBody, {String? customMessage}) {
    String message;
    
    switch (statusCode) {
      case 400:
        message = customMessage ?? 'Geçersiz istek. Lütfen bilgilerinizi kontrol edin.';
        break;
      case 401:
        message = 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.';
        _handleUnauthorized();
        break;
      case 403:
        message = customMessage ?? 'Bu işlem için yetkiniz bulunmuyor.';
        break;
      case 404:
        message = customMessage ?? 'İstenen kaynak bulunamadı.';
        break;
      case 422:
        message = _parseValidationErrors(responseBody) ?? 'Girilen bilgiler geçerli değil.';
        break;
      case 429:
        message = 'Çok fazla istek gönderdiniz. Lütfen daha sonra tekrar deneyin.';
        break;
      case 500:
        message = customMessage ?? 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.';
        break;
      case 503:
        message = 'Servis geçici olarak kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
        break;
      default:
        message = customMessage ?? 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
    }
    
    debugPrint('🌐 API Error - Status: $statusCode, Message: $message');
    _showErrorSnackbar(message);
  }

  /// 🔒 Network hata yönetimi
  static void handleNetworkError(dynamic error) {
    String message;
    
    if (error is SocketException) {
      message = 'İnternet bağlantınızı kontrol edin.';
    } else if (error is TimeoutException) {
      message = 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';
    } else {
      message = 'Bağlantı hatası oluştu. Lütfen tekrar deneyin.';
    }
    
    debugPrint('🔒 Network Error: $error');
    _showErrorSnackbar(message);
  }

  /// 📱 Form validation hatası
  static void handleValidationError(String message) {
    debugPrint('📱 Validation Error: $message');
    _showErrorSnackbar(message, backgroundColor: Colors.orange);
  }

  /// ✅ Başarı mesajı
  static void showSuccess(String message) {
    debugPrint('✅ Success: $message');
    Get.snackbar(
      'Başarılı',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      shouldIconPulse: false,
    );
  }

  /// ⚠️ Uyarı mesajı
  static void showWarning(String message) {
    debugPrint('⚠️ Warning: $message');
    Get.snackbar(
      'Uyarı',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.warning, color: Colors.white),
      shouldIconPulse: false,
    );
  }

  /// 🔄 Loading dialog göster
  static void showLoading({String message = 'Yükleniyor...'}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Geri tuşu ile kapatılmasın
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(message),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// 🔄 Loading dialog kapat
  static void hideLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  // Private methods
  static String _getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return 'Beklenmeyen bir hata oluştu';
  }

  static void _showErrorSnackbar(String message, {Color? backgroundColor}) {
    Get.snackbar(
      'Hata',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor ?? Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
      shouldIconPulse: false,
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Tamam', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  static void _handleUnauthorized() {
    // Token'ı temizle ve login sayfasına yönlendir
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed('/login');
    });
  }

  static String? _parseValidationErrors(String? responseBody) {
    // Laravel validation error parsing
    try {
      if (responseBody == null) return null;
      
      final decoded = json.decode(responseBody);
      if (decoded is Map && decoded.containsKey('errors')) {
        final errors = decoded['errors'] as Map;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
} 