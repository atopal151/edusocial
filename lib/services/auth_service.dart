import 'dart:convert';
import 'package:edusocial/utils/constants.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final GetStorage _box = GetStorage();

  String? lastErrorMessage; // 🌟 Hata mesajını buraya kaydediyoruz
  Future<bool> login(String email, String password) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // BURAYI DA EKLEDİK
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
          print("Token başarıyla kaydedildi: $token");
          return true;
        }
      }
      lastErrorMessage = data["message"] ?? "Giriş başarısız.";
      print("Login failed: ${data["message"] ?? response.body}");
      return false;
    } catch (e) {
      print("Login error: $e");
      return false;
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
        print("buradayız1");
        if (token != null) {
          print("buradayız2");
          _box.write('token', token);
          return true;
        }
      }
      lastErrorMessage = data["message"] ?? "Bilinmeyen bir hata oluştu.";
      // Eğer status false ise, mesajı döndür.
      print("Register failed: ${data["message"] ?? response.body}");
      return false;
    } catch (e) {
      print("Register error: $e");
      return false;
    }
  }
}
