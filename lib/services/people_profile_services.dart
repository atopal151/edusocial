import 'dart:convert';
import 'package:edusocial/models/people_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class PeopleProfileService {
  static final box = GetStorage();

  static Future<PeopleProfileModel?> fetchUserById(int userId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/user/find-by-id/$userId');
    final token = box.read('token');

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );
      //debugPrint("📥 [fetchUserById] Status: ${response.statusCode}");
      //debugPrint("📥 [fetchUserById] Body: ${response.body}", wrapWidth: 1024);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return PeopleProfileModel.fromJson(body['data']);
      } else {
       // debugPrint("❌ [fetchUserById] API başarısız: ${response.statusCode}");
        //debugPrint("❌ [fetchUserById] Body: ${response.body}", wrapWidth: 1024);
        return null;
      }
    } catch (e) {
      print("❗ fetchUserById error: $e");
      return null;
    }
  }

  static Future<bool> followUser(int userId) async {
    try {
      final token = GetStorage().read('token');

      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}/user/follow"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"user_id": userId}),
      );

      /*  debugPrint("📥 Follow response: ${response.statusCode}");
    debugPrint("📥 Body: ${response.body}");*/

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body["status"] == true; // ✅ DÜZELTİLEN KISIM
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("❌ followUser hata: $e", wrapWidth: 1024);
      return false;
    }
  }

  static Future<bool> unfollowUser(int userId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/user/unfollow');
    final token = box.read('token');

    try {
      /*  debugPrint("📤 Unfollow request sending to: $url");
    debugPrint("📤 Payload: { user_id: $userId }");*/

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"user_id": userId}),
      );

      /*debugPrint("📥 Unfollow response: ${response.statusCode}");
    debugPrint("📥 Unfollow body: ${response.body}");*/

      final body = jsonDecode(response.body);

      // 🔁 Başarı durumu kontrolü
      if (response.statusCode == 200 && body['status'] == true) {
        return true;
      }

      // ⚠️ Zaten unfollow edilmişse yine true say
      if (response.statusCode == 404 &&
          (body['message']
                  ?.toString()
                  .toLowerCase()
                  .contains("already unfollowed") ??
              false)) {
        debugPrint("⚠️ Kullanıcı zaten takip edilmiyor.");
        return true;
      }

      return false;
    } catch (e) {
      print("❗ unfollowUser error: $e");
      return false;
    }
  }
}
