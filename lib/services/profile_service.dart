import 'dart:convert';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';
import '../models/people_profile_model.dart';
import '../components/print_full_text.dart';

class ProfileService {
  final box = GetStorage();

  Future<ProfileModel> fetchProfileData() async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("${AppConstants.baseUrl}/me"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      // Gelen verinin tamamını JSON formatında yazdır
      try {
        final jsonBody = json.decode(response.body);

        // Hesap doğrulama durumunu kontrol et
        if (jsonBody['data'] != null) {
          final data = jsonBody['data'];

          // Olası doğrulama alanlarını kontrol et
          final verificationFields = [
            'is_verified',
            'verified',
            'verification_status',
            'account_verified',
            'email_verified',
            'phone_verified',
            'document_verified',
            'identity_verified',
            'verification_level',
            'verification_type'
          ];

          printFullText("🔍 HESAP DOĞRULAMA ALANLARI KONTROLÜ:");
          for (String field in verificationFields) {
            if (data.containsKey(field)) {
              printFullText("✅ $field: ${data[field]}");
            }
          }

        
        }

        // Data alanını ayrıca yazdır
        if (jsonBody['data'] != null) {}

        final profileModel = ProfileModel.fromJson(jsonBody['data']);

        // Doğrulama durumunu yazdır
        printFullText("🔍 HESAP DOĞRULAMA DURUMU:");
        printFullText("  Doğrulanmış mı: ${isUserVerified(profileModel)}");
        printFullText("  Durum: ${getVerificationStatus(profileModel)}");

        final verificationDetails = getVerificationDetails(profileModel);
        printFullText("  Detaylar:");
        verificationDetails.forEach((key, value) {
          printFullText("    $key: $value");
        });

        return profileModel;
      } catch (e) {
        debugPrint("❌ ProfileService - JSON parse hatası: $e");
        throw Exception("❗ Profil verisi alınamadı: ${response.body}");
      }
    } else {
      debugPrint("❌ ProfileService - HTTP hatası: ${response.statusCode}");
      throw Exception("❗ Profil verisi alınamadı: ${response.body}");
    }
  }

  /// 🔥 YENİ: Kullanıcı adından entries'ları çek
  static Future<PeopleProfileModel?> fetchUserByUsername(
      String username) async {
    final box = GetStorage();
    final url =
        Uri.parse('${AppConstants.baseUrl}/user/find-by-username/$username');
    final token = box.read('token');

    try {

      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));


      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // PrintFullText ile tam JSON response'u yazdır
        final formattedJson = const JsonEncoder.withIndent('  ').convert(body);
        printFullText("🔍 USER BY USERNAME API - TAM JSON RESPONSE:");
        printFullText(formattedJson);

        // Hesap doğrulama durumunu kontrol et
        if (body['data'] != null) {
          final data = body['data'];

          // Olası doğrulama alanlarını kontrol et
          final verificationFields = [
            'is_verified',
            'verified',
            'verification_status',
            'account_verified',
            'email_verified',
            'phone_verified',
            'document_verified',
            'identity_verified',
            'verification_level',
            'verification_type'
          ];

          printFullText(
              "🔍 USER BY USERNAME - HESAP DOĞRULAMA ALANLARI KONTROLÜ:");
          for (String field in verificationFields) {
            if (data.containsKey(field)) {
              printFullText("✅ $field: ${data[field]}");
            }
          }

          // Tüm data alanlarını listele
          printFullText("📊 USER BY USERNAME - DATA ALANLARI:");
          data.forEach((key, value) {
            printFullText("  $key: $value");
          });
        }

        final model = PeopleProfileModel.fromJson(body['data']);
        return model;
      } else {
        debugPrint(
            "❌ ProfileService - fetchUserByUsername başarısız: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ ProfileService - fetchUserByUsername error: $e");
      return null;
    }
  }

  /// Kullanıcının hesap doğrulama durumunu kontrol et
  bool isUserVerified(ProfileModel profile) {
    // Olası doğrulama alanlarını kontrol et
    if (profile.isVerified == true) return true;
    if (profile.verified == true) return true;
    if (profile.accountVerified == true) return true;
    if (profile.documentVerified == true) return true;
    if (profile.identityVerified == true) return true;

    // String alanları kontrol et
    if (profile.verificationStatus == 'verified') return true;
    if (profile.verificationLevel == 'verified') return true;
    if (profile.verificationType == 'verified') return true;

    return false;
  }

  /// Kullanıcının hesap doğrulama durumunu string olarak getir
  String getVerificationStatus(ProfileModel profile) {
    if (isUserVerified(profile)) {
      return "Doğrulanmış";
    } else {
      return "Doğrulanmamış";
    }
  }

  /// Kullanıcının hesap doğrulama detaylarını getir
  Map<String, dynamic> getVerificationDetails(ProfileModel profile) {
    return {
      'isVerified': profile.isVerified,
      'verified': profile.verified,
      'verificationStatus': profile.verificationStatus,
      'accountVerified': profile.accountVerified,
      'emailVerified': profile.emailVerified,
      'phoneVerified': profile.phoneVerified,
      'documentVerified': profile.documentVerified,
      'identityVerified': profile.identityVerified,
      'verificationLevel': profile.verificationLevel,
      'verificationType': profile.verificationType,
    };
  }
}
