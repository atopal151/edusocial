// group_services.dart
import 'dart:convert';
import 'package:edusocial/models/group_models/grup_suggestion_model.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../models/group_models/group_model.dart';

class GroupServices {
  // group_services.dart

  Future<List<GroupSuggestionModel>> fetchSuggestionGroups() async {
    final box = GetStorage();
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/timeline/groups"),
        headers: {
          'Authorization': 'Bearer ${box.read('token')}',
        },
      );
      // debugPrint("📥 Group Suggestion Response: ${response.statusCode}",
      //  wrapWidth: 1024);
      //debugPrint("📥 Group Suggestion Body: ${response.body}", wrapWidth: 1024);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        return data.map((item) => GroupSuggestionModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❗ Group Suggestion error: $e", wrapWidth: 1024);
      return [];
    }
  }

  Future<List<GroupModel>> fetchUserGroups() async {
    final box = GetStorage();
    final token = box.read('token');

    //debugPrint("🚀 fetchUserGroups() çağrıldı");
    //debugPrint("🔑 Token: $token");

    try {
      final uri = Uri.parse("${AppConstants.baseUrl}/me/groups");
      //debugPrint("🌐 İstek Atılıyor: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint("📥 Kullanıcı Grupları Status: ${response.statusCode}",
          wrapWidth: 1024);
      debugPrint("📥 Kullanıcı Grupları Body:\n${response.body}",
          wrapWidth: 1024);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        debugPrint("📦 Gelen Kullanıcı Grubu Sayısı: ${data.length}",
            wrapWidth: 1024);

        final userGroupList = data.map((item) {
          final group = GroupModel(
            id: item['id'].toString(),
            userId: item['user_id'],
            groupAreaId: item['group_area_id'],
            name: item['name'] ?? '',
            description: item['description'] ?? '',
            status: item['status'] ?? '',
            isPrivate: item['is_private'] ?? false,
            deletedAt: item['deleted_at'],
            createdAt: item['created_at'] ?? '',
            updatedAt: item['updated_at'] ?? '',
            userCountWithAdmin: item['user_count_with_admin'] ?? 0,
            userCountWithoutAdmin: item['user_count_without_admin'] ?? 0,
            messageCount: item['message_count'] ?? 0,
            isFounder: item['is_founder'] ?? false,
            isMember: item['is_member'] ?? false,
            isPending: item['is_pending'] ?? false,
            avatarUrl: item['avatar_url'] ?? '',
            bannerUrl: item['banner_url'] ?? '',
            humanCreatedAt: item['human_created_at'] ?? '',
            pivotCreatedAt: item['pivot']?['created_at'] ?? '',
            pivotUpdatedAt: item['pivot']?['updated_at'] ?? '',
          );

          return group;
        }).toList();

        return userGroupList;
      } else {
        debugPrint("❌ Sunucudan beklenmeyen yanıt.");
        return [];
      }
    } catch (e) {
      debugPrint("💥 Kullanıcı grupları alınırken hata oluştu: $e",
          wrapWidth: 1024);
      return [];
    }
  }

  Future<List<GroupModel>> fetchAllGroups() async {
    final box = GetStorage();
    final token = box.read('token');

    /* debugPrint("🚀 fetchAllGroups() çağrıldı");
    debugPrint("🔑 Token: $token", wrapWidth: 1024);*/

    try {
      final uri = Uri.parse("${AppConstants.baseUrl}/groups");
      //debugPrint("🌐 İstek Atılıyor: $uri", wrapWidth: 1024);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      /* debugPrint("📥 HTTP Status Code: ${response.statusCode}",
          wrapWidth: 1024);

      // 🔽 Dönen cevabı aynen gösteriyoruz
      debugPrint("📦 RAW Response Body:", wrapWidth: 1024);
      debugPrint(response.body, wrapWidth: 1024);*/

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        // debugPrint("📦 Gelen Grup Sayısı: ${data.length}", wrapWidth: 1024);
        final groupList = data.map((item) {
          final group = GroupModel(
            id: item['id'].toString(),
            userId: item['user_id'],
            groupAreaId: item['group_area_id'],
            name: item['name'] ?? '',
            description: item['description'] ?? '',
            status: item['status'] ?? '',
            isPrivate: item['is_private'] ?? false,
            deletedAt: item['deleted_at'],
            createdAt: item['created_at'] ?? '',
            updatedAt: item['updated_at'] ?? '',
            userCountWithAdmin: item['user_count_with_admin'] ?? 0,
            userCountWithoutAdmin: item['user_count_without_admin'] ?? 0,
            messageCount: item['message_count'] ?? 0,
            isFounder: item['is_founder'] ?? false,
            isMember: item['is_member'] ?? false,
            isPending: item['is_pending'] ?? false,
            avatarUrl: item['avatar_url'] ?? '',
            bannerUrl: item['banner_url'] ?? '',
            humanCreatedAt: item['human_created_at'] ?? '',
            pivotCreatedAt: item['pivot']?['created_at'] ?? '',
            pivotUpdatedAt: item['pivot']?['updated_at'] ?? '',
          );

          return group;
        }).toList();

        /* debugPrint("🎯 Toplam ${groupList.length} grup modele dönüştürüldü.",
            wrapWidth: 1024);*/
        return groupList;
      } else {
        debugPrint("❌ Sunucudan beklenmeyen yanıt alındı.", wrapWidth: 1024);
        return [];
      }
    } catch (e) {
      debugPrint("💥 Hata oluştu: $e", wrapWidth: 1024);
      return [];
    }
  }
}
