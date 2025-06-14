import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart'; // AppConstants burada
import '../../models/match_model.dart';

class MatchServices {
  static final _box = GetStorage(); // GetStorage ile token al
  static Future<bool> addLesson(String lessonName) async {
    final token = GetStorage().read('token');
    final url = Uri.parse("${AppConstants.baseUrl}/schools/lesson");

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"name": lessonName}), // 🔥 Düzeltildi: "name" olmalı
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body["status"] == true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

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

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body["status"] == true;
      } else {
        return false;
      }
    } catch (e) {
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

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body)['data'];
        if (data == null) return [];

        final match = MatchModel.fromJson(data);
        return [match];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
