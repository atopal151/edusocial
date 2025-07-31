import 'package:flutter/foundation.dart';
import 'package:edusocial/models/chat_models/last_message_model.dart';

class ChatModel {
  final int id;
  final String name;
  final String surname;
  final String username;
  final String avatar;
  final int conversationId;
  final bool isOnline;
  int unreadCount; // 🔥 final değil artık!
  LastMessage? lastMessage;

  ChatModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.username,
    required this.avatar,
    required this.conversationId,
    required this.isOnline,
    this.unreadCount = 0,
    this.lastMessage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    // Backend'den null geliyorsa 0 olarak ayarla
    final unreadCount = json['unread_count'] ?? 0;
    
    debugPrint("📊 ChatModel.fromJson Debug:");
    debugPrint("  - User: ${json['name']} (${json['username']})");
    debugPrint("  - Raw unread_count: ${json['unread_count']}");
    debugPrint("  - Parsed unreadCount: $unreadCount");
    
    return ChatModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? '',
      conversationId: json['conversation_id'] ?? 0,
      isOnline: json['is_online'] ?? false,
      unreadCount: unreadCount,
      lastMessage: json['last_message'] != null
          ? LastMessage.fromJson(json['last_message'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatar': avatar,
      'conversation_id': conversationId,
      'is_online': isOnline,
      'unread_count': unreadCount,
      'last_message': lastMessage?.toJson(),
    };
  }
}
