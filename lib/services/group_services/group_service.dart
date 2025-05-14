// group_services.dart
import 'dart:convert';
import 'dart:io';

import 'package:edusocial/models/group_models/grup_suggestion_model.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
      print("📥 Group Suggestion Response: ${response.statusCode}");
      print("📥 Group Suggestion Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        return data.map((item) => GroupSuggestionModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("❗ Group Suggestion error: $e");
      return [];
    }
  }

  Future<bool> createGroup({
    required String name,
    required String description,
    required String groupAreaId,
    required bool isPrivate,
    File? avatar,
    File? banner,
  }) async {
    final box = GetStorage();
    final token = box.read('token');

    var uri = Uri.parse("${AppConstants.baseUrl}/group");

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['group_area_id'] = groupAreaId;
    request.fields['is_private'] = isPrivate ? '1' : '0';

    if (avatar != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        avatar.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    if (banner != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'banner',
        banner.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("📤 Grup Oluşturma Response: ${response.statusCode}");
    print("📤 Grup Oluşturma Body: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  }

Future<List<GroupModel>> fetchUserGroups() async {
  final box = GetStorage();
  final token = box.read('token');

  print("🚀 fetchUserGroups() çağrıldı");
  print("🔑 Token: $token");

  try {
    final uri = Uri.parse("${AppConstants.baseUrl}/me/groups");
    print("🌐 İstek Atılıyor: $uri");

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print("📥 Kullanıcı Grupları Status: ${response.statusCode}");
    print("📥 Kullanıcı Grupları Body:\n${response.body}");

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<dynamic> data = jsonBody['data'] ?? [];

      print("📦 Gelen Kullanıcı Grubu Sayısı: ${data.length}");

      final userGroupList = data.map((item) {
        final group = GroupModel(
          id: item['id'].toString(),
          name: item['name'] ?? '',
          description: item['description'] ?? '',
          imageUrl: item['image'] != null
              ? "${AppConstants.baseUrl}/${item['image']}"
              : '',
          memberCount: item['member_count'] ?? 0,
          category: item['category'] ?? 'Genel',
          isJoined: true, // Kullanıcı zaten bu gruplara üye
        );
        print("✅ Kullanıcı Grubu: ${group.name} (${group.id})");
        return group;
      }).toList();

      return userGroupList;
    } else {
      print("❌ Sunucudan beklenmeyen yanıt.");
      return [];
    }
  } catch (e) {
    print("💥 Kullanıcı grupları alınırken hata oluştu: $e");
    return [];
  }
}


  Future<List<GroupModel>> fetchAllGroups() async {
    final box = GetStorage();
    final token = box.read('token');

    print("🚀 fetchAllGroups() çağrıldı");
    print("🔑 Token: $token");

    try {
      final uri = Uri.parse("${AppConstants.baseUrl}/groups");
      print("🌐 İstek Atılıyor: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("📥 HTTP Status Code: ${response.statusCode}");

      // 🔽 Dönen cevabı aynen gösteriyoruz
      print("📦 RAW Response Body:");
      print(response.body);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        print("📦 Gelen Grup Sayısı: ${data.length}");

        final groupList = data.map((item) {
          final group = GroupModel(
            id: item['id'].toString(),
            name: item['name'] ?? '',
            description: item['description'] ?? '',
            imageUrl: item['image'] != null
                ? "${AppConstants.baseUrl}/${item['image']}"
                : '',
            memberCount: item['member_count'] ?? 0,
            category: item['category'] ?? 'Genel',
            isJoined: item['is_member'] ?? false,
          );
          print("✅ Grup Eklendi: ${group.name} (${group.id})");
          return group;
        }).toList();

        print("🎯 Toplam ${groupList.length} grup modele dönüştürüldü.");
        return groupList;
      } else {
        print("❌ Sunucudan beklenmeyen yanıt alındı.");
        return [];
      }
    } catch (e) {
      print("💥 Hata oluştu: $e");
      return [];
    }
  }
}
