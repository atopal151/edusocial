import 'dart:convert';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';
import '../models/people_profile_model.dart';

class ProfileService {
  final box = GetStorage();

  Future<ProfileModel> fetchProfileData() async {
    final token = box.read("token");

    //debugPrint("🔄 ProfileService.fetchProfileData() başlatıldı");
    //debugPrint("🔑 Token: ${token != null ? 'Var' : 'Yok'}");

    final response = await http.get(
      Uri.parse("${AppConstants.baseUrl}/me"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    //debugPrint("📥 ProfileService - HTTP Status Code: ${response.statusCode}");
    //debugPrint("📦 ProfileService - Response Body: ${response.body}");
    
    if (response.statusCode == 200) {
      // Gelen verinin tamamını JSON formatında yazdır
      try {
        final jsonBody = json.decode(response.body);
       // final formattedJson = const JsonEncoder.withIndent('  ').convert(jsonBody);
        //debugPrint("🔍 ProfileService - Tam JSON Response:");
        //debugPrint(formattedJson);
        
        // Data alanını ayrıca yazdır
        if (jsonBody['data'] != null) {
         // final dataJson = const JsonEncoder.withIndent('  ').convert(jsonBody['data']);
          //debugPrint("📊 ProfileService - Data Alanı:");
          //debugPrint(dataJson);
          
          // Entries alanını kontrol et
          if (jsonBody['data']['entries'] != null) {
            final entries = jsonBody['data']['entries'] as List;
            //debugPrint("📝 ProfileService - Entries sayısı: ${entries.length}");
            for (int i = 0; i < entries.length; i++) {
              //debugPrint("📝 Entry $i: ${entries[i]}");
            }
          } else {
            debugPrint("⚠️ ProfileService - Entries alanı bulunamadı");
          }
          
          // Post verilerini debug et
          if (jsonBody['data']['posts'] != null) {
            final posts = jsonBody['data']['posts'] as List;
            //debugPrint("📝 ProfileService - Post sayısı: ${posts.length}");
            for (int i = 0; i < posts.length; i++) {
              //debugPrint("📝 Post $i: ${posts[i]}");
            }
          } else {
            debugPrint("⚠️ ProfileService - Posts alanı bulunamadı");
          }
          
          // Account type kontrolü
          //final accountType = jsonBody['data']['account_type'];
          //adebugPrint("🔍 ProfileService - Account Type: $accountType");
        }
        
        return ProfileModel.fromJson(jsonBody['data']);
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
  static Future<PeopleProfileModel?> fetchUserByUsername(String username) async {
    final box = GetStorage();
    final url = Uri.parse('${AppConstants.baseUrl}/user/find-by-username/$username');
    final token = box.read('token');

    try {
      //debugPrint("🔄 ProfileService - fetchUserByUsername çağrıldı: $username");
      
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));
      
      //debugPrint("📥 ProfileService - Response status: ${response.statusCode}");
      //debugPrint("📥 ProfileService - Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        
        //debugPrint("✅ ProfileService - fetchUserByUsername başarılı");
        //debugPrint("📊 ProfileService - Entries sayısı: ${body['data']['entries']?.length ?? 0}");
        //debugPrint("🔍 ProfileService - Account type: ${body['data']['account_type'] ?? 'unknown'}");

        final model = PeopleProfileModel.fromJson(body['data']);
        return model;
      } else {
        debugPrint("❌ ProfileService - fetchUserByUsername başarısız: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ ProfileService - fetchUserByUsername error: $e");
      return null;
    }
  }
}
