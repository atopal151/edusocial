import 'dart:convert';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';

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

    //debugPrint("📥 ProfileService - HTTP Status Code: ${response.statusCode}");
      //debugPrint("📦 ProfileService - Response Body: ${response.body}");
    
    if (response.statusCode == 200) {
      // Gelen verinin tamamını JSON formatında yazdır
      try {
        final jsonBody = json.decode(response.body);
        //final formattedJson = const JsonEncoder.withIndent('  ').convert(jsonBody);
        //debugPrint("🔍 ProfileService - Tam JSON Response:");
        // debugPrint(formattedJson);
        
        // Data alanını ayrıca yazdır
        if (jsonBody['data'] != null) {
          //final dataJson = const JsonEncoder.withIndent('  ').convert(jsonBody['data']);
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
            //debugPrint("⚠️ ProfileService - Entries alanı bulunamadı");
          }
          
          // Post verilerini debug et
          if (jsonBody['data']['posts'] != null) {
            final posts = jsonBody['data']['posts'] as List;
            //debugPrint("📝 ProfileService - Post sayısı: ${posts.length}");
          }
        }
        
        return ProfileModel.fromJson(jsonBody['data']);
      } catch (e) {
        debugPrint("❌ ProfileService - JSON parse hatası: $e");
        throw Exception("❗ Profil verisi alınamadı: ${response.body}");
      }
    } else {
      throw Exception("❗ Profil verisi alınamadı: ${response.body}");
    }
  }
}
