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

class ChatServices {
  static final _box = GetStorage();
  
  // OPTIMIZE: HTTP client configuration for better network resilience
  static final http.Client _httpClient = http.Client();
  
  // RETRY: Configuration for retry mechanism
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(seconds: 2);
  static const Duration _requestTimeout = Duration(seconds: 15);

  /// RETRY: Generic retry mechanism for HTTP requests
  static Future<http.Response> _makeRequestWithRetry(
    Future<http.Response> Function() request,
    {String operation = 'API call'}
  ) async {
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
          throw HttpException('HTTP ${response.statusCode}: ${response.reasonPhrase}');
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
          //debugPrint('⏳ Retrying in ${delay.inSeconds} seconds...');
          await Future.delayed(delay);
        }
        
      } on HttpException catch (e) {
        lastException = e;
        //debugPrint('🔴 $operation - HTTP error on attempt $attempt: $e');
        
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

    // Debug logları ekle
    //debugPrint('📤 ChatServices.sendMessage called:');
    //debugPrint('  - Receiver ID: $receiverId');
    //debugPrint('  - Message: "$message"');
    //debugPrint('  - Conversation ID: $conversationId');
    //debugPrint('  - Media files: ${mediaFiles?.length ?? 0}');
    //debugPrint('  - Links: ${links?.length ?? 0}');

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
        debugPrint('⚠️ Toplam dosya: ${mediaFiles.length}, Görsel: ${imageFiles.length}');
        
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

        //debugPrint('  - File: ${file.path}');
        //debugPrint('  - Extension: $fileExtension');
        //debugPrint('  - MIME Type: $mimeType');
        //debugPrint('  - Field Name: media[]');

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

      //debugPrint('📥 Response status: ${response.statusCode}');
      //debugPrint('📥 Response body: ${response.body}');

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

      // Raw API response'u yazdır
      printFullText('''
🌐 ONLINE FRIENDS API RAW RESPONSE
====================================
📡 URL: ${url.toString()}
📊 Status Code: ${response.statusCode}
📦 Raw Response Body:
${response.body}
====================================
''');

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
    int limit = 1000,  // Increased from 25 to 1000 to remove limit
    int offset = 0,  // Hangi mesajdan başlayacağı
  }) async {
    final token = _box.read('token');
    final currentUserId = _box.read('userId');
    
    // OPTIMIZE: Query parameters ile pagination
    final uri = Uri.parse('${AppConstants.baseUrl}/conversation/$conversationId').replace(
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

    // Raw API response'u yazdır
    printFullText('''
🌐 PRIVATE CHAT MESSAGES API RAW RESPONSE
==========================================
📡 URL: $uri
📊 Status Code: ${response.statusCode}
📦 Raw Response Body:
${response.body}
==========================================
''');

    final body = jsonDecode(response.body);
    final List<dynamic> messagesJson = body['data'];
    
    //debugPrint("✅ ${messagesJson.length} mesaj yüklendi (pagination)");
    
    // İlk 5 mesajın detayını göster
    //debugPrint("📖 === İLK 5 MESAJ DETAYI ===");
    for (int i = 0; i < messagesJson.length && i < 5; i++) {
      final message = messagesJson[i];
      //debugPrint("📖 Mesaj ${i + 1}:");
      //debugPrint("  - ID: ${message['id']}");
      //debugPrint("  - Message: ${message['message']}");
      //debugPrint("  - Sender ID: ${message['sender_id']}");
      //debugPrint("  - Is Read: ${message['is_read']}");
      //debugPrint("  - Is Me: ${message['is_me']}");
      //debugPrint("  - Created At: ${message['created_at']}");
      //debugPrint("  - Raw JSON: ${jsonEncode(message)}");
      //debugPrint("  - ---");
    }
    //debugPrint("📖 =========================");

    return messagesJson
        .map((json) => MessageModel.fromJson(json as Map<String, dynamic>,
            currentUserId: currentUserId))
        .toList();
  }

  /// Eski API metodu (backward compatibility)
  static Future<List<MessageModel>> fetchAllConversationMessages(int conversationId) async {
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

      final body = jsonDecode(response.body);
      //debugPrint("✅ Chat List API Response:");
      //debugPrint("📊 Response Status: ${response.statusCode}");
      //debugPrint("📊 Response Body: ${jsonEncode(body)}");
      //debugPrint("📊 Response Data Type: ${body.runtimeType}");
      if (body is Map<String, dynamic>) {
        //  debugPrint("📊 Response Keys: ${body.keys.toList()}");
        if (body.containsKey('data')) {
          final data = body['data'];
          //debugPrint("📊 Data Type: ${data.runtimeType}");
          if (data is List && data.isNotEmpty) {
            //debugPrint("📊 First Item Keys: ${(data.first as Map<String, dynamic>).keys.toList()}");
          }
        }
      }

      if (body is Map<String, dynamic> && body.containsKey('data')) {
        final data = body['data'];
        if (data is List) {
          final chatList = data.map((json) {
            //debugPrint("📖 === CHAT ITEM FULL DEBUG ===");
            //debugPrint("📖 Raw JSON: ${jsonEncode(json)}");
            //debugPrint("📖 User ID: ${json['id']}");
            //debugPrint("📖 Name: ${json['name']}");
            //debugPrint("📖 Raw JSON Keys: ${json.keys.toList()}");
            //debugPrint("📖 Unread Count (unread_count): ${json['unread_count']} (type: ${json['unread_count']?.runtimeType})");
            //debugPrint("📖 Unread Count (unread_messages_total_count): ${json['unread_messages_total_count']} (type: ${json['unread_messages_total_count']?.runtimeType})");
            //debugPrint("📖 Unread Count (unreadCount): ${json['unreadCount']} (type: ${json['unreadCount']?.runtimeType})");
            //debugPrint("📖 Unread Count (unread_message_count): ${json['unread_message_count']} (type: ${json['unread_message_count']?.runtimeType})");
            //debugPrint("📖 Unread Count (message_count): ${json['message_count']} (type: ${json['message_count']?.runtimeType})");
            //debugPrint("📖 Unread Count (count): ${json['count']} (type: ${json['count']?.runtimeType})");
            //debugPrint("📖 Last Message: ${json['last_message']?['message'] ?? 'No message'}");
            //debugPrint("📖 Last Message Created: ${json['last_message']?['created_at'] ?? 'No date'}");
            //debugPrint("📖 ==============================");
            return ChatModel.fromJson(json);
          }).toList();
          
          // Toplam okunmamış mesaj sayısını hesapla
          final totalUnread = chatList.fold(0, (sum, chat) => sum + chat.unreadCount);
          //debugPrint("📊 === CHAT LIST SUMMARY ===");
          //debugPrint("📊 Toplam Chat Sayısı: ${chatList.length}");
          //debugPrint("📊 Toplam Okunmamış Mesaj: $totalUnread");
          //debugPrint("📊 Okunmamış Mesajı Olan Chat'ler:");
          for (var chat in chatList) {
            if (chat.unreadCount > 0) {
              //  debugPrint("  - ${chat.name} (${chat.username}): ${chat.unreadCount} okunmamış mesaj");
            }
          }
          //debugPrint("📊 =========================");
          
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

      //debugPrint('  - URL: $url');
      //debugPrint('  - UserID: $userId');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      //debugPrint('📥 fetchUserDetails - API Yanıtı:');
      //debugPrint('  - Status Code: ${response.statusCode}');
      //debugPrint('  - Body: ${response.body}');

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
      //debugPrint('❌ fetchUserDetails - Hata: $e');
      //debugPrint('  - Hata Mesajı: ${e.toString()}');
      throw Exception('Kullanıcı bilgileri getirilemedi!');
    }
  }
}
