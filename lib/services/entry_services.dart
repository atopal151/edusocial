import 'dart:convert';
import 'package:edusocial/models/entry_model.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class EntryServices {
  static Future<List<EntryModel>> fetchTimelineEntries() async {
    final token = GetStorage().read("token");

    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/timeline/entries"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      //debugPrint("📥 Entry Response: ${response.statusCode}", wrapWidth: 1024);
      //debugPrint("📥 Entry Body: ${response.body}", wrapWidth: 1024);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        return data.map((e) => EntryModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❗ Entry API error: $e", wrapWidth: 1024);
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

        //debugPrint(" $data",wrapWidth: 1024);
        final Map<String, int> result = {};
        for (var item in data) {
          final name = item["name"];
          final id = item["id"];

          if (name != null && id != null) {
            result[name.toString()] = id;
          }
        }
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
