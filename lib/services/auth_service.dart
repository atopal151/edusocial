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

  /// Kullanıcı bilgilerini çek (school_id ve department_id kontrol için)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // Kullanıcı bilgilerini döndür
      } else {
        debugPrint("❗ Kullanıcı bilgisi alınamadı: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("❗ Kullanıcı bilgisi alma hatası: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> register({
    required String name,
    required String surname,
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
          'name': name,
          'surname': surname,
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == true) {
        final token = data['data']['token'];
        
        if (token != null) {
          _box.write('token', token);
          return data['data']['user']; // 🛑 Kullanıcı bilgilerini döndür
        }
      }
      lastErrorMessage = data["message"] ?? "Bilinmeyen bir hata oluştu.";
      debugPrint("Register failed: ${data["message"] ?? response.body}",wrapWidth: 1024);
      return null;
    } catch (e) {
      debugPrint("Register error: $e",wrapWidth: 1024);
      return null;
    }
  }

  /// Şifre sıfırlama e-postası gönder
  Future<bool> sendForgotPasswordEmail(String email) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/forgot-password');
      
      debugPrint("📤 Şifre sıfırlama isteği gönderiliyor...");
      debugPrint("📍 URL: $url");
      debugPrint("📧 E-posta: $email");
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      debugPrint("📥 HTTP Status Code: ${response.statusCode}");
      debugPrint("📥 Response Headers: ${response.headers}");
      debugPrint("📥 Raw Response Body: ${response.body}");

      final data = jsonDecode(response.body);
      debugPrint("📥 Parsed Response Data: $data");

      if (response.statusCode == 200 && data["status"] == true) {
        debugPrint("✅ Şifre sıfırlama e-postası başarıyla gönderildi");
        debugPrint("✅ Response Status: ${data["status"]}");
        debugPrint("✅ Response Message: ${data["message"] ?? "No message"}");
        return true;
      } else {
        lastErrorMessage = data["message"] ?? "Şifre sıfırlama e-postası gönderilemedi.";
        debugPrint("❌ Şifre sıfırlama başarısız");
        debugPrint("❌ Status Code: ${response.statusCode}");
        debugPrint("❌ Response Status: ${data["status"]}");
        debugPrint("❌ Error Message: ${data["message"] ?? "No error message"}");
        debugPrint("❌ Full Error Response: $data");
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("💥 Şifre sıfırlama e-postası gönderme hatası: $e");
      debugPrint("💥 Stack Trace: $stackTrace");
      lastErrorMessage = "Ağ bağlantısı hatası oluştu.";
      return false;
    }
  }

  /// Token ile şifre sıfırla
  Future<bool> resetPasswordWithToken({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/reset-password');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == true) {
        debugPrint("✅ Şifre başarıyla sıfırlandı");
        return true;
      } else {
        lastErrorMessage = data["message"] ?? "Şifre sıfırlama başarısız.";
        debugPrint("❌ Şifre sıfırlama hatası: ${data["message"]}");
        return false;
      }
    } catch (e) {
      debugPrint("💥 Şifre sıfırlama hatası: $e");
      lastErrorMessage = "Ağ bağlantısı hatası oluştu.";
      return false;
    }
  }

  /// E-posta ile şifre sıfırla (alternatif endpoint)
  Future<bool> resetPasswordByEmail({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/forgot-password');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == true) {
        debugPrint("✅ Şifre başarıyla sıfırlandı");
        return true;
      } else {
        lastErrorMessage = data["message"] ?? "Şifre sıfırlama başarısız.";
        debugPrint("❌ Şifre sıfırlama hatası: ${data["message"]}");
        return false;
      }
    } catch (e) {
      debugPrint("💥 Şifre sıfırlama hatası: $e");
      lastErrorMessage = "Ağ bağlantısı hatası oluştu.";
      return false;
    }
  }

  static void logout() {
    _box.erase(); // Tüm kayıtlı verileri temizler
    Get.offAllNamed("/login"); // Kullanıcıyı login ekranına atar
  }
}
