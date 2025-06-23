import 'dart:convert';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';

class ProfileService {
  final box = GetStorage();

  Future<ProfileModel> fetchProfileData() async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("${AppConstants.baseUrl}/me"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    debugPrint("📥 ProfileService - HTTP Status Code: ${response.statusCode}");
    debugPrint("📦 ProfileService - Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      
      // Post verilerini debug et
      if (jsonBody['data'] != null && jsonBody['data']['posts'] != null) {
        final posts = jsonBody['data']['posts'] as List;
        debugPrint("📝 ProfileService - Post sayısı: ${posts.length}");
        
        for (int i = 0; i < posts.length; i++) {
          final post = posts[i];
          debugPrint("📝 Post $i:");
          debugPrint("  - ID: ${post['id']}");
          debugPrint("  - Content: ${post['content']}");
          debugPrint("  - Links: ${post['links']}");
          debugPrint("  - Media: ${post['media']}");
        }
      }
      
      return ProfileModel.fromJson(jsonBody['data']);
    } else {
      throw Exception("❗ Profil verisi alınamadı: ${response.body}");
    }
  }
}
