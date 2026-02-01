import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:edusocial/models/chat_models/chat_detail_model.dart';
import 'package:edusocial/models/chat_models/chat_user_model.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/chat_models/chat_model.dart';
import '../models/user_chat_detail_model.dart';
import '../components/print_full_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_helper.dart';

class ChatServices {
  static final _box = GetStorage();

  // Kırmızı nokta durumunu kaydetmek için key
  static const String _unreadChatsKey = 'unread_chat_conversation_ids';
  static const String _unreadGroupsKey = 'unread_group_ids';
  static const String _totalUnreadCountKey = 'total_unread_count';

  /// 🔴 Kırmızı nokta olan conversation ID'leri kaydet
  static Future<void> saveUnreadChats(List<int> conversationIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = conversationIds.map((id) => id.toString()).toList();
      await prefs.setStringList(_unreadChatsKey, jsonList);
      printFullText('💾 Kırmızı nokta durumları kaydedildi: $conversationIds');
    } catch (e) {
      printFullText('❌ Kırmızı nokta durumları kaydedilemedi: $e');
    }
  }

  /// 🔴 Kırmızı nokta olan conversation ID'leri geri yükle
  static Future<List<int>> loadUnreadChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_unreadChatsKey) ?? [];
      final conversationIds = jsonList.map((id) => int.parse(id)).toList();
      printFullText('📂 Kırmızı nokta durumları yüklendi: $conversationIds');
      return conversationIds;
    } catch (e) {
      printFullText('❌ Kırmızı nokta durumları yüklenemedi: $e');
      return [];
    }
  }

  /// 🔴 Belirli bir conversation'ı okunmuş olarak işaretle
  static Future<void> markConversationAsRead(int conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_unreadChatsKey) ?? [];
      final conversationIds = jsonList.map((id) => int.parse(id)).toList();

      // Conversation ID'yi listeden çıkar
      conversationIds.remove(conversationId);

      // Güncellenmiş listeyi kaydet
      final updatedJsonList =
          conversationIds.map((id) => id.toString()).toList();
      await prefs.setStringList(_unreadChatsKey, updatedJsonList);

      printFullText(
          '✅ Conversation $conversationId okunmuş olarak işaretlendi');
    } catch (e) {
      printFullText('❌ Conversation okunmuş olarak işaretlenemedi: $e');
    }
  }

  /// 🔴 Belirli bir conversation'ı okunmamış olarak işaretle
  static Future<void> markConversationAsUnread(int conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_unreadChatsKey) ?? [];
      final conversationIds = jsonList.map((id) => int.parse(id)).toList();

      // Conversation ID'yi listeye ekle (eğer yoksa)
      if (!conversationIds.contains(conversationId)) {
        conversationIds.add(conversationId);
      }

      // Güncellenmiş listeyi kaydet
      final updatedJsonList =
          conversationIds.map((id) => id.toString()).toList();
      await prefs.setStringList(_unreadChatsKey, updatedJsonList);

      printFullText(
          '🔴 Conversation $conversationId okunmamış olarak işaretlendi');
    } catch (e) {
      printFullText('❌ Conversation okunmamış olarak işaretlenemedi: $e');
    }
  }

  /// 🔴 Kırmızı nokta olan grup ID'lerini kaydet
  static Future<void> saveUnreadGroups(List<int> groupIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = groupIds.map((id) => id.toString()).toList();
      await prefs.setStringList(_unreadGroupsKey, jsonList);
      printFullText('💾 Grup kırmızı nokta durumları kaydedildi: $groupIds');
    } catch (e) {
      printFullText('❌ Grup kırmızı nokta durumları kaydedilemedi: $e');
    }
  }

  /// 🔴 Kırmızı nokta olan grup ID'lerini geri yükle
  static Future<List<int>> loadUnreadGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_unreadGroupsKey) ?? [];
      final groupIds = jsonList.map((id) => int.parse(id)).toList();
      printFullText('📂 Grup kırmızı nokta durumları yüklendi: $groupIds');
      return groupIds;
    } catch (e) {
      printFullText('❌ Grup kırmızı nokta durumları yüklenemedi: $e');
      return [];
    }
  }

  /// 🔴 Belirli bir grubu okunmuş olarak işaretle
  static Future<void> markGroupAsRead(int groupId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_unreadGroupsKey) ?? [];
      final groupIds = jsonList.map((id) => int.parse(id)).toList();

      // Group ID'yi listeden çıkar
      groupIds.remove(groupId);

      // Güncellenmiş listeyi kaydet
      final updatedJsonList = groupIds.map((id) => id.toString()).toList();
      await prefs.setStringList(_unreadGroupsKey, updatedJsonList);

      printFullText('✅ Grup $groupId okunmuş olarak işaretlendi');
    } catch (e) {
      printFullText('❌ Grup okunmuş olarak işaretlenemedi: $e');
    }
  }

  /// 🔴 Belirli bir grubu okunmamış olarak işaretle
  static Future<void> markGroupAsUnread(int groupId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_unreadGroupsKey) ?? [];
      final groupIds = jsonList.map((id) => int.parse(id)).toList();

      // Group ID'yi listeye ekle (eğer yoksa)
      if (!groupIds.contains(groupId)) {
        groupIds.add(groupId);
      }

      // Güncellenmiş listeyi kaydet
      final updatedJsonList = groupIds.map((id) => id.toString()).toList();
      await prefs.setStringList(_unreadGroupsKey, updatedJsonList);

      printFullText('🔴 Grup $groupId okunmamış olarak işaretlendi');
    } catch (e) {
      printFullText('❌ Grup okunmamış olarak işaretlenemedi: $e');
    }
  }

  /// 🔴 Tüm kırmızı nokta durumlarını temizle
  static Future<void> clearAllUnreadChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_unreadChatsKey);
      printFullText('🗑️ Tüm kırmızı nokta durumları temizlendi');
    } catch (e) {
      printFullText('❌ Kırmızı nokta durumları temizlenemedi: $e');
    }
  }

  /// 📊 Toplam unread count'u kaydet
  static Future<void> saveTotalUnreadCount(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_totalUnreadCountKey, count);
      printFullText('💾 Toplam unread count kaydedildi: $count');
    } catch (e) {
      printFullText('❌ Toplam unread count kaydedilemedi: $e');
    }
  }

  /// 📊 Toplam unread count'u geri yükle
  static Future<int> loadTotalUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(_totalUnreadCountKey) ?? 0;
      printFullText('📂 Toplam unread count yüklendi: $count');
      return count;
    } catch (e) {
      printFullText('❌ Toplam unread count yüklenemedi: $e');
      return 0;
    }
  }

  // OPTIMIZE: HTTP client configuration for better network resilience
  static final http.Client _httpClient = http.Client();

  // RETRY: Configuration for retry mechanism
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(seconds: 2);
  static const Duration _requestTimeout = Duration(seconds: 15);

  /// RETRY: Generic retry mechanism for HTTP requests
  static Future<http.Response> _makeRequestWithRetry(
      Future<http.Response> Function() request,
      {String operation = 'API call'}) async {
    Exception? lastException;

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final response = await request().timeout(_requestTimeout);

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (attempt > 1) {
            debugPrint('✅ $operation - Success on attempt $attempt');
          }
          return response;
        } else {
          throw HttpException(
              'HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      } on SocketException catch (e) {
        lastException = e;
        debugPrint(
            '🌐 $operation - Network error on attempt $attempt: ${e.message}');

        if (attempt < _maxRetries) {
          final delay = _baseDelay * attempt; // Exponential backoff
          debugPrint('⏳ Retrying in ${delay.inSeconds} seconds...');
          await Future.delayed(delay);
        }
      } on TimeoutException catch (e) {
        lastException = e;

        if (attempt < _maxRetries) {
          final delay = _baseDelay * attempt;
          await Future.delayed(delay);
        }
      } on HttpException catch (e) {
        lastException = e;

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

  static Future<void> sendMessage(
    int receiverId,
    String message, {
    String? conversationId,
    List<File>? mediaFiles,
    List<String>? links,
  }) async {
    final token = _box.read('token');
    final url = Uri.parse('${AppConstants.baseUrl}/conversation');

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    // Text alanları ekle
    request.fields['receiver_id'] = receiverId.toString();
    if (conversationId != null) {
      request.fields['conversation_id'] = conversationId;
    }

    // Mesaj alanını her zaman gönder (boş string olsa bile)
    // Backend "conversation.message.required_without_all" hatası veriyor
    request.fields['message'] = message.isEmpty ? ' ' : message;

    // Linkleri ekle
    if (links != null && links.isNotEmpty) {
      for (var i = 0; i < links.length; i++) {
        request.fields['links[$i]'] = links[i];
      }
    }

    // Medya dosyalarını ekle (Sadece görsel dosyalar - private chat için)
    if (mediaFiles != null && mediaFiles.isNotEmpty) {
      //debugPrint('📁 Adding media files to request:');

      // Sadece görsel dosyaları kabul et (private chat için)
      final imageFiles = mediaFiles.where((file) {
        final fileExtension = file.path.split('.').last.toLowerCase();
        return [
          // Sadece görsel dosyalar
          'jpg', 'jpeg', 'png', 'gif', 'webp'
        ].contains(fileExtension);
      }).toList();

      if (imageFiles.length != mediaFiles.length) {
        debugPrint('⚠️ Private chat\'te sadece görsel dosyalar desteklenir!');
        debugPrint(
            '⚠️ Toplam dosya: ${mediaFiles.length}, Görsel: ${imageFiles.length}');

        // Doküman dosyalarını listele
        final documentFiles = mediaFiles.where((file) {
          final fileExtension = file.path.split('.').last.toLowerCase();
          return ['pdf', 'doc', 'docx', 'txt', 'rtf'].contains(fileExtension);
        }).toList();

        for (var file in documentFiles) {
          debugPrint('❌ Doküman dosyası (desteklenmiyor): ${file.path}');
        }
      }

      for (var file in imageFiles) {
        final fileExtension = file.path.split('.').last.toLowerCase();
        String mimeType = _getMimeType(fileExtension);

        request.files.add(
          await http.MultipartFile.fromPath(
            'media[]',
            file.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }
      //debugPrint('📁 Total files added: ${request.files.length}');
    }

    try {
      //debugPrint('📤 Sending request to: $url');
      var streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // API'dan gelen ham send message response datasını printfulltext ile yazdır
      printFullText('📤 =======================================');
      printFullText('📤 [ChatService] Send Message API Response');
      printFullText('📤 =======================================');
      printFullText('📤 URL: $url');
      printFullText('📤 Receiver ID: $receiverId');
      printFullText('📤 Conversation ID: $conversationId');
      printFullText('📤 Status Code: ${response.statusCode}');
      printFullText('📤 Response Body: ${response.body}');
      printFullText('📤 =======================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Mesaj başarıyla gönderildi!");
      } else {
        debugPrint('❌ Mesaj gönderilemedi: ${response.statusCode}');
        debugPrint('❌ Response body: ${response.body}');
        throw Exception('Mesaj gönderilemedi');
      }
    } catch (e) {
      debugPrint('❌ Mesaj gönderme hatası: $e');
      rethrow;
    }
  }

  /// Dosya uzantısına göre MIME type döndürür
  static String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      // Görsel dosyalar
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';

      // Doküman dosyalar
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'rtf':
        return 'application/rtf';

      default:
        return 'application/octet-stream';
    }
  }

  static Future<List<ChatUserModel>> fetchOnlineFriends() async {
    final token = _box.read('token');
    final url = Uri.parse("${AppConstants.baseUrl}/timeline/last-conversation");

    try {
      // RETRY: Use retry mechanism for network resilience
      final response = await _makeRequestWithRetry(
        () => _httpClient.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        operation: 'Fetch Online Friends',
      );

      // API'dan gelen ham online friends response datasını printfulltext ile yazdır
      printFullText('👥 =======================================');
      printFullText('👥 [ChatService] Online Friends API Response');
      printFullText('👥 =======================================');
      printFullText('👥 URL: $url');
      printFullText('👥 Status Code: ${response.statusCode}');
      printFullText('👥 Response Body: ${response.body}');
      printFullText('👥 =======================================');
      
      final body = jsonDecode(response.body);
      final dataList = body['data'] as List<dynamic>;

      final chatList =
          dataList.map((json) => ChatUserModel.fromJson(json)).toList();

      //debugPrint("✅ Chat List: $chatList");

      return chatList;
    } catch (e) {
      debugPrint("🛑 Online Friends Error: $e");
      rethrow;
    }
  }

  /// Mesaj detaylarını getir (Show Conversation) - PAGINATION SUPPORT ADDED
  static Future<List<MessageModel>> fetchConversationMessages(
    int conversationId, {
    int limit = 1000, // Increased from 25 to 1000 to remove limit
    int offset = 0, // Hangi mesajdan başlayacağı
  }) async {
    final token = _box.read('token');
    final currentUserId = _box.read('userId');

    // OPTIMIZE: Query parameters ile pagination
    final uri =
        Uri.parse('${AppConstants.baseUrl}/conversation/$conversationId')
            .replace(
      queryParameters: {
        'limit': limit.toString(),
        'offset': offset.toString(),
        'sort': 'desc', // En yeniden eskiye doğru
      },
    );

    //debugPrint("📱 Sohbet mesajları getiriliyor (PAGINATED): $uri");
    //debugPrint("📊 Pagination: limit=$limit, offset=$offset");

    // RETRY: Use retry mechanism for network resilience
    final response = await _makeRequestWithRetry(
      () => _httpClient.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
      operation: 'Fetch Conversation Messages',
    );

    // API'dan gelen ham conversation messages response datasını printfulltext ile yazdır
    printFullText('💬 =======================================');
    printFullText('💬 [ChatService] Conversation Messages API Response');
    printFullText('💬 =======================================');
    printFullText('💬 URL: $uri');
    printFullText('💬 Conversation ID: $conversationId');
    printFullText('💬 Limit: $limit, Offset: $offset');
    printFullText('💬 Status Code: ${response.statusCode}');
    printFullText('💬 Response Body: ${response.body}');
    printFullText('💬 =======================================');

    final body = jsonDecode(response.body);
    final List<dynamic> messagesJson = body['data'];

    return messagesJson
        .map((json) => MessageModel.fromJson(json as Map<String, dynamic>,
            currentUserId: currentUserId))
        .toList();
  }

  /// Eski API metodu (backward compatibility)
  static Future<List<MessageModel>> fetchAllConversationMessages(
      int conversationId) async {
    return fetchConversationMessages(conversationId, limit: 1000, offset: 0);
  }

  /// Birebir mesaj listesi çek
  static Future<List<ChatModel>> fetchChatList() async {
    try {
      final token = _box.read('token');

      // RETRY: Use retry mechanism for network resilience
      final response = await _makeRequestWithRetry(
        () => _httpClient.get(
          Uri.parse('${AppConstants.baseUrl}/conversation'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        operation: 'Fetch Chat List',
      );

      // API'dan gelen ham chat list response datasını printfulltext ile yazdır
      printFullText('💬 =======================================');
      printFullText('💬 [ChatService] Chat List API Response');
      printFullText('💬 =======================================');
      printFullText('💬 URL: ${AppConstants.baseUrl}/conversation');
      printFullText('💬 Status Code: ${response.statusCode}');
      printFullText('💬 Response Body: ${response.body}');
      printFullText('💬 =======================================');
      
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic> && body.containsKey('data')) {
        final data = body['data'];
        if (data is List) {
          final chatList = data.map((json) {
            return ChatModel.fromJson(json);
          }).toList();

          return chatList;
        } else {
          debugPrint(
              "⚠️ 'data' alanı liste değilmiş. Tip: ${data.runtimeType}");
          return [];
        }
      } else {
        debugPrint("⚠️ 'data' alanı yok veya map değil!");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Chat listesi çekilirken hata: $e");
      rethrow;
    }
  }

  /// Kullanıcı detaylarını getir
  static Future<UserChatDetailModel> fetchUserDetails(int userId) async {
    try {
      //debugPrint('🔍 fetchUserDetails - Başladı');
      final token = await _box.read('token');
      final url = '${AppConstants.baseUrl}/api/user/$userId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // API'dan gelen ham user details response datasını printfulltext ile yazdır
      printFullText('👤 =======================================');
      printFullText('👤 [ChatService] User Details API Response');
      printFullText('👤 =======================================');
      printFullText('👤 URL: $url');
      printFullText('👤 User ID: $userId');
      printFullText('👤 Status Code: ${response.statusCode}');
      printFullText('👤 Response Body: ${response.body}');
      printFullText('👤 =======================================');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final userData = data['data'];
          return UserChatDetailModel(
            id: userData['id'].toString(),
            name: '${userData['name']} ${userData['surname']}',
            follower: userData['follower_count']?.toString() ?? '0',
            following: userData['following_count']?.toString() ?? '0',
            imageUrl: userData['avatar'] ?? '',
            memberImageUrls: const [],
            documents: const [],
            links: const [],
            photoUrls: const [],
          );
        }
      }
      throw Exception('Kullanıcı bilgileri getirilemedi!');
    } catch (e) {
      debugPrint('❌ fetchUserDetails - Hata: $e');
      debugPrint('  - Hata Mesajı: ${e.toString()}');
      throw Exception('Kullanıcı bilgileri getirilemedi!');
    }
  }
}
