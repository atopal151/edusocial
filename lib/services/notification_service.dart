import 'dart:convert';
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

      /*debugPrint("📥 notifications Response: ${response.statusCode}", wrapWidth: 1024);
      debugPrint("📥 notifications Body: ${response.body}", wrapWidth: 1024);*/

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

        return allNotifs.map((e) => NotificationModel.fromJson(e)).toList();
      } else {
        throw Exception('Bildirimler alınamadı. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      /*debugPrint("❗ Bildirim servisi hatası: $e", wrapWidth: 1024);*/
      rethrow;
    }
  }

  /// Takip isteğini kabul veya reddet
  static Future<bool> acceptOrDeclineFollowRequest({
    required String userId,
    required String decision, // "accept" veya "decline"
  }) async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/follow-invitation");

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

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Takip isteği onaylanamadı: \\${response.body}');
    }
  }

  /// Grup katılma isteğini kabul veya reddet
  static Future<bool> acceptOrDeclineGroupJoinRequest({
    required String userId,
    required String groupId,
    required String decision, // "accept" veya "decline"
  }) async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/group-invitation");

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

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Grup katılma isteği onaylanamadı: \\${response.body}');
    }
  }
}
