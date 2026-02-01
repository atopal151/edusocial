// group_services.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:edusocial/components/print_full_text.dart';
import 'package:edusocial/models/group_models/grup_suggestion_model.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../models/group_models/group_model.dart';
import '../../models/group_models/group_detail_model.dart';

class GroupServices {
  // OPTIMIZE: HTTP client configuration for better network resilience
  static final http.Client _httpClient = http.Client();

  // RETRY: Configuration for retry mechanism
  static const int _maxRetries = 3;
  static const Duration _baseDelay =
      Duration(seconds: 3); // 2'den 3'e çıkarıldı
  static const Duration _requestTimeout =
      Duration(seconds: 30); // 15'ten 30'a çıkarıldı

  /// RETRY: Generic retry mechanism for HTTP requests
  static Future<http.Response> _makeRequestWithRetry(
      Future<http.Response> Function() request,
      {String operation = 'API call'}) async {
    Exception? lastException;

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        //debugPrint('🔄 $operation - Attempt $attempt/$_maxRetries');

        final response = await request().timeout(_requestTimeout);

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (attempt > 1) {
            //debugPrint('✅ $operation - Success on attempt $attempt');
          }
          return response;
        } else {
          throw HttpException(
              'HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      } on SocketException catch (e) {
        lastException = e;
        //debugPrint('🌐 $operation - Network error on attempt $attempt: ${e.message}');

        if (attempt < _maxRetries) {
          final delay = _baseDelay * attempt; // Exponential backoff
          debugPrint('⏳ Retrying in ${delay.inSeconds} seconds...');
          await Future.delayed(delay);
        }
      } on TimeoutException catch (e) {
        lastException = e;
        //debugPrint('⏰ $operation - Timeout on attempt $attempt');

        if (attempt < _maxRetries) {
          final delay = _baseDelay * attempt;
          debugPrint('⏳ Retrying in ${delay.inSeconds} seconds...');
          await Future.delayed(delay);
        }
      } on HttpException catch (e) {
        lastException = e;
        debugPrint('🔴 $operation - HTTP error on attempt $attempt: $e');

        // Don't retry for 4xx errors (client errors)
        if (e.toString().contains('4')) {
          rethrow;
        }

        if (attempt < _maxRetries) {
          final delay = _baseDelay * attempt;
          await Future.delayed(delay);
        }
      } catch (e) {
        lastException = Exception(e.toString());
        debugPrint('❌ $operation - Unexpected error on attempt $attempt: $e');

        if (attempt < _maxRetries) {
          final delay = _baseDelay * attempt;
          await Future.delayed(delay);
        }
      }
    }

    debugPrint('💥 $operation - All $_maxRetries attempts failed');
    throw lastException ?? Exception('All retry attempts failed');
  }

//ana sayfa içerisinde çıkacak olan önerilen group alanı endpointi
  Future<List<GroupSuggestionModel>> fetchSuggestionGroups() async {
    final box = GetStorage();
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/timeline/groups"),
        headers: {
          'Authorization': 'Bearer ${box.read('token')}',
        },
      );
      /*debugPrint("📥 Group Suggestion Response: ${response.statusCode}",
         wrapWidth: 1024);
      debugPrint("📥 Group Suggestion Body: ${response.body}", wrapWidth: 1024);*/

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        return data.map((item) => GroupSuggestionModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      /*debugPrint("❗ Group Suggestion error: $e", wrapWidth: 1024);*/
      return [];
    }
  }

  Future<List<GroupModel>> fetchUserGroups() async {
    final box = GetStorage();
    final token = box.read('token');

    try {
      // Hem kullanıcının üye olduğu hem de admin olduğu grupları getir
      final uri = Uri.parse("${AppConstants.baseUrl}/me/groups");

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // API'dan gelen ham grup listesi response datasını printfulltext ile yazdır
      printFullText('👥 =======================================');
      printFullText('👥 [GroupService] User Groups API Response');
      printFullText('👥 =======================================');
      printFullText('👥 URL: $uri');
      printFullText('👥 Status Code: ${response.statusCode}');
      printFullText('👥 Response Body: ${response.body}');
      printFullText('👥 =======================================');

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        final userGroupList =
            data.map((item) => GroupModel.fromJson(item)).toList();

        // Kullanıcının admin olduğu grupları da ekle
        // Eğer API'den gelen verilerde isFounder=true olan gruplar varsa, bunlar zaten dahil edilmiş olmalı
        // Ancak eğer eksikse, tüm grupları kontrol edip admin olduğu grupları da ekleyelim
        final allGroups = await fetchAllGroups();
        final adminGroups =
            allGroups.where((group) => group.isFounder).toList();

        // Admin gruplarını userGroupList'e ekle (eğer zaten yoksa)
        for (final adminGroup in adminGroups) {
          final exists =
              userGroupList.any((group) => group.id == adminGroup.id);
          if (!exists) {
            userGroupList.add(adminGroup);
            printFullText(
                "🔍 ADMIN GROUP EKLENDİ: ${adminGroup.name} (ID: ${adminGroup.id})");
          }
        }

        return userGroupList;
      } else {
        debugPrint("❌ Sunucudan beklenmeyen yanıt: ${response.statusCode}");
        debugPrint("❌ Error Body: ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("💥 Kullanıcı grupları alınırken hata oluştu: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchGroupAreas() async {
    final box = GetStorage();
    final token = box.read('token');

    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/groups/areas"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];
        return List<Map<String, dynamic>>.from(data);
      } else {
        debugPrint("❌ Grup alanları alınamadı. Status: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("💥 Grup alanları alınırken hata oluştu: $e");
      return [];
    }
  }

  Future<List<GroupModel>> fetchAllGroups() async {
    final box = GetStorage();
    final token = box.read('token');

    try {
      final uri = Uri.parse("${AppConstants.baseUrl}/groups");

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      /*printFullText("📥 ALL GROUPS API RESPONSE:");
      printFullText("Status Code: ${response.statusCode}");
      printFullText("Response Body: ${response.body}");*/

      // Her grubun detayını ayrı ayrı yazdır
      /*if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        printFullText("🔍 ALL GROUPS - TOPLAM ${data.length} GRUP:");
        for (int i = 0; i < data.length; i++) {
          final group = data[i];
          /*printFullText("""
📋 ALL GROUP ${i + 1}:
  - ID: ${group['id']}
  - Name: ${group['name']}
  - Description: ${group['description']}
  - Is Private: ${group['is_private']}
  - Is Founder: ${group['is_founder']}
  - Is Member: ${group['is_member']}
  - Is Pending: ${group['is_pending']}
  - User Count: ${group['user_count_with_admin']}
  - Message Count: ${group['message_count']}
  - Created At: ${group['created_at']}
  - Updated At: ${group['updated_at']}
  ---
""");*/
        }
      }*/

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        final groupList =
            data.map((item) => GroupModel.fromJson(item)).toList();

        return groupList;
      } else {
        debugPrint("❌ Sunucudan beklenmeyen yanıt alındı.", wrapWidth: 1024);
        return [];
      }
    } catch (e) {
      debugPrint("💥 Hata oluştu: $e", wrapWidth: 1024);
      return [];
    }
  }

  Future<bool> sendJoinRequest(String groupId) async {
    final box = GetStorage();
    final token = box.read('token');

    try {
      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}/group-join"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "group_id": groupId,
        }),
      );

      //debugPrint("📤 Join request status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint("❌ Katılma isteği başarısız: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("💥 Join isteği hatası: $e");
      return false;
    }
  }

  /// PAGINATION: Fetch group messages with pagination support
  Future<List<dynamic>> fetchGroupMessagesWithPagination(
    String groupId, {
    int limit = 1000, // Increased from 25 to 1000 to remove limit
    int offset = 0,
  }) async {
    final box = GetStorage();
    try {
      //debugPrint('📱 Fetching paginated group messages for ID: $groupId');
      //debugPrint('📊 Pagination: limit=$limit, offset=$offset');

      final uri = Uri.parse('${AppConstants.baseUrl}/group-messages/$groupId')
          .replace(queryParameters: {
        'limit': limit.toString(),
        'offset': offset.toString(),
        'sort': 'desc', // En yeniden eskiye
      });

      // RETRY: Use retry mechanism for network resilience
      final response = await _makeRequestWithRetry(
        () => _httpClient.get(
          uri,
          headers: {
            'Authorization': 'Bearer ${box.read('token')}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        operation: 'Fetch Paginated Group Messages',
      );

      //debugPrint('📥 Paginated group messages response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['status'] == true && jsonBody['data'] != null) {
          final messages = jsonBody['data'] as List? ?? [];
          printFullText("GROUPS MESSAGES DATA:${json.encode(messages)}");
          //debugPrint('✅ ${messages.length} group messages loaded (paginated)');
          return messages;
        }
      }

      debugPrint(
          '❌ Failed to fetch paginated group messages: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('❌ Paginated group messages fetch error: $e');
      return [];
    }
  }

  /// OPTIMIZED: Faster group detail fetching with minimal data
  Future<GroupDetailModel> fetchGroupDetail(String groupId) async {
    final box = GetStorage();
    try {
      //debugPrint('🚀 Optimized group detail fetch for ID: $groupId');

      // OPTIMIZE: Add query parameters to request only essential data
      final uri = Uri.parse('${AppConstants.baseUrl}/group-detail/$groupId')
          .replace(queryParameters: {
        'minimal': 'true', // Request minimal data if backend supports
        'limit_messages': '1000', // Increased from 50 to 1000 to remove limit
        'include': 'messages,basic_info', // Only essential data
      });

      // RETRY: Use retry mechanism for network resilience
      final response = await _makeRequestWithRetry(
        () => _httpClient.get(
          uri,
          headers: {
            'Authorization': 'Bearer ${box.read('token')}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        operation: 'Fetch Group Detail',
      );

      //debugPrint('📡 Group detail response time: ${DateTime.now()}');

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);

        // API'den gelen ham veriyi debug et
        /*printFullText('🔍 =======================================');
        printFullText('🔍 GROUP DETAIL API RAW RESPONSE');
        printFullText('🔍 =======================================');
        printFullText('🔍 URL: ${uri.toString()}');
        printFullText('🔍 Status Code: ${response.statusCode}');
        printFullText('🔍 Response Headers: ${response.headers}');
        printFullText('🔍 Raw Response Body:');
        printFullText(response.body);
        printFullText('🔍 =======================================');
        */
        if (jsonBody['status'] == true && jsonBody['data'] != null) {
          // Pin durumlarını ve okunmamış mesaj sayısını kontrol et
          final groupData = jsonBody['data']['group'];
          final groupChats = groupData['group_chats'] as List? ?? [];

          printFullText(
              '🔍 [GroupService] === PIN DURUMU VE OKUNMAMIŞ MESAJ KONTROLÜ ===');
          printFullText(
              '🔍 [GroupService] Toplam mesaj sayısı: ${groupChats.length}');

          // API'dan gelen unread_messages_total_count'u kullan
          final userData = groupData['user'];
          final apiUnreadCount = userData['unread_messages_total_count'] ?? 0;

          debugPrint(
              '🔍 [GroupService] API\'dan gelen unread count: $apiUnreadCount');

          for (int i = 0; i < groupChats.length; i++) {
            final chat = groupChats[i];
            final messageId = chat['id'];
            final isPinned = chat['is_pinned'] ?? false;
            final isRead = chat['is_read'] ?? true;
            final messageContent = chat['message'];
            final userId = chat['user_id'];

            printFullText(
                '🔍 [GroupService] Mesaj $i: ID=$messageId, user_id=$userId, is_pinned=$isPinned, is_read=$isRead, content="$messageContent"');
          }

          /*printFullText('🔍 [GroupService] === ÖZET ===');
          printFullText('🔍 [GroupService] Toplam mesaj: ${groupChats.length}');
          printFullText('🔍 [GroupService] API Unread Count: $apiUnreadCount');
          printFullText('🔍 [GroupService] Pinli mesaj: $pinnedMessageCount');
          printFullText('🔍 [GroupService] === KONTROL TAMAMLANDI ===');*/

          // API'dan gelen unread count'u logla
          debugPrint(
              '📊 [GroupService] API\'dan gelen unread count: $apiUnreadCount');

          return GroupDetailModel.fromJson(jsonBody['data']);
        }
        throw Exception('No group data found');
      } else {
        debugPrint('❌ API Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to fetch group details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Group detail fetch error: $e');
      rethrow;
    }
  }

  /// CACHE: Simple in-memory cache for group details
  static final Map<String, GroupDetailModel> _groupCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheTimeout = Duration(minutes: 5);

  /// Get group detail with caching
  Future<GroupDetailModel> fetchGroupDetailCached(String groupId) async {
    // Check cache first
    if (_groupCache.containsKey(groupId) &&
        _cacheTimestamps.containsKey(groupId)) {
      final cacheTime = _cacheTimestamps[groupId]!;
      if (DateTime.now().difference(cacheTime) < _cacheTimeout) {
        //debugPrint('✅ Returning cached group data for ID: $groupId');
        return _groupCache[groupId]!;
      }
    }

    // Fetch fresh data
    final groupDetail = await fetchGroupDetail(groupId);

    // Cache the result
    _groupCache[groupId] = groupDetail;
    _cacheTimestamps[groupId] = DateTime.now();

    //debugPrint('💾 Cached group data for ID: $groupId');
    return groupDetail;
  }

  /// Clear cache when needed
  static void clearGroupCache() {
    _groupCache.clear();
    _cacheTimestamps.clear();
    debugPrint('🗑️ Group cache cleared');
  }

  Future<bool> sendGroupMessage({
    required String groupId,
    String? message,
    List<File>? mediaFiles,
    List<String>? links,
    List<String>? pollOptions,
  }) async {
    final box = GetStorage();
    final token = box.read('token');

    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/group-message');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['group_id'] = groupId;

      // Message alanını her zaman gönder (boş string olsa bile)
      request.fields['message'] = message ?? '';

      // Media dosyalarını ekle
      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        for (int i = 0; i < mediaFiles.length; i++) {
          final file = mediaFiles[i];
          if (await file.exists()) {
            final fileExtension = file.path.split('.').last.toLowerCase();
            String mimeType = 'application/octet-stream';

            // MIME type belirle
            if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
              mimeType = 'image/$fileExtension';
            } else if (['pdf'].contains(fileExtension)) {
              mimeType = 'application/pdf';
            } else if (['doc', 'docx'].contains(fileExtension)) {
              mimeType = 'application/msword';
            } else if (['txt'].contains(fileExtension)) {
              mimeType = 'text/plain';
            }

            request.files.add(await http.MultipartFile.fromPath(
              'media[]',
              file.path,
              contentType: MediaType.parse(mimeType),
            ));
          }
        }
      }

      // Linkleri ekle
      if (links != null && links.isNotEmpty) {
        for (int i = 0; i < links.length; i++) {
          request.fields['links[]'] = links[i];
        }
      }

      // Poll seçeneklerini ekle
      if (pollOptions != null && pollOptions.isNotEmpty) {
        for (int i = 0; i < pollOptions.length; i++) {
          request.fields['poll_options[]'] = pollOptions[i];
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('❌ Send group message failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('💥 Send group message error: $e');
      return false;
    }
  }

  // Kullanıcının katıldığı grupları al
  Future<List<GroupModel>?> getUserGroups() async {
    final box = GetStorage();
    final token = box.read('token');
    try {
      final response = await _makeRequestWithRetry(
        () => http.get(
          Uri.parse('${AppConstants.baseUrl}/timeline/groups'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        operation: 'Get User Groups',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        final List<dynamic> data = responseData['data'] as List<dynamic>;

        final List<GroupModel> groups =
            data.map((json) => GroupModel.fromJson(json)).toList();
        return groups;
      } else {
        debugPrint(
            '❌ Get user groups failed with status: ${response.statusCode}');
        debugPrint('❌ Error Response Body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('💥 Get user groups error: $e');
      return null;
    }
  }

  /// Gruptan ayrılma işlemi (Withdraw Group Invitation endpoint'i kullanarak)
  Future<bool> withdrawGroupInvitation(String groupId) async {
    final box = GetStorage();
    final token = box.read('token');

    try {
      debugPrint(
          "🔄 Gruptan ayrılma isteği gönderiliyor... Group ID: $groupId");

      final response = await http.put(
        Uri.parse("${AppConstants.baseUrl}/group-join/$groupId"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      debugPrint(
          "📤 Withdraw group invitation response: ${response.statusCode}");
      debugPrint("📤 Withdraw group invitation body: ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        debugPrint("✅ Gruptan başarıyla ayrıldı");
        return true;
      } else {
        debugPrint("❌ Gruptan ayrılma başarısız: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("💥 Withdraw group invitation error: $e");
      return false;
    }
  }

  /// Grubu silme işlemi (sadece grup kurucusu yapabilir)
  Future<bool> deleteGroup(String groupId) async {
    final box = GetStorage();
    final token = box.read('token');

    try {
      debugPrint("🔄 Grup silme isteği gönderiliyor... Group ID: $groupId");

      final response = await http.delete(
        Uri.parse("${AppConstants.baseUrl}/groups/$groupId"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("📤 Delete group response: ${response.statusCode}");
      debugPrint("📤 Delete group body: ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        debugPrint("✅ Grup başarıyla silindi");
        return true;
      } else {
        debugPrint("❌ Grup silme başarısız: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("💥 Delete group error: $e");
      return false;
    }
  }
}
