import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart'; // AppConstants burada
import '../../models/match_model.dart';

class MatchServices {
  static final _box = GetStorage(); // GetStorage ile token al

  static Future<List<MatchModel>> fetchMatches() async {
    final token = _box.read('token');

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/match-user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("📥 Match Response: ${response.statusCode}");
      print("📥 Match Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body)['data'];
        final MatchModel match = MatchModel.fromJson(data);
        return [match];
      } else {
        return [];
      }
    } catch (e) {
      print("❗ Match verileri alınamadı: $e");
      return [];
    }
  }
}
