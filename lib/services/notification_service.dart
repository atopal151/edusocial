import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import '../utils/constants.dart';

class NotificationService {
  static final _box = GetStorage();

  /// Tüm bildirimleri çek
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

        final postNotifs = jsonBody['data']?['post_notifications'] ?? [];
        final invitationNotifs = jsonBody['data']?['invitation_notifications'] ?? [];
        final followerNotifs = jsonBody['data']?['follower_notifications'] ?? [];


        final allNotifs = [
          ...postNotifs,
          ...invitationNotifs,
          ...followerNotifs
        ];

        // Bildirimleri created_at tarihine göre sırala (en yeni en üstte)
        allNotifs.sort((a, b) {
          final aCreatedAt = a['created_at'] ?? '';
          final bCreatedAt = b['created_at'] ?? '';
          
          if (aCreatedAt.isEmpty && bCreatedAt.isEmpty) return 0;
          if (aCreatedAt.isEmpty) return 1; // Boş tarih en alta
          if (bCreatedAt.isEmpty) return -1; // Boş tarih en alta
          
          final aDate = DateTime.tryParse(aCreatedAt);
          final bDate = DateTime.tryParse(bCreatedAt);
          
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1; // Geçersiz tarih en alta
          if (bDate == null) return -1; // Geçersiz tarih en alta
          
          // En yeni tarih en üstte olacak şekilde sırala
          return bDate.compareTo(aDate);
        });

        return allNotifs.map((e) => NotificationModel.fromJson(e)).toList();
      } else {
        throw Exception('Bildirimler alınamadı. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❗ Bildirim servisi hatası: $e", wrapWidth: 1024);
      rethrow;
    }
  }

  /// Takip isteğini kabul veya reddet
  static Future<Map<String, dynamic>> acceptOrDeclineFollowRequest({
    required String userId,
    required String decision, // "accept" veya "decline"
  }) async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/follow-invitation");

    try {
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": int.tryParse(userId) ?? userId,
          "decision": decision,
        }),
      );


      final jsonResponse = jsonDecode(response.body);
      
      // 422 hatası "already responded" durumu için
      if (response.statusCode == 422) {
        final message = jsonResponse['message'] ?? '';
        if (message.contains('already.responded')) {
          // Bu durumda başarılı olarak kabul et, çünkü istek zaten yanıtlanmış
          return {
            'status': true,
            'message': 'İstek zaten yanıtlanmış',
            'already_responded': true
          };
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        throw Exception('Takip isteği onaylanamadı: ${response.body}');
      }
    } catch (e) {
      debugPrint("❗ Follow request error: $e");
      rethrow;
    }
  }

  /// Kullanıcıyı takip et
  static Future<Map<String, dynamic>> followUser({
    required String userId,
  }) async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/user/follow");

    try {
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": int.tryParse(userId) ?? userId,
        }),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Takip işlemi başarısız: ${response.body}');
      }
    } catch (e) {
      debugPrint("❗ Follow user error: $e");
      rethrow;
    }
  }

  /// Kullanıcıyı takipten çıkar
  static Future<Map<String, dynamic>> unfollowUser({
    required String userId,
  }) async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/user/unfollow");

    try {
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": int.tryParse(userId) ?? userId,
        }),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Takipten çıkarma işlemi başarısız: ${response.body}');
      }
    } catch (e) {
      debugPrint("❗ Unfollow user error: $e");
      rethrow;
    }
  }

  /// Grup katılma isteğini kabul veya reddet
  static Future<Map<String, dynamic>> acceptOrDeclineGroupJoinRequest({
    required String userId,
    required String groupId,
    required String decision, // "accept" veya "decline"
  }) async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/group-invitation");

    try {
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": int.tryParse(userId) ?? userId,
          "group_id": int.tryParse(groupId) ?? groupId,
          "decision": decision,
        }),
      );


      final jsonResponse = jsonDecode(response.body);
      
      // 422 hatası "already responded" durumu için
      if (response.statusCode == 422) {
        final message = jsonResponse['message'] ?? '';
        if (message.contains('already.responded')) {
          // Bu durumda başarılı olarak kabul et, çünkü istek zaten yanıtlanmış
          return {
            'status': true,
            'message': 'İstek zaten yanıtlanmış',
            'already_responded': true
          };
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        throw Exception('Grup katılma isteği onaylanamadı: ${response.body}');
      }
    } catch (e) {
      debugPrint("❗ Group join request error: $e");
      rethrow;
    }
  }

  /// Etkinlik oluşturma isteğini kabul veya reddet
  static Future<bool> acceptOrDeclineEventCreateRequest({
    required String userId,
    required String groupId,
    required String eventId,
    required String decision, // "accept" veya "decline"
  }) async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/event-invitation");

    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "user_id": int.tryParse(userId) ?? userId,
        "group_id": int.tryParse(groupId) ?? groupId,
        "event_id": int.tryParse(eventId) ?? eventId,
        "decision": decision,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Etkinlik oluşturma isteği onaylanamadı: \\${response.body}');
    }
  }


}
