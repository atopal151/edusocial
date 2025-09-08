import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'api_service.dart';

class VerificationService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  /// Kullanıcı hesap doğrulama
  /// [file] Yüklenecek belge dosyası
  /// [documentType] Belge türü (passport, id_card, driver_license)
  Future<Map<String, dynamic>> verifyUser(File file, String documentType) async {
    try {
      // Token'ı al
      final token = _storage.read('token');
      if (token == null) {
        throw Exception('Token bulunamadı');
      }

      // Form data oluştur
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'document_type': documentType,
      });

      // Headers
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      };

      // API çağrısı
      final response = await _apiService.post(
        '/verify-user',
        formData,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Doğrulama başarıyla gönderildi',
        };
      } else {
        return {
          'success': false,
          'message': 'Doğrulama başarısız: ${response.statusMessage}',
        };
      }
    } catch (e) {
      debugPrint('❌ VerificationService.verifyUser hatası: $e');
      
      // 422 hatası için özel mesaj
      if (e.toString().contains('422')) {
        return {
          'success': false,
          'message': 'Dosya formatı veya içeriği uygun değil. Lütfen farklı bir dosya deneyin.',
        };
      }
      
      // DioException için detaylı hata mesajı
      if (e is dio.DioException) {
        String errorMessage = 'Doğrulama sırasında bir hata oluştu';
        
        if (e.response?.statusCode == 422) {
          errorMessage = 'Dosya formatı veya içeriği uygun değil. Lütfen farklı bir dosya deneyin.';
        } else if (e.response?.statusCode == 413) {
          errorMessage = 'Dosya boyutu çok büyük. Lütfen daha küçük bir dosya seçin.';
        } else if (e.response?.statusCode == 415) {
          errorMessage = 'Desteklenmeyen dosya formatı. Lütfen JPG, PNG veya PDF formatında bir dosya seçin.';
        }
        
        return {
          'success': false,
          'message': errorMessage,
        };
      }
      
      return {
        'success': false,
        'message': 'Doğrulama sırasında bir hata oluştu: $e',
      };
    }
  }

  /// Belge türlerini getir
  List<String> getDocumentTypes() {
    return ['passport', 'id_card', 'driver_license'];
  }

  /// Belge türü adını getir
  String getDocumentTypeName(String documentType) {
    switch (documentType) {
      case 'passport':
        return 'Pasaport';
      case 'id_card':
        return 'Kimlik Kartı';
      case 'driver_license':
        return 'Sürücü Belgesi';
      default:
        return 'Bilinmeyen Belge';
    }
  }

  /// Dosya boyutu kontrolü (10MB limit)
  bool isValidFileSize(File file) {
    const int maxSizeInBytes = 10 * 1024 * 1024; // 10MB
    return file.lengthSync() <= maxSizeInBytes;
  }

  /// Dosya türü kontrolü
  bool isValidFileType(File file) {
    final fileName = file.path.toLowerCase();
    return fileName.endsWith('.jpg') || 
           fileName.endsWith('.jpeg') || 
           fileName.endsWith('.png') ||
           fileName.endsWith('.pdf');
  }
}
