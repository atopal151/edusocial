import 'dart:convert';
import 'dart:io';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../models/post_model.dart';

class PostServices {
  static final _box = GetStorage();

  /// Gönderi oluşturma fonksiyonu
  static Future<bool> createPost(String content, List<File> mediaFiles, {List<String>? links}) async {
    final token = _box.read('token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.baseUrl}/timeline/posts'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['content'] = content;

    // Linkleri ekle
    if (links != null && links.isNotEmpty) {
      for (int i = 0; i < links.length; i++) {
        request.fields['links[$i]'] = links[i];
      }
    }

    // 🔁 Her medya dosyası için MIME tipi ile yükleme
    for (var file in mediaFiles) {
      if (await file.exists()) {
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final parts = mimeType.split('/');

        request.files.add(
          await http.MultipartFile.fromPath(
            'media[]',
            file.path,
            contentType: MediaType(parts[0], parts[1]),
          ),
        );
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      /* debugPrint("📤 CreatePost Response: ${response.statusCode}");
      debugPrint("📤 CreatePost Body: ${response.body}");*/

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❗ Post gönderilemedi: $e");
      return false;
    }
  }

  /// Anasayfa gönderilerini getir
  static Future<List<PostModel>> fetchHomePosts() async {
    final token = _box.read('token');
    //debugPrint("🔄 PostServices.fetchHomePosts() çağrıldı");
    //debugPrint("🔑 Token: ${token != null ? 'Var' : 'Yok'}");

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/timeline/posts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      //debugPrint("📥 Postlar Response: ${response.statusCode}", wrapWidth: 1024);
      //debugPrint("📥 Postlar Body: ${response.body}", wrapWidth: 1024);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        /// Debug için JSON'u ham olarak gör
        //debugPrint("📦 [DEBUG - JSON RAW]:\n${jsonEncode(body)}", wrapWidth: 1024);

        final List posts = body['data']['data'];
        //debugPrint("📊 API'den ${posts.length} post alındı");

        final postList = posts.map((item) {
          //debugPrint("🔍 Post JSON: ${jsonEncode(item)}", wrapWidth: 1024);
          return PostModel.fromJson(item);
        }).toList();
        
        //debugPrint("✅ ${postList.length} post başarıyla parse edildi");
        return postList;
      } else {
        debugPrint("❌ API yanıtı başarısız: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("❗ Postlar alınamadı: $e", wrapWidth: 1024);
      return [];
    }
  }

  /// Belirli bir gönderinin detayını getirir
  static Future<PostModel?> fetchPostDetail(String postId) async {
    final token = _box.read('token');

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/timeline/posts/$postId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      //debugPrint("📥 Post Detail Response: ${response.statusCode}");
      //debugPrint("📥 Post Detail Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        return PostModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("❗ fetchPostDetail Hatası: $e");
      return null;
    }
  }

  // post like endpoint

  static Future<bool> toggleLike(String postId) async {
    final token = _box.read('token');

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/post-like'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'post_id': postId,
        },
      );

      //debugPrint("📤 Like Response: ${response.statusCode}");
      //debugPrint("📤 Like Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ toggleLike Hatası: $e");
      return false;
    }
  }

  //delete post
  static Future<bool> deletePost(String postId) async {
    final token = _box.read('token');

    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/timeline/posts/$postId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint("📤 Delete Post Response: ${response.statusCode}");
      debugPrint("📤 Delete Post Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ deletePost Hatası: $e");
      return false;
    }
  }

  /// Post şikayet etme fonksiyonu
  static Future<bool> reportPost(int postId) async {
    final token = _box.read('token');

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/post-report'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'post_id': postId,
        }),
      );

      debugPrint("📤 Report Post Response: ${response.statusCode}");
      debugPrint("📤 Report Post Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❌ reportPost Hatası: $e");
      return false;
    }
  }
}
