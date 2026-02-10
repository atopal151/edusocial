import 'dart:convert';
import 'package:edusocial/components/print_full_text.dart';
import 'package:edusocial/models/people_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class PeopleProfileService {
  static final box = GetStorage();

  static Future<PeopleProfileModel?> fetchUserByUsername(
      String username) async {
    final url =
        Uri.parse('${AppConstants.baseUrl}/user/find-by-username/$username');
    final token = box.read('token');

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10)); // 10 saniye timeout

      if (response.statusCode == 200) {
        // API'dan gelen ham people profile response datasını printfulltext ile yazdır
        //printFullText('👥 [PeopleProfileService] User Profile API Response: ${response.body}');
        
        final body = jsonDecode(response.body);
        

        final model = PeopleProfileModel.fromJson(body['data']);

        return model;
      } else {
        debugPrint(
            "❌ [fetchUserByUsername] API başarısız: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ fetchUserByUsername error: $e");
      return null;
    }
  }

  static Future<PeopleProfileModel?> fetchUserById(int userId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/user/find-by-id/$userId');
    final token = box.read('token');

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 8)); // 8 saniye timeout

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        

        if (body['data'] != null) {
          final userData = body['data'];

          // Tüm avatar ile ilgili alanları kontrol et
          userData.forEach((key, value) {
            if (key.toString().toLowerCase().contains('avatar') ||
                key.toString().toLowerCase().contains('image') ||
                key.toString().toLowerCase().contains('photo') ||
                key.toString().toLowerCase().contains('profile')) {
            }
          });
        }

        return PeopleProfileModel.fromJson(body['data']);
      } else {
        debugPrint("❌ [fetchUserById] API başarısız: ${response.statusCode}");
        debugPrint("❌ Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❗ fetchUserById error: $e");
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

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body["status"] == true;
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
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"user_id": userId}),
      );

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
      debugPrint("❗ unfollowUser error: $e");
      return false;
    }
  }

  /// Tek API çağrısı ile takip listesini getirir.
  /// API cevabı: data.followers.data (takipçiler) ve data.followings.data (takip edilenler).
  static Future<Map<String, List<Map<String, dynamic>>>> fetchUserFollowList(
    int userId, {
    int page = 1,
    int perPage = 50,
  }) async {
    final url = Uri.parse('${AppConstants.frontendBaseUrl}/user/follow').replace(
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'user_id': userId.toString(),
      },
    );
    final token = box.read('token');

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint(
            "❌ [fetchUserFollowList] API başarısız: ${response.statusCode}");
        return {'followers': [], 'followings': []};
      }

      // Ham API cevabını debug et (frontend/user/follow endpoint)
      printFullText('👥 =======================================');
      printFullText('👥 [PeopleProfileService] /frontend/user/follow API Ham Veri');
      printFullText('👥 =======================================');
      printFullText('👥 URL: $url');
      printFullText('👥 Status Code: ${response.statusCode}');
      printFullText('👥 Response Body: ${response.body}');
      printFullText('👥 =======================================');

      final body = jsonDecode(response.body);
      final data = body['data'];

      if (data == null || data is! Map<String, dynamic>) {
        return {'followers': [], 'followings': []};
      }

      final rawFollowers = _extractPaginatedDataList(data['followers']);
      final rawFollowings = _extractPaginatedDataList(data['followings']);

      final followers = rawFollowers
          .map((e) => _userFollowItemToMap(e as Map<String, dynamic>))
          .toList();
      final followings = rawFollowings
          .map((e) => _userFollowItemToMap(e as Map<String, dynamic>))
          .toList();

      return {'followers': followers, 'followings': followings};
    } catch (e) {
      debugPrint("❌ fetchUserFollowList error: $e");
      return {'followers': [], 'followings': []};
    }
  }

  /// data.followers / data.followings gibi { data: [...], meta: {} } yapısından listeyi çıkarır
  static List<dynamic> _extractPaginatedDataList(dynamic section) {
    if (section == null) return [];
    if (section is Map<String, dynamic>) {
      final inner = section['data'];
      if (inner is List<dynamic>) return inner;
    }
    return [];
  }

  /// Takipçi listesi (data.followers.data)
  static Future<List<Map<String, dynamic>>> fetchUserFollowers(
    int userId, {
    int page = 1,
    int perPage = 50,
  }) async {
    final result = await fetchUserFollowList(userId, page: page, perPage: perPage);
    return result['followers'] ?? [];
  }

  /// Takip edilen listesi (data.followings.data)
  static Future<List<Map<String, dynamic>>> fetchUserFollowing(
    int userId, {
    int page = 1,
    int perPage = 50,
  }) async {
    final result = await fetchUserFollowList(userId, page: page, perPage: perPage);
    return result['followings'] ?? [];
  }

  static Map<String, dynamic> _userFollowItemToMap(Map<String, dynamic> json) {
    return {
      'id': json['id'],
      'name': json['name'] ?? '',
      'surname': json['surname'] ?? '',
      'username': json['username'] ?? '',
      'avatar_url': json['avatar_url'] ?? json['avatar'] ?? '',
      'is_following': json['is_following'] ?? false,
      'is_following_pending': json['is_following_pending'] ?? false,
      'is_verified': json['is_verified'] ?? false,
      'account_type': json['account_type'],
      'created_at': json['created_at'],
    };
  }

  /// Birden fazla kullanıcıyı tek seferde çek (performans için)
  static Future<Map<int, PeopleProfileModel>> fetchUsersByIds(
      List<int> userIds) async {
    if (userIds.isEmpty) return {};

    final Map<int, PeopleProfileModel> users = {};

    try {
      final List<Future<void>> futures = userIds.map((userId) async {
        try {
          final userData = await fetchUserById(userId);
          if (userData != null) {
            users[userId] = userData;
          }
        } catch (e) {
          debugPrint("❌ Kullanıcı $userId çekilirken hata: $e");
        }
      }).toList();

      await Future.wait(futures).timeout(const Duration(seconds: 15));

      return users;
    } catch (e) {
      debugPrint("❌ Batch kullanıcı çekme hatası: $e");
      return {};
    }
  }
}
