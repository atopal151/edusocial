import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

import '../models/user_search_model.dart';
import '../models/group_search_model.dart';
import '../models/event_model.dart';
import '../utils/constants.dart'; // AppConstants.baseUrl buradan

class SearchServices {
  static final _box = GetStorage();

  // Hepsini taşıyacak bir sonuç modeli tanımlıyoruz
  static Future<SearchResult> searchAll(String query) async {
    final token = _box.read('token');

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/search?query=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("🔎 Search Response: ${response.statusCode}");
      print("🔎 Search Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body)['data'];

        final users = (jsonData['users'] as List<dynamic>?)
            ?.map((item) => UserSearchModel.fromJson(item))
            .toList() ?? [];

        final groups = (jsonData['groups'] as List<dynamic>?)
            ?.map((item) => GroupSearchModel.fromJson(item))
            .toList() ?? [];

        final events = (jsonData['events'] as List<dynamic>?)
            ?.map((item) => EventModel.fromJson(item))
            .toList() ?? [];

        return SearchResult(users: users, groups: groups, events: events);
      } else {
        return SearchResult.empty();
      }
    } catch (e) {
      print("❗ Search error: $e");
      return SearchResult.empty();
    }
  }
}

// Gelen arama sonuçları bir class içine toplandı
class SearchResult {
  final List<UserSearchModel> users;
  final List<GroupSearchModel> groups;
  final List<EventModel> events;

  SearchResult({
    required this.users,
    required this.groups,
    required this.events,
  });

  factory SearchResult.empty() {
    return SearchResult(users: [], groups: [], events: []);
  }
}
