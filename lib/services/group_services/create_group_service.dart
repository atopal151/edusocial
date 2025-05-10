import 'dart:convert';
import 'dart:io';
import 'package:edusocial/models/group_models/group_area_model.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CreateGroupService {
  final _box = GetStorage();

  void testCreateGroupWithDemoData() async {
    final service = CreateGroupService();

    final success = await service.createGroup(
      name: "Test Grubu",
      description: "Bu bir demo grup açıklamasıdır.",
      groupAreaId: "1", // gerçek bir ID olmalı
      isPrivate: false,
      avatar: null,
      banner: null,
    );

    if (success) {
      print("✅ Demo grup başarıyla oluşturuldu.");
    } else {
      print("❌ Demo grup oluşturulamadı.");
    }
  }

  Future<List<GroupAreaModel>> fetchGroupAreas() async {
    try {
      final token = _box.read("token");
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/groups/areas"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List list = jsonData["data"] ?? [];
        return list.map((e) => GroupAreaModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("❗ Grup alanları alınamadı: $e");
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
    try {
      final token = _box.read("token");
      final uri = Uri.parse("${AppConstants.baseUrl}/groups");

      var request = http.MultipartRequest("POST", uri);
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

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print("📤 Grup Oluşturma Response: ${response.statusCode}");
      print("📤 Grup Oluşturma Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❗ Grup oluşturma hatası: $e");
      return false;
    }
  }
}
