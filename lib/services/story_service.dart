import 'dart:convert';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
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

      //debugPrint("📥 Story Response: ${response.statusCode}", wrapWidth: 1024);
      //debugPrint("📥 Story Body: ${response.body}", wrapWidth: 1024);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body["data"];
        return data.map((json) => StoryModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❗ Story çekilirken hata: $e", wrapWidth: 1024);
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

   // debugPrint("📥 Story Detail Response: ${response.statusCode}");
    //debugPrint("📥 Story Detail Body: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body["data"];

      // Eğer her bir item bir story içeriğiyse ve içinde "url" varsa:
      return data.map<String>((item) => item["url"].toString()).toList();
    } else {
      return [];
    }
  } catch (e) {
    debugPrint("❗ fetchStoriesByUserId() hatası: $e");
    return [];
  }
}

}
