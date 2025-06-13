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

class ChatServices {
  static final _box = GetStorage();

  static Future<void> sendMessage(
    int receiverId,
    String message, {
    List<File>? mediaFiles,
    List<String>? links,
  }) async {
    final token = _box.read('token');
    final url = Uri.parse('${AppConstants.baseUrl}/conversation');

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    // Text alanları ekle
    request.fields['receiver_id'] = receiverId.toString();
    request.fields['message'] = message;

    // Linkleri ekle
    if (links != null && links.isNotEmpty) {
      for (var link in links) {
        request.fields['links[]'] = link;
      }
    }

    // Medya dosyalarını ekle
    if (mediaFiles != null && mediaFiles.isNotEmpty) {
      for (var file in mediaFiles) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'media[]', // backend burada 'media' veya 'media[]' mi bekliyor kontrol et
            file.path,
            contentType: MediaType('image', 'jpeg'), // veya dosya tipine göre
          ),
        );
      }
    }

    var streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    //debugPrint("✅ Send Message Response: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("✅ Mesaj başarıyla gönderildi!");
    } else {
      throw Exception("❌ Mesaj gönderilemedi: ${response.statusCode}");
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
static Future<List<MessageModel>> fetchConversationMessages(int chatId) async {
  final token = _box.read('token');
  final response = await http.get(
    Uri.parse('${AppConstants.baseUrl}/conversation/$chatId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  debugPrint('Gönderilen chatId: $chatId');

  // JSON pretty-print
  try {
    final decodedJson = jsonDecode(response.body);
    final prettyJson = const JsonEncoder.withIndent('  ').convert(decodedJson);
    debugPrint("✅ Pretty JSON (Show Conversation):\n$prettyJson", wrapWidth: 1024);
  } catch (e) {
    debugPrint("🛑 JSON parse error: $e");
  }

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    final List<dynamic> messagesJson = body['data'];

    return messagesJson
        .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
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
}
