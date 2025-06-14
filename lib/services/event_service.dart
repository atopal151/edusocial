import 'dart:convert';
import 'package:edusocial/models/event_model.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EventServices {
  Future<List<EventModel>> fetchEvents() async {
    try {
      final token = GetStorage().read("token");

      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/events"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      /*debugPrint("📥 Events Response: ${response.statusCode}", wrapWidth: 1024);
      debugPrint("📥 Events Body: ${response.body}", wrapWidth: 1024);*/

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'];
        return data.map((e) => EventModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      /*debugPrint("❗ Events çekilirken hata: $e", wrapWidth: 1024);*/
      return [];
    }
  }
}
