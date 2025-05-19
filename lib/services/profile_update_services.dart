import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class ProfileUpdateService {
  static final _box = GetStorage();

  /// 📤 Profil bilgilerini güncelle
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
    required String description,
    required String tiktok,
    required String languageId,

    File? avatarFile,
    File? coverFile, // Yeni parametre olarak al
  }) async {
    final token = _box.read('token');
    final uri = Uri.parse('${AppConstants.baseUrl}/profile');

    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // 📄 Normal form alanları
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
      'description': description,
      'tiktok': tiktok,
      'language_id': languageId,

    });

    // 📚 Ders bilgileri (array formatı)
    for (int i = 0; i < lessons.length; i++) {
      request.fields['lessons[$i]'] = lessons[i];
    }

    // 🖼️ Avatar resmi eklenmişse
    if (avatarFile != null) {
      final mimeType = avatarFile.path.endsWith('.png')
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          avatarFile.path,
          contentType: mimeType,
        ),
      );
    }
    if (coverFile != null) {
      final mimeType = coverFile.path.endsWith('.png')
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');
      request.files.add(
        await http.MultipartFile.fromPath(
          'cover_photo',
          coverFile.path,
          contentType: mimeType,
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('🔄 Profil Güncelleme Status Code: ${response.statusCode}');
      debugPrint('📩 Güncelleme Yanıtı:\n${response.body}', wrapWidth: 1024);

      if (response.statusCode == 200) {
        debugPrint("✅ Profil başarıyla güncellendi.");
      } else {
        throw Exception('❗ Sunucu hatası: ${response.body}');
      }
    } catch (e) {
      debugPrint('❗ Profil güncelleme isteği başarısız: $e');
      rethrow;
    }
  }
}
