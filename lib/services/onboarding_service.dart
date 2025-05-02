import 'dart:convert';
import 'package:edusocial/utils/constants.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class OnboardingServices {
  static final _box = GetStorage();

  //-------------------------------------------------------------//

  /// Okulları ve bölümleri birlikte getirir
  static Future<List<Map<String, dynamic>>> fetchSchools() async {
    final token = _box.read('token');
    if (token == null) {
      print("❗ Token bulunamadı! Okul listesi çekilemedi.");
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

      print("🔥 Okul Listesi Response: ${response.statusCode}");
      print("🔥 Okul Listesi Body: ${response.body}");

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
        print("❗ Okul listesi alınamadı: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❗ Okul listesi yüklenirken hata: $e");
      return [];
    }
  }

  /// Okul ve bölüm seçimi kaydetme (PUT /school)
  static Future<bool> updateSchool(
      {required int schoolId, required int departmentId}) async {
    final token = _box.read('token');
    if (token == null) {
      print("❗ Token bulunamadı! Okul güncelleme işlemi yapılamadı.");
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

      print("📤 Update School Response: ${response.statusCode}");
      print("📤 Update School Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❗ Okul güncelleme hatası: $e");
      return false;
    }
  }

  //-------------------------------------------------------------//
  static Future<bool> addLesson(String lessonName) async {
    final token = _box.read('token');
    if (token == null) {
      print("❗ Token bulunamadı! Ders eklenemedi.");
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

      print("🔥 Ders Ekleme Response: ${response.statusCode}");
      print("🔥 Ders Ekleme Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("❗ Ders eklenirken hata: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❗ Ders eklenirken exception: $e");
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

      print("🟢 Grup katılım response: ${response.statusCode}");
      print("🟢 Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❗ Join işlemi hatası: $e");
      return false;
    }
  }

  //-------------------------------------------------------------//
  static Future<List<Map<String, dynamic>>> fetchAllGroups() async {
    final token = _box.read('token');
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/groups'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("📥 Grup listesi response: ${response.statusCode}");
      print("📥 Grup listesi body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.cast<Map<String, dynamic>>();
      } else {
        print("❗ Grup listesi alınamadı: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❗ Grup listesi çekilirken hata: $e");
      return [];
    }
  }

  //-------------------------------------------------------------//
}
