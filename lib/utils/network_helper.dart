import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkHelper {
  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('🌐 Internet connectivity check failed: $e');
      return false;
    }
  }

  /// Check specific server connectivity
  static Future<bool> canReachServer(String host) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 3));
      
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('🌐 Server connectivity check failed for $host: $e');
      return false;
    }
  }

  /// Get user-friendly error message based on exception type
  static String getNetworkErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socketexception') || 
        errorString.contains('connection reset by peer')) {
      return 'İnternet bağlantısı sorunu. Bağlantınızı kontrol edin.';
    } else if (errorString.contains('timeout')) {
      return 'İstek zaman aşımına uğradı. Tekrar deneyin.';
    } else if (errorString.contains('host lookup failed') || 
               errorString.contains('failed host lookup')) {
      return 'Sunucuya erişilemiyor. DNS ayarlarınızı kontrol edin.';
    } else if (errorString.contains('certificate') || 
               errorString.contains('ssl') || 
               errorString.contains('tls')) {
      return 'Güvenlik sertifikası hatası. Uygulama güncellemesi gerekebilir.';
    } else if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Yetkilendirme hatası. Tekrar giriş yapın.';
    } else if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'Bu işlem için yetkiniz yok.';
    } else if (errorString.contains('404') || errorString.contains('not found')) {
      return 'İstenen kaynak bulunamadı.';
    } else if (errorString.contains('500') || errorString.contains('internal server error')) {
      return 'Sunucu hatası. Daha sonra tekrar deneyin.';
    } else if (errorString.contains('502') || errorString.contains('bad gateway')) {
      return 'Ağ geçidi hatası. Sunucu geçici olarak erişilemez.';
    } else if (errorString.contains('503') || errorString.contains('service unavailable')) {
      return 'Servis geçici olarak kullanılamıyor.';
    }
    
    return 'Beklenmeyen bir hata oluştu. Tekrar deneyin.';
  }

  /// Check if error is retryable
  static bool isRetryableError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Don't retry client errors (4xx)
    if (errorString.contains('401') || errorString.contains('403') || 
        errorString.contains('404') || errorString.contains('400')) {
      return false;
    }
    
    // Retry network and server errors
    return errorString.contains('socketexception') ||
           errorString.contains('timeout') ||
           errorString.contains('connection reset') ||
           errorString.contains('500') ||
           errorString.contains('502') ||
           errorString.contains('503');
  }
} 