import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart'; // AppConstants burada
import '../../models/match_model.dart';
import 'package:flutter/foundation.dart';

class MatchServices {
  static final _box = GetStorage(); // GetStorage ile token al
  static Future<bool> addLesson(String lesson) async {
    final token = GetStorage().read('token');
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/schools/lesson'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': lesson,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<bool> followUser(int userId) async {
    final token = GetStorage().read('token');
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/user/follow'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'user_id': userId,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<List<MatchModel>> fetchMatches() async {
    final token = _box.read('token');
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/match-user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body)['data'];
        if (data == null) return [];

        // Eğer data bir liste ise, tüm eşleşmeleri işle
        if (data is List) {
          return data.map((match) => MatchModel.fromJson(match)).toList();
        } 
        // Eğer data tek bir obje ise, onu liste içinde döndür
        else {
          return [MatchModel.fromJson(data)];
        }
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❗ Fetch matches error: $e");
      return [];
    }
  }

  static Future<List<MatchModel>> findMatches() async {
    final token = GetStorage().read('token');
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/match-user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body)['data'];
        if (data == null) return [];
        
        // Eğer data bir liste ise, tüm eşleşmeleri işle
        if (data is List) {
          return data.map((match) => MatchModel.fromJson(match)).toList();
        } 
        // Eğer data tek bir obje ise, onu liste içinde döndür
        else {
          return [MatchModel.fromJson(data)];
        }
      } else {
        throw Exception('Eşleşmeler yüklenirken bir hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❗ Match fetch error: $e");
      throw Exception('Eşleşmeler yüklenirken bir hata oluştu: $e');
    }
  }
}
