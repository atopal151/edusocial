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

class ChatServices {
  static final _box = GetStorage();

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
    debugPrint('📤 ChatServices.sendMessage called:');
    debugPrint('  - Receiver ID: $receiverId');
    debugPrint('  - Message: "$message"');
    debugPrint('  - Conversation ID: $conversationId');
    debugPrint('  - Media files: ${mediaFiles?.length ?? 0}');
    debugPrint('  - Links: ${links?.length ?? 0}');

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

    // Medya dosyalarını ekle
    if (mediaFiles != null && mediaFiles.isNotEmpty) {
      debugPrint('📁 Adding media files to request:');
      for (var file in mediaFiles) {
        final fileExtension = file.path.split('.').last.toLowerCase();
        String mimeType = 'application/octet-stream';
        String fieldName = 'media[]'; // Default field name
        
        // MIME type belirle
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
          mimeType = 'image/$fileExtension';
          fieldName = 'media[]'; // Resimler için media field
        } else if (['pdf'].contains(fileExtension)) {
          mimeType = 'application/pdf';
          fieldName = 'documents[]'; // PDF'ler için documents field
        } else if (['doc', 'docx'].contains(fileExtension)) {
          mimeType = 'application/msword';
          fieldName = 'documents[]'; // Word dosyaları için documents field
        } else if (['txt'].contains(fileExtension)) {
          mimeType = 'text/plain';
          fieldName = 'documents[]'; // Text dosyaları için documents field
        }
        
        debugPrint('  - File: ${file.path}');
        debugPrint('  - Extension: $fileExtension');
        debugPrint('  - MIME Type: $mimeType');
        debugPrint('  - Field Name: $fieldName');
        
        request.files.add(
          await http.MultipartFile.fromPath(
            fieldName,
            file.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }
      debugPrint('📁 Total files added: ${request.files.length}');
    }

    try {
      debugPrint('📤 Sending request to: $url');
      var streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

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

  static Future<List<ChatUserModel>> fetchOnlineFriends() async {
    final token = _box.read('token');
    final url = Uri.parse("${AppConstants.baseUrl}/timeline/last-conversation");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // debugPrint("🌐 URL: ${url.toString()}");
      //debugPrint("🔑 Token: $token");
       // debugPrint("📥 Response Status Code: ${response.statusCode}");
       //debugPrint("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final dataList = body['data'] as List<dynamic>;

        final chatList =
            dataList.map((json) => ChatUserModel.fromJson(json)).toList();

       //debugPrint("✅ Chat List: $chatList");

        return chatList;
      } else {
        throw Exception("Failed to fetch last conversation.");
      }
    } catch (e) {
      debugPrint("🛑 Hata: $e");
      rethrow;
    }
  }

/// Mesaj detaylarını getir (Show Conversation)
static Future<List<MessageModel>> fetchConversationMessages(int conversationId) async {
  final token = _box.read('token');
  final currentUserId = _box.read('userId');
  final url = '${AppConstants.baseUrl}/conversation/$conversationId';
  
  debugPrint("Sohbet mesajları getiriliyor (2. deneme): $url");

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  debugPrint("Sohbet Mesajları Yanıt Kodu: ${response.statusCode}");
  // debugPrint("Sohbet Mesajları Yanıt Body: ${response.body}");

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    final List<dynamic> messagesJson = body['data'];

    return messagesJson
        .map((json) => MessageModel.fromJson(json as Map<String, dynamic>, currentUserId: currentUserId))
        .toList();
  } else {
    throw Exception('Mesajlar getirilemedi!');
  }
}

  /// Birebir mesaj listesi çek
  static Future<List<ChatModel>> fetchChatList() async {
    try {
      final token = _box.read('token');
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/conversation'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
      //  debugPrint("✅ Gelen JSON Body:");
      //  debugPrint(jsonEncode(body));

        if (body is Map<String, dynamic> && body.containsKey('data')) {
          final data = body['data'];
          if (data is List) {
            return data.map((json) {
                // debugPrint("🔍 Her chat JSON:");
                  //debugPrint(jsonEncode(json));
              return ChatModel.fromJson(json);
            }).toList();
          } else {
            debugPrint(
                "⚠️ 'data' alanı liste değilmiş. Tip: ${data.runtimeType}");
            return [];
          }
        } else {
          debugPrint("⚠️ 'data' alanı yok veya map değil!");
          return [];
        }
      } else {
        debugPrint(
            "❌ Chat listesi çekilemedi. StatusCode: ${response.statusCode}");
        throw Exception('Chat listesi alınamadı.');
      }
    } catch (e) {
      debugPrint("❌ Chat listesi çekilirken hata: $e");
      rethrow;
    }
  }

  /// Kullanıcı detaylarını getir
  static Future<UserChatDetailModel> fetchUserDetails(int userId) async {
    try {
      debugPrint('🔍 fetchUserDetails - Başladı');
      final token = await _box.read('token');
      final url = '${AppConstants.baseUrl}/api/user/$userId';
      
      debugPrint('  - URL: $url');
      debugPrint('  - UserID: $userId');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('📥 fetchUserDetails - API Yanıtı:');
      debugPrint('  - Status Code: ${response.statusCode}');
      debugPrint('  - Body: ${response.body}');

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
