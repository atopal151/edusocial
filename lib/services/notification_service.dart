import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import '../utils/constants.dart';

class NotificationService {
  static final _box = GetStorage();

  /// 📥 Mobil bildirimleri çek
  static Future<List<NotificationModel>> fetchMobileNotifications() async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/notifications/mobile");

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final List data = jsonBody['data'] ?? [];

        return data.map((e) => NotificationModel(
          id: e['id'].toString(),
          userId: e['user_id'].toString(),
          userName: e['user_name'] ?? '',
          profileImageUrl: e['profile_image_url'] ?? '',
          type: e['type'] ?? 'other',
          message: e['message'] ?? '',
          timestamp: DateTime.tryParse(e['created_at'] ?? '') ?? DateTime.now(),
          isRead: e['is_read'] == 1 || e['is_read'] == true,
        )).toList();
      } else {
        throw Exception('Bildirimler alınamadı. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❗ Bildirim servisi hatası: $e");
      rethrow;
    }
  }
}
