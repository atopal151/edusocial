import 'dart:convert';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../models/hot_topics_model.dart';

class HotTopicsService {

  Future<List<HotTopicsModel>> fetchHotTopics() async {
    try {
      final box = GetStorage();
      final token = box.read("token");

      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/timeline/topics"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

     debugPrint("📥 Topics Response: ${response.statusCode}",wrapWidth: 1024);
      debugPrint("📥 Topics Body: ${response.body}",wrapWidth: 1024);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final dataList = jsonData['data'] as List;
        return dataList
            .map((json) => HotTopicsModel.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❗ Topics alınırken hata: $e",wrapWidth: 1024);
      return [];
    }
  }
}
