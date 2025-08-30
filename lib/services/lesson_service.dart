import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class LessonService {
  static final GetStorage _box = GetStorage();

  /// Ders ekleme (ID döndüren versiyon)
  static Future<Map<String, dynamic>> addLessonWithId(String lessonName) async {
    try {
      final token = _box.read('token');
      if (token == null) {
        debugPrint("❌ Token bulunamadı");
        return {'success': false, 'id': null};
      }

      final url = Uri.parse('${AppConstants.baseUrl}/schools/lesson');
      

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': lessonName,
        }),
      );


      final data = jsonDecode(response.body);
      debugPrint("📥 Parsed Response Data: $data");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Ders başarıyla eklendi");
        
        // Ders ID'sini response'dan al
        int? lessonId;
        if (data["data"] != null && data["data"]["id"] != null) {
          lessonId = data["data"]["id"];
          debugPrint("🆔 Ders ID alındı: $lessonId");
        } else if (data["id"] != null) {
          lessonId = data["id"];
          debugPrint("🆔 Ders ID alındı: $lessonId");
        } else {
          debugPrint("⚠️ Ders ID response'da bulunamadı");
        }
        
        return {'success': true, 'id': lessonId};
      } else {
        debugPrint("❌ Ders ekleme başarısız");
        debugPrint("❌ Status Code: ${response.statusCode}");
        return {'success': false, 'id': null};
      }
    } catch (e, stackTrace) {
      debugPrint("💥 Ders ekleme hatası: $e");
      debugPrint("💥 Stack Trace: $stackTrace");
      return {'success': false, 'id': null};
    }
  }

  /// Ders ekleme (geriye uyumluluk için)
  static Future<bool> addLesson(String lessonName) async {
    final result = await addLessonWithId(lessonName);
    return result['success'] as bool;
  }






}
