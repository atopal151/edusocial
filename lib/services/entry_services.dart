import 'dart:convert';
import 'package:edusocial/models/topic_with_entry_model.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/entry_model.dart';
import '../models/topic_model.dart';
import '../models/topic_category_model.dart';
import '../models/user_model.dart';
import 'package:dio/dio.dart';

class EntryServices {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {
        "Authorization": "Bearer ${GetStorage().read("token")}",
        "Accept": "application/json",
      },
    ),
  );

  static Future<TopicEntryResponse?> fetchEntriesByTopicId(int topicId) async {
    final token = GetStorage().read("token");

    try {
      //debugPrint("🔍 Fetching entries for topic ID: $topicId");
      //debugPrint("🔑 Token: ${token != null ? 'Var' : 'Yok'}");
      //debugPrint("🌐 URL: ${AppConstants.baseUrl}/timeline/topics/$topicId?sort=latest");
      
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/timeline/topics/$topicId?sort=latest"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      //debugPrint("📥 Response Status: ${response.statusCode}");
      //debugPrint("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        //debugPrint("📦 Decoded JSON: $jsonBody");

        if (jsonBody != null && jsonBody["data"] != null) {
          final data = jsonBody["data"];
          //debugPrint("📊 Data field: $data");
          //debugPrint("📊 Data type: ${data.runtimeType}");

          if (data is Map<String, dynamic>) {
            // Topic bilgilerini debug et
            //debugPrint("🏷️ Topic info:");
            //debugPrint("  - Topic ID: ${data['topic']?['id']}");
            //debugPrint("  - Topic Name: ${data['topic']?['name']}");
            //debugPrint("  - Entries Count: ${data['entrys']?.length ?? 0}");
            
            if (data['entrys'] != null) {
              //debugPrint("📝 Entries details:");
              final entries = data['entrys'] as List;
              for (int i = 0; i < entries.length; i++) {
                //debugPrint("  [$i] Entry ID: ${entries[i]['id']}, Content: ${entries[i]['content']?.substring(0, entries[i]['content']?.length > 50 ? 50 : entries[i]['content']?.length)}...");
              }
            } else {
              //debugPrint("⚠️ No entries found in data");
            }
            
            final result = TopicEntryResponse.fromJson(data);
            debugPrint("✅ TopicEntryResponse created successfully");
            return result;
          } else {
            debugPrint("❌ Data is not a Map<String, dynamic>, type: ${data.runtimeType}");
            return null;
          }
        } else {
          debugPrint("⚠️ 'data' alanı null veya eksik!");
          debugPrint("📦 Full response body: ${response.body}");
          return null;
        }
      } else {
        debugPrint("⚠️ Topic entries failed: ${response.statusCode}");
        debugPrint("❌ Error response body: ${response.body}");
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint("❗ fetchEntriesByTopicId error: $e");
      debugPrint("❗ StackTrace: $stackTrace");
      return null;
    }
  }

  Future<List<TopicCategoryModel>> fetchTopicCategories() async {
    try {
      final response = await dio.get('/topic-categories');
      //debugPrint("📥 Topic Categories Raw Response: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => TopicCategoryModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<bool> createTopicWithEntry({
    required String name,
    required String content,
    required int topicCategoryId,
  }) async {
    final token = GetStorage().read("token");
    //debugPrint("🔑 Token alındı: ${token != null ? "Var" : "Yok"}");

    try {
      //debugPrint("🌐 API isteği gönderiliyor...");
      //debugPrint("📤 Gönderilen veriler:");
      //debugPrint("   - Konu Adı: $name");
      //debugPrint("   - İçerik: $content");
      //debugPrint("   - Kategori ID: $topicCategoryId");

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

      //debugPrint("📥 API yanıtı alındı:");
      //debugPrint("   - Status Code: ${response.statusCode}");
      //debugPrint("   - Response Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      //debugPrint("❌ API çağrısı sırasında hata oluştu:");
      //debugPrint("   - Hata: $e");
      //debugPrint("   - Stack Trace: $stackTrace");
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
      // debugPrint("❗ Vote Entry error: $e");
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
      // debugPrint("❗ Send Entry To Topic error: $e");
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
      // debugPrint("❗ Topic Categories With Topics error: $e");
      return [];
    }
  }

  static Future<List<EntryModel>> fetchEntriesForPerson(int personId) async {
    final token = GetStorage().read("token");

    try {
      // debugPrint("🔍 Fetching entries for person ID: $personId");
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/timeline/entries/person/$personId"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      // debugPrint("📥 Person entries status code: ${response.statusCode}");
      // debugPrint("📥 Person entries full response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        // debugPrint("📦 Person entries decoded JSON: $jsonBody");
        
        final List<dynamic> entriesJson = jsonBody["data"] ?? [];
        // debugPrint("📦 Person entries count: ${entriesJson.length}");
        
        final entries = entriesJson.map((json) {
          // debugPrint("📦 Processing entry: $json");
          return EntryModel.fromJson(json);
        }).toList();

      

        return entries;
      } else {
        // debugPrint("❌ Person Entries Error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      // debugPrint("❗ Person Entries Error: $e");
      return [];
    }
  }

  static Future<List<EntryModel>> fetchEntries() async {
    try {
      //debugPrint('🔍 Fetching all entries');
      final token = await GetStorage().read('token');
      //debugPrint('🔑 Token: ${token != null ? 'Var' : 'Yok'}');

      if (token == null) {
        debugPrint('❌ Token bulunamadı!');
        return [];
      }

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/timeline/entries'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'page': 1,
          'per_page': 20,
          'sort': 'latest',
        }),
      );

      //debugPrint('📥 All entries status code: ${response.statusCode}');
      //debugPrint('📥 All entries full response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> entries = jsonBody['data'] ?? [];
        //debugPrint('📦 Alınan entry sayısı: ${entries.length}');

        if (entries.isEmpty) {
          //debugPrint('⚠️ Hiç entry bulunamadı!');
          return [];
        }

        //debugPrint('📝 Entry\'ler parse ediliyor...');
        final List<EntryModel> entryList = entries.map((entry) {
          //debugPrint('📌 Entry detayları:');
          //debugPrint('   ID: ${entry['id']}');
          //debugPrint('   İçerik: ${entry['content']}');
          //debugPrint('   Upvote: ${entry['upvote_count']}');
          //debugPrint('   Downvote: ${entry['downvote_count']}');
          //debugPrint('   Oluşturulma: ${entry['human_created_at']}');
          //debugPrint('   Topic: ${entry['topic']?['name']}');
          //debugPrint('   Kategori: ${entry['topic']?['topic_category']?['title']}');
          //debugPrint('   Kullanıcı: ${entry['user']?['name']}');
          return EntryModel.fromJson(entry);
        }).toList();

        debugPrint('✅ Entry\'ler başarıyla yüklendi');
        return entryList;
      } else {
        debugPrint('❌ All Entries Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
          debugPrint('❌ All Entries Error: $e');
      return [];
    }
  }

  Future<List<EntryModel>> fetchTimelineEntries() async {
    try {
      final response = await dio.get('/timeline/entries');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => EntryModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load timeline entries');
      }
    } catch (e) {
      throw Exception('Failed to load timeline entries: $e');
    }
  }

  Future<UserModel?> fetchUserById(int userId) async {
    try {
      final response = await dio.get('/users/$userId');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<TopicModel>> fetchAllTopics() async {
    try {
      final response = await dio.get('/topics', queryParameters: {
        'include': 'category,user,last_entry.user', // Tüm ilişkili verileri dahil et
        'with': 'last_entry.user,category', // İlişkili modelleri yükle
      });

      debugPrint("📥 Raw Response from fetchAllTopics: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final List<TopicModel> topics = data.map((json) {
          // debugPrint("📦 Topic JSON: $json");
          // debugPrint("📦 Last Entry JSON: ${json['last_entry']}");
          return TopicModel.fromJson(json);
        }).toList();
        // debugPrint("Response from fetchAllTopics: $topics");
        return topics;
      } else {
        // debugPrint("⚠️ Failed to fetch topics: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // debugPrint("⚠️ Error fetching topics: $e");
      return [];
    }
  }

  Future<List<TopicModel>> fetchTopicsByCategory(int categoryId) async {
    try {
      final response = await dio.get('/timeline/topics', queryParameters: {
        'topic_category_id': categoryId,
        'include': 'category,user,last_entry,last_entry.user',
        'with': 'last_entry.user,category',
      });

      // debugPrint("📥 Raw Response for category $categoryId: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => TopicModel.fromJson(json)).toList();
      } else {
        debugPrint("⚠️ Failed to fetch topics for category $categoryId: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("❗ Error fetching topics for category $categoryId: $e");
      return [];
    }
  }
}
