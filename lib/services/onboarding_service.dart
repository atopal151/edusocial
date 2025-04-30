import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class OnboardingServices {
  static final _box = GetStorage();
  static final String baseUrl = "https://stageapi.edusocial.pl/mobile";

  //-------------------------------------------------------------//
  static Future<List<Map<String, dynamic>>> fetchSchools() async {
    final token = _box.read('token');

    if (token == null) {
      print("❗ Token bulunamadı! Okul listesi çekilemedi.");
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schools'),
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

  //-------------------------------------------------------------//
  static Future<List<String>> fetchDepartments(int schoolId) async {
    final token = _box.read('token');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schools/school_departments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List departments = jsonDecode(response.body)['data'];
        return departments.map<String>((e) => e['name'].toString()).toList();
      } else {
        print("❗ Bölüm listesi alınamadı: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❗ Bölüm listesi yükleme hatası: $e");
      return [];
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
        Uri.parse('$baseUrl/school/lesson'),
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
        Uri.parse('$baseUrl/groups/join'),
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
        Uri.parse('$baseUrl/groups'),
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
