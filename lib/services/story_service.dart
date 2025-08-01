import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../models/story_model.dart';

class StoryService {
  static final box = GetStorage();

  static Future<List<StoryModel>> fetchStories() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/timeline/stories"),
        headers: {
          "Authorization": "Bearer ${box.read('token')}",
        },
      );

      // debugPrint("📥 Storyy Response: ${response.statusCode}", wrapWidth: 1024);
      // debugPrint("📥 Story Body: ${response.body}", wrapWidth: 1024);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body["data"];
        return data.map((json) => StoryModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      // debugPrint("❗ Story çekilirken hata: $e", wrapWidth: 1024);
      return [];
    }
  }

  static Future<List<String>> fetchStoriesByUserId(String userId) async {
    final token = GetStorage().read('token');

    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/timeline/stories/$userId"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // debugPrint("📥 Story uıd: $userId");
      // debugPrint("📥 Story Detail Response: ${response.statusCode}");
      // debugPrint("📥 Story Detail Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final userBlock = body["data"];

        // Eğer data doğrudan stories listesi ise:
        final stories = userBlock["stories"] ?? [];

        return stories.map<String>((item) => item["path"].toString()).toList();
      } else {
        return [];
      }
    } catch (e) {
      // debugPrint("❗ fetchStoriesByUserId() hatası: $e");
      return [];
    }
  }

  /// Tek hikaye oluştur (eski metod - geriye dönük uyumluluk için)
  static Future<bool> createStory(File mediaFile) async {
    return await createMultipleStories([mediaFile]);
  }

  /// Birden fazla hikaye oluştur
  static Future<bool> createMultipleStories(List<File> mediaFiles) async {
    if (mediaFiles.isEmpty) return false;

    final token = box.read('token');
    int successCount = 0;

    try {
      // Her dosya için ayrı ayrı story oluştur
      for (File mediaFile in mediaFiles) {
        final uri = Uri.parse("${AppConstants.baseUrl}/timeline/stories");

        // MIME tipini dosya uzantısından al
        final mimeType = lookupMimeType(mediaFile.path) ?? 'image/jpeg';

        // İstek oluştur
        var request = http.MultipartRequest('POST', uri);
        request.headers['Authorization'] = 'Bearer $token';

        // Dosyayı ekle
        final multipartFile = await http.MultipartFile.fromPath(
          'media', // 🟡 Bu alan Postman'de neyse onunla aynı olmalı!
          mediaFile.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);

        // İsteği gönder
        final response = await request.send();

        if (response.statusCode == 200) {
          successCount++;
          debugPrint("✅ Story $successCount/${mediaFiles.length} başarıyla yüklendi.");
        } else {
          debugPrint("❌ Story yükleme başarısız. Status: ${response.statusCode}");
        }
      }

      // En az bir story başarılı ise true döndür
      final isSuccess = successCount > 0;
      
      if (isSuccess) {
        debugPrint("✅ Toplam $successCount/${mediaFiles.length} story başarıyla yüklendi.");
      } else {
        debugPrint("❌ Hiçbir story yüklenemedi.");
      }

      return isSuccess;
    } catch (e) {
      debugPrint("❗ createMultipleStories hatası: $e");
      return false;
    }
  }
}
