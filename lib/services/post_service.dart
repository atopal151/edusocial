import 'dart:convert';
import 'dart:io';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../models/post_model.dart';

class PostServices {
  static final _box = GetStorage();

  static Future<bool> createPost(String content, List<File> mediaFiles) async {
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

    for (var file in mediaFiles) {
      request.files
          .add(await http.MultipartFile.fromPath('media[]', file.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("📤 CreatePost Response: ${response.statusCode}");
      debugPrint("📤 CreatePost Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❗ Post gönderilemedi: $e");
      return false;
    }
  }

  static Future<List<PostModel>> fetchHomePosts() async {
  final token = _box.read('token');

  try {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/timeline/posts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    debugPrint("📥 Postlar Response: ${response.statusCode}",
        wrapWidth: 1024);
    debugPrint("📥 Postlar Body: ${response.body}", wrapWidth: 1024);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      /// Debug için JSON'u ham olarak gör
      debugPrint("📦 [DEBUG - JSON RAW]:\n${jsonEncode(body)}", wrapWidth: 1024);

      final List posts = body['data']['data'];

      return posts.map((item) {
        debugPrint("🔍 Post JSON: ${jsonEncode(item)}", wrapWidth: 1024); // Her post objesini tek tek yaz

        return PostModel.fromJson(item);
      }).toList();
    } else {
      return [];
    }
  } catch (e) {
    debugPrint("❗ Postlar alınamadı: $e", wrapWidth: 1024);
    return [];
  }
}

}
