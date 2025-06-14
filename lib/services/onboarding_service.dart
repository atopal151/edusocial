import 'dart:convert';
import 'package:edusocial/models/group_models/group_model.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class OnboardingServices {
  static final _box = GetStorage();

  //-------------------------------------------------------------//

  /// Okulları ve bölümleri birlikte getirir
  static Future<List<Map<String, dynamic>>> fetchSchools() async {
    final token = _box.read('token');
    if (token == null) {
      // debugPrint("❗ Token bulunamadı! Okul listesi çekilemedi.",wrapWidth: 1024);
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/schools'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // debugPrint("🔥 Okul Listesi Response: ${response.statusCode}",wrapWidth: 1024);
      // debugPrint("🔥 Okul Listesi Body: ${response.body}",wrapWidth: 1024);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data
            .map<Map<String, dynamic>>((school) => {
                  "id": school['id'],
                  "name": school['name'],
                  "departments": school['departments'] ?? [],
                })
            .toList();
      } else {
        // debugPrint("❗ Okul listesi alınamadı: ${response.body}",wrapWidth: 1024);
        return [];
      }
    } catch (e) {
      // debugPrint("❗ Okul listesi yüklenirken hata: $e",wrapWidth: 1024);
      return [];
    }
  }

  /// Okul ve bölüm seçimi kaydetme (PUT /school)
  static Future<bool> updateSchool(
      {required int schoolId, required int departmentId}) async {
    final token = _box.read('token');
    if (token == null) {
      // debugPrint("❗ Token bulunamadı! Okul güncelleme işlemi yapılamadı.");
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/schools'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "school_id": schoolId,
          "school_department_id": departmentId,
        }),
      );

      // debugPrint("📤 Update School Response: ${response.statusCode}",wrapWidth: 1024);
      // debugPrint("📤 Update School Body: ${response.body}",wrapWidth: 1024);

      return response.statusCode == 200;
    } catch (e) {
      // debugPrint("❗ Okul güncelleme hatası: $e",wrapWidth: 1024);
      return false;
    }
  }

  //-------------------------------------------------------------//
  static Future<bool> addLesson(String lessonName) async {
    final token = _box.read('token');
    if (token == null) {
      // debugPrint("❗ Token bulunamadı! Ders eklenemedi.");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/schools/lesson'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"name": lessonName}),
      );

      // debugPrint("🔥 Ders Ekleme Response: ${response.statusCode}",wrapWidth: 1024);
      // debugPrint("🔥 Ders Ekleme Body: ${response.body}",wrapWidth: 1024);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // debugPrint("❗ Ders eklenirken hata: ${response.body}",wrapWidth: 1024);
        return false;
      }
    } catch (e) {
      // debugPrint("❗ Ders eklenirken exception: $e",wrapWidth: 1024);
      return false;
    }
  }

  //-------------------------------------------------------------//
  static Future<bool> requestGroupJoin(int groupId) async {
    final token = _box.read('token');
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/groups/join'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"group_id": groupId}),
      );

      // debugPrint("🟢 Grup katılım response: ${response.statusCode}",wrapWidth: 1024);
      // debugPrint("🟢 Body: ${response.body}",wrapWidth: 1024);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // debugPrint("❗ Join işlemi hatası: $e",wrapWidth: 1024);
      return false;
    }
  }

  //-------------------------------------------------------------//
  static Future<List<GroupModel>> fetchAllGroups() async {
    final token = _box.read('token');
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/groups'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((e) => GroupModel.fromJson(e)).toList();
      } else {
        // debugPrint("❗ Grup listesi alınamadı: ${response.body}");
        return [];
      }
    } catch (e) {
      // debugPrint("❗ Grup listesi çekilirken hata: $e");
      return [];
    }
  }

  //-------------------------------------------------------------//
}
