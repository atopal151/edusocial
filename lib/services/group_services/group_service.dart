// group_services.dart
import 'dart:convert';
import 'dart:io';
import 'package:edusocial/models/group_models/grup_suggestion_model.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../models/group_models/group_model.dart';
import '../../models/group_models/group_detail_model.dart';

class GroupServices {
//ana sayfa içerisinde çıkacak olan önerilen group alanı endpointi
  Future<List<GroupSuggestionModel>> fetchSuggestionGroups() async {
    final box = GetStorage();
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/timeline/groups"),
        headers: {
          'Authorization': 'Bearer ${box.read('token')}',
        },
      );
      /*debugPrint("📥 Group Suggestion Response: ${response.statusCode}",
         wrapWidth: 1024);
      debugPrint("📥 Group Suggestion Body: ${response.body}", wrapWidth: 1024);*/

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        return data.map((item) => GroupSuggestionModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      /*debugPrint("❗ Group Suggestion error: $e", wrapWidth: 1024);*/
      return [];
    }
  }

  Future<List<GroupModel>> fetchUserGroups() async {
    final box = GetStorage();
    final token = box.read('token');

    /*debugPrint("🚀 fetchUserGroups() çağrıldı");
    debugPrint("🔑 Token: $token");*/

    try {
      final uri = Uri.parse("${AppConstants.baseUrl}/me/groups");
      /*debugPrint("🌐 İstek Atılıyor: $uri");*/

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      /*debugPrint("📥 Kullanıcı Grupları Status: ${response.statusCode}",
       wrapWidth: 1024);
      debugPrint("📥 Kullanıcı Grupları Body:\n${response.body}",
      wrapWidth: 1024);*/

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        /*debugPrint("📦 Gelen Kullanıcı Grubu Sayısı: ${data.length}",
          wrapWidth: 1024);*/

        final userGroupList = data.map((item) => GroupModel.fromJson(item)).toList();

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

  Future<List<Map<String, dynamic>>> fetchGroupAreas() async {
    final box = GetStorage();
    final token = box.read('token');

    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/groups/areas"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];
        return List<Map<String, dynamic>>.from(data);
      } else {
        debugPrint("❌ Grup alanları alınamadı. Status: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("💥 Grup alanları alınırken hata oluştu: $e");
      return [];
    }
  }

  Future<List<GroupModel>> fetchAllGroups() async {
    final box = GetStorage();
    final token = box.read('token');

    try {
      final uri = Uri.parse("${AppConstants.baseUrl}/groups");

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        final groupList = data.map((item) => GroupModel.fromJson(item)).toList();

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

  Future<bool> sendJoinRequest(String groupId) async {
    final box = GetStorage();
    final token = box.read('token');

    try {
      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}/group-join"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "group_id": groupId,
        }),
      );

      debugPrint("📤 Join request status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint("❌ Katılma isteği başarısız: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("💥 Join isteği hatası: $e");
      return false;
    }
  }

  Future<GroupDetailModel> fetchGroupDetail(String groupId) async {
    final box = GetStorage();
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/group-detail/$groupId'),
        headers: {
          'Authorization': 'Bearer ${box.read('token')}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['status'] == true && jsonBody['data'] != null) {
          final groupData = jsonBody['data']['group'];

          debugPrint('📋 GRUP DETAY VERİLERİ:');
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          debugPrint('ID: ${groupData['id']}');
          debugPrint('Group Chats: ${jsonBody['data']['group']['group_chats']}');
          debugPrint('Group Event: ${jsonBody['data']['group']['group_events']}');
          debugPrint('Group users: ${jsonBody['data']['users']}');
          return GroupDetailModel.fromJson(jsonBody['data']);
        }
        throw Exception('No group data found');
      } else {
        throw Exception('Failed to fetch group details');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> sendGroupMessage({
    required String groupId,
    String? message,
    List<File>? mediaFiles,
    List<String>? links,
    List<String>? pollOptions,
  }) async {
    final box = GetStorage();
    final token = box.read('token');

    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/group-message');
      var request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['group_id'] = groupId;
      
      // Message alanını her zaman gönder (boş string olsa bile)
      request.fields['message'] = message ?? '';

      // Media dosyalarını ekle
      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        for (int i = 0; i < mediaFiles.length; i++) {
          final file = mediaFiles[i];
          if (await file.exists()) {
            final fileExtension = file.path.split('.').last.toLowerCase();
            String mimeType = 'application/octet-stream';
            
            // MIME type belirle
            if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
              mimeType = 'image/$fileExtension';
            } else if (['pdf'].contains(fileExtension)) {
              mimeType = 'application/pdf';
            } else if (['doc', 'docx'].contains(fileExtension)) {
              mimeType = 'application/msword';
            } else if (['txt'].contains(fileExtension)) {
              mimeType = 'text/plain';
            }
            
            request.files.add(await http.MultipartFile.fromPath(
              'media[]',
              file.path,
              contentType: MediaType.parse(mimeType),
            ));
          }
        }
      }

      // Linkleri ekle
      if (links != null && links.isNotEmpty) {
        for (int i = 0; i < links.length; i++) {
          request.fields['links[]'] = links[i];
        }
      }

      // Poll seçeneklerini ekle
      if (pollOptions != null && pollOptions.isNotEmpty) {
        for (int i = 0; i < pollOptions.length; i++) {
          request.fields['poll_options[]'] = pollOptions[i];
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📤 Send Group Message Response: ${response.statusCode}');
      debugPrint('📤 Send Group Message Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('❌ Send group message failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('💥 Send group message error: $e');
      return false;
    }
  }
}
