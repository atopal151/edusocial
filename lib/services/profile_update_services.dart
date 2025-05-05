import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:http_parser/http_parser.dart';
import '../utils/constants.dart';

class ProfileUpdateService {
  static final _box = GetStorage();

  static Future<void> updateProfile({
    required String username,
    required String name,
    required String surname,
    required String email,
    required String phone,
    required String birthday,
    required String instagram,
    required String twitter,
    required String facebook,
    required String linkedin,
    required String accountType,
    required bool emailNotification,
    required bool mobileNotification,
    required String schoolId,
    required String departmentId,
    required List<String> lessons,
    File? avatarFile,
  }) async {
    final token = _box.read('token');
    final uri = Uri.parse('${AppConstants.baseUrl}/profile');

    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // Form alanları
    request.fields.addAll({
      'username': username,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'birthday': birthday,
      'instagram': instagram,
      'twitter': twitter,
      'facebook': facebook,
      'linkedin': linkedin,
      'account_type': accountType,
      'notification_email': emailNotification ? '1' : '0',
      'notification_mobile': mobileNotification ? '1' : '0',
      'school_id': schoolId,
      'school_department_id': departmentId,
    });

    // Ders listesi
    for (int i = 0; i < lessons.length; i++) {
      request.fields['lessons[$i]'] = lessons[i];
    }

    // Avatar dosyası (varsa)
    if (avatarFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          avatarFile.path,
          contentType: MediaType('image', 'jpeg'), // (isteğe göre png yapabilirsin)
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🔵 Profil Güncelleme Status Code: ${response.statusCode}');
      print('📩 Profil Güncelleme Body: ${response.body}');

      if (response.statusCode == 200) {
        print("✅ Profil başarıyla güncellendi.");
      } else {
        throw Exception('❗ Profil güncelleme hatası: ${response.body}');
      }
    } catch (e) {
      print('❗ Profil güncelleme isteği başarısız: $e');
      rethrow;
    }
  }
}
