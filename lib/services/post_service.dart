import 'dart:convert';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../models/post_model.dart';

class PostServices {
  static final _box = GetStorage();

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

      debugPrint("📥 Postlar Response: ${response.statusCode}",wrapWidth: 1024);
      debugPrint("📥 Postlar Body: ${response.body}",wrapWidth: 1024);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        return data.map((item) => PostModel(
          profileImage: item['user']['avatar'] ?? '',
          userName: item['user']['username'] ?? '',
          postDate: item['created_at'] ?? '',
          postDescription: item['description'] ?? '',
          postImage: item['image'] ?? '',
          likeCount: item['like_count'] ?? 0,
          commentCount: item['comment_count'] ?? 0,
        )).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❗ Postlar alınamadı: $e",wrapWidth: 1024);
      return [];
    }
  }
}
