import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart'; // AppConstants burada
import '../../models/match_model.dart';

class MatchServices {
  static final _box = GetStorage(); // GetStorage ile token al

  static Future<bool> followUser(int userId) async {
    final token = GetStorage().read('token');
    final url = Uri.parse("${AppConstants.baseUrl}/user/follow");

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"user_id": userId}),
      );

     //debugPrint("📥 Match Follow Response: ${response.statusCode}");
      //debugPrint("📥 Match Follow Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body["status"] == true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("❌ Match follow error: $e", wrapWidth: 1024);
      return false;
    }
  }

  static Future<List<MatchModel>> fetchMatches() async {
    final token = _box.read('token');

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/match-user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      //debugPrint("📥 Match Response: ${response.statusCode}", wrapWidth: 1024);
      //debugPrint("📥 Match Body: ${response.body}", wrapWidth: 1024);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body)['data'];
        final MatchModel match = MatchModel.fromJson(data);
        return [match];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❗ Match verileri alınamadı: $e", wrapWidth: 1024);
      return [];
    }
  }
}
