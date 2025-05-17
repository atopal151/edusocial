import 'dart:convert';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final GetStorage _box = GetStorage();

  String? lastErrorMessage; // 🌟 Hata mesajını buraya kaydediyoruz
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'login': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == true) {
        final token = data['data']['token'];
        if (token != null) {
          _box.write('token', token);
          debugPrint("Token başarıyla kaydedildi: $token",wrapWidth: 1024);
          return data['data']['user']; // 🛑 Kullanıcı bilgilerini döndür
        }
      }
      lastErrorMessage = data["message"] ?? "Giriş başarısız.";
      return null;
    } catch (e) {
      debugPrint("Login error: $e",wrapWidth: 1024);
      return null;
    }
  }

  String? getToken() => _box.read('token');

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/register');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': "nametest",
          'surname': 'surnametest',
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == true) {
        final token = data['data']['token']; // 🔥 BURAYI DÜZELTTİK
        debugPrint("buradayız1");
        if (token != null) {
          debugPrint("buradayız2");
          _box.write('token', token);
          return true;
        }
      }
      lastErrorMessage = data["message"] ?? "Bilinmeyen bir hata oluştu.";
      // Eğer status false ise, mesajı döndür.
      debugPrint("Register failed: ${data["message"] ?? response.body}",wrapWidth: 1024);
      return false;
    } catch (e) {
      debugPrint("Register error: $e",wrapWidth: 1024);
      return false;
    }
  }

  static void logout() {
    _box.erase(); // Tüm kayıtlı verileri temizler
    Get.offAllNamed("/login"); // Kullanıcıyı login ekranına atar
  }
}
