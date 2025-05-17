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

      debugPrint("📥 Entry Response: ${response.statusCode}",wrapWidth: 1024);
      debugPrint("📥 Entry Body: ${response.body}",wrapWidth: 1024);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        return data.map((e) => EntryModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❗ Entry API error: $e",wrapWidth: 1024);
      return [];
    }
  }
}
