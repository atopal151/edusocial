import 'dart:convert';
import 'package:edusocial/models/entry_model.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class EntryServices {

static Future<List<EntryModel>> fetchEntriesByTopicId(int topicId) async {
  final token = GetStorage().read("token");

  try {
    final response = await http.get(
      Uri.parse("${AppConstants.baseUrl}/timeline/topics/$topicId"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    debugPrint("📥 Entry category id Body: ${response.body}", wrapWidth: 1024);

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final data = jsonBody["data"];
      debugPrint("📥 Gelen Response: ${response.body}");

      // 🔁 "entrys" anahtarına dikkat!
      if (data != null && data["entrys"] != null) {
        final List<dynamic> entryList = data["entrys"];
        return entryList.map((e) => EntryModel.fromJson(e)).toList();
      } else {
        debugPrint("⚠️ 'entrys' alanı boş veya yok.");
        return [];
      }
    } else {
      debugPrint("⚠️ Topic entries response failed: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    debugPrint("❗ fetchEntriesByTopicId error: $e");
    return [];
  }
}


  static Future<Map<String, int>> fetchTopicCategories() async {
    final token = GetStorage().read("token");

    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/topic-categories"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final List data = jsonBody["data"];

        debugPrint("📥 Status Code: ${response.statusCode}");
        debugPrint("📥 Body: ${response.body}");
        debugPrint("📦 RAW DATA: $data");

        final Map<String, int> result = {};
        for (var item in data) {
          final name = item["title"]; // ✅ DÜZELTİLDİ
          final id = item["id"];

          if (name != null && id != null) {
            result[name.toString()] = id;
          }
        }

        debugPrint("📦 Topic Category Map: $result");
        return result;
      } else {
        return {};
      }
    } catch (e) {
      debugPrint("❗ Topic Categories error: $e");
      return {};
    }
  }

  static Future<bool> createTopicWithEntry({
    required String name,
    required String content,
    required int topicCategoryId,
  }) async {
    final token = GetStorage().read("token");

    try {
      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}/timeline/topics"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "content": content,
          "topic_category_id": topicCategoryId,
        }),
      );

      /*  debugPrint("📤 Create Topic Response: ${response.statusCode}");
      debugPrint("📤 Create Topic Body: ${response.body}");*/

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❗ Create Topic error: $e");
      return false;
    }
  }
}
