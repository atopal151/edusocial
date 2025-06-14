import 'dart:convert';
import 'package:edusocial/utils/constants.dart';
//import 'package:flutter/material.dart';
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

    /*debugPrint("📥 kullanıcı HTTP Status Code: ${response.statusCode}",
      wrapWidth: 1024);
    debugPrint("📦 Kullanıcı Bilgileri Body:\n${response.body}",
      wrapWidth: 1024);
    final jsonBody = json.decode(response.body);
    final pretty = const JsonEncoder.withIndent('  ').convert(jsonBody);
    debugPrint(pretty, wrapWidth: 1024); // Konsol kesmesin diye
    debugPrint("Kullanıcı HTTP Status Code: ${response.statusCode}");
    debugPrint("Kullanıcı Bilgileri Body: ${response.body}");*/

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return ProfileModel.fromJson(jsonBody['data']);
    } else {
      throw Exception("❗ Profil verisi alınamadı: ${response.body}");
    }
  }
}
