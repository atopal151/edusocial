import 'dart:convert';
import 'package:edusocial/models/topic_with_entry_model.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/entry_model.dart';

class EntryServices {
  static Future<TopicEntryResponse?> fetchEntriesByTopicId(int topicId) async {
    final token = GetStorage().read("token");

    try {
      debugPrint("🔍 Fetching entries for topic ID: $topicId");
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/timeline/topics/$topicId"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint("📥 Entry topic full response: ${response.body}");
      debugPrint("📥 Entry topic status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        debugPrint("📦 Entry topic decoded JSON: $jsonBody");

        if (jsonBody != null && jsonBody["data"] != null) {
          final data = jsonBody["data"];
          debugPrint("📦 Entry topic data: $data");

          if (data is Map<String, dynamic>) {
            final result = TopicEntryResponse.fromJson(data);
            debugPrint("✅ Entry topic parsed successfully");
            debugPrint("📦 Topic Name: ${result.topic?.name}");
            debugPrint("📦 Topic Category: ${result.topic?.category?.title}");
            debugPrint("📦 Topic Entry Count: ${result.entries?.length}");
            
            // Entry detaylarını yazdır
            result.entries?.forEach((entry) {
              debugPrint("📦 Entry ID: ${entry.id}");
              debugPrint("📦 Entry Content: ${entry.content}");
              debugPrint("📦 Entry Upvotes: ${entry.upvotes_count}");
              debugPrint("📦 Entry Downvotes: ${entry.downvotes_count}");
              debugPrint("📦 Entry Created At: ${entry.human_created_at}");
              debugPrint("📦 Entry User: ${entry.user.name}");
              debugPrint("-------------------");
            });
            
            return result;
          } else {
            debugPrint("❗ 'data' beklenen formatta değil: ${data.runtimeType}");
            return null;
          }
        } else {
          debugPrint("⚠️ 'data' alanı null veya eksik!");
          return null;
        }
      } else {
        debugPrint("⚠️ Topic entries failed: ${response.statusCode}");
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint("❗ fetchEntriesByTopicId error: $e");
      debugPrint("❗ StackTrace: $stackTrace");
      return null;
    }
  }

  static Future<Map<String, int>> fetchTopicCategories() async {
    final token = GetStorage().read("token");

    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/topic-categories"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final List data = jsonBody["data"];

        //debugPrint("📥 Status Code: ${response.statusCode}");
        //debugPrint("📥 Body: ${response.body}");
        //debugPrint("📦 RAW DATA: $data");

        final Map<String, int> result = {};
        for (var item in data) {
          final name = item["title"]; // ✅ DÜZELTİLDİ
          final id = item["id"];

          if (name != null && id != null) {
            result[name.toString()] = id;
          }
        }

        //debugPrint("📦 Topic Category Map: $result");
        return result;
      } else {
        return {};
      }
    } catch (e) {
      debugPrint("❗ Topic Categories error: $e");
      return {};
    }
  }

  static Future<bool> createTopicWithEntry({
    required String name,
    required String content,
    required int topicCategoryId,
  }) async {
    final token = GetStorage().read("token");

    try {
      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}/timeline/topics"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "content": content,
          "topic_category_id": topicCategoryId,
        }),
      );

      /*  debugPrint("📤 Create Topic Response: ${response.statusCode}");
      debugPrint("📤 Create Topic Body: ${response.body}");*/

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❗ Create Topic error: $e");
      return false;
    }
  }

  // Vote Entry
  static Future<bool> voteEntry({
    required String vote,
    required int entryId,
  }) async {
    final token = GetStorage().read("token");

    try {
      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}/vote-entry"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "vote": vote,
          "entry_id": entryId,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❗ Vote Entry error: $e");
      return false;
    }
  }

  // Send Entry To Topic
  static Future<bool> sendEntryToTopic({
    required int topicId,
    required String content,
  }) async {
    final token = GetStorage().read("token");

    try {
      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}/timeline/entries"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "topic_id": topicId,
          "content": content,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❗ Send Entry To Topic error: $e");
      return false;
    }
  }

  // List Topic Categories With Topics
  static Future<List<dynamic>> fetchTopicCategoriesWithTopics() async {
    final token = GetStorage().read("token");

    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/topic-categories"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return jsonBody["data"] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❗ Topic Categories With Topics error: $e");
      return [];
    }
  }

  static Future<List<EntryModel>> fetchEntriesForPerson(int personId) async {
    final token = GetStorage().read("token");

    try {
      debugPrint("🔍 Fetching entries for person ID: $personId");
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/timeline/entries/person/$personId"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint("📥 Person entries status code: ${response.statusCode}");
      debugPrint("📥 Person entries full response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        debugPrint("📦 Person entries decoded JSON: $jsonBody");
        
        final List<dynamic> entriesJson = jsonBody["data"] ?? [];
        debugPrint("📦 Person entries count: ${entriesJson.length}");
        
        final entries = entriesJson.map((json) {
          debugPrint("📦 Processing entry: $json");
          return EntryModel.fromJson(json);
        }).toList();

        debugPrint("✅ Successfully parsed ${entries.length} entries");
        entries.forEach((entry) {
          debugPrint("📦 Entry ID: ${entry.id}");
          debugPrint("📦 Entry Content: ${entry.content}");
          debugPrint("📦 Entry Upvotes: ${entry.upvotes_count}");
          debugPrint("📦 Entry Downvotes: ${entry.downvotes_count}");
          debugPrint("📦 Entry Created At: ${entry.human_created_at}");
          debugPrint("📦 Entry Topic: ${entry.topic?.name}");
          debugPrint("📦 Entry Category: ${entry.topic?.category?.title}");
          debugPrint("📦 Entry User: ${entry.user.name}");
          debugPrint("-------------------");
        });

        return entries;
      } else {
        debugPrint("❌ Person Entries Error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("❗ Person Entries Error: $e");
      return [];
    }
  }

  static Future<List<EntryModel>> fetchEntries() async {
    final token = GetStorage().read("token");

    try {
      debugPrint("🔍 Fetching all entries");
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/timeline/entries"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint("📥 All entries status code: ${response.statusCode}");
      debugPrint("📥 All entries full response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        debugPrint("📦 All entries decoded JSON: $jsonBody");
        
        final List<dynamic> entriesJson = jsonBody["data"] ?? [];
        debugPrint("📦 All entries count: ${entriesJson.length}");
        
        final entries = entriesJson.map((json) {
          debugPrint("📦 Processing entry: $json");
          return EntryModel.fromJson(json);
        }).toList();

        debugPrint("✅ Successfully parsed ${entries.length} entries");
        entries.forEach((entry) {
          debugPrint("📦 Entry ID: ${entry.id}");
          debugPrint("📦 Entry Content: ${entry.content}");
          debugPrint("📦 Entry Upvotes: ${entry.upvotes_count}");
          debugPrint("📦 Entry Downvotes: ${entry.downvotes_count}");
          debugPrint("📦 Entry Created At: ${entry.human_created_at}");
          debugPrint("📦 Entry Topic: ${entry.topic?.name}");
          debugPrint("📦 Entry Category: ${entry.topic?.category?.title}");
          debugPrint("📦 Entry User: ${entry.user.name}");
          debugPrint("-------------------");
        });

        return entries;
      } else {
        debugPrint("❌ All Entries Error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("❗ All Entries Error: $e");
      return [];
    }
  }
}
