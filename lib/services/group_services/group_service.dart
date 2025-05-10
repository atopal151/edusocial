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
    await Future.delayed(Duration(seconds: 1));
    return [
      GroupModel(
        id: "1",
        name: "Kimya Kulübü",
        description: "Kimya severlerin bir araya geldiği grup.",
        imageUrl:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        memberCount: 564,
        category: "Kimya",
        isJoined: true,
      ),
      GroupModel(
        id: "2",
        name: "Fizikçiler Platformu",
        description: "Fizik üzerine tartışmalar.",
        imageUrl:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        memberCount: 443,
        category: "Fizik",
        isJoined: true,
      ),
      GroupModel(
        id: "1",
        name: "Edebiyat Kulübü",
        description: "Edebiyat severlerin bir araya geldiği grup.",
        imageUrl:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        memberCount: 776,
        category: "Eğitim",
        isJoined: true,
      ),
    ];
  }

  Future<List<GroupModel>> fetchAllGroups() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      GroupModel(
        id: "1",
        name: "Kimya Kulübü",
        description: "Kimya severlerin bir araya geldiği grup.",
        imageUrl:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        memberCount: 35,
        category: "Kimya",
        isJoined: true,
      ),
      GroupModel(
        id: "3",
        name: "Teknoloji Dünyası",
        description: "Yeni teknolojiler ve haberler.",
        imageUrl:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        memberCount: 55,
        category: "Teknoloji",
        isJoined: false,
      ),
      GroupModel(
        id: "4",
        name: "Eğitimde Yenilik",
        description: "Eğitim teknolojileri üzerine.",
        imageUrl:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        memberCount: 23,
        category: "Eğitim",
        isJoined: false,
      ),
      GroupModel(
        id: "3",
        name: "Teknoloji Dünyası",
        description: "Yeni teknolojiler ve haberler.",
        imageUrl:
            "https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg",
        memberCount: 800,
        category: "Teknoloji",
        isJoined: false,
      ),
      GroupModel(
        id: "4",
        name: "Eğitimde Yenilik",
        description: "Eğitim teknolojileri üzerine.",
        imageUrl:
            "https://images.pexels.com/photos/4145190/pexels-photo-4145190.jpeg",
        memberCount: 440,
        category: "Eğitim",
        isJoined: false,
      ),
      GroupModel(
        id: "3",
        name: "Teknoloji Dünyası",
        description: "Yeni teknolojiler ve haberler.",
        imageUrl:
            "https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg",
        memberCount: 657,
        category: "Teknoloji",
        isJoined: false,
      ),
      GroupModel(
        id: "4",
        name: "Eğitimde Yenilik",
        description: "Eğitim teknolojileri üzerine.",
        imageUrl:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        memberCount: 410,
        category: "Eğitim",
        isJoined: false,
      ),
    ];
  }
}
