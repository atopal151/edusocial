
import 'package:edusocial/models/chat_models/last_message_model.dart';

class ChatModel {
  final int id;
  final String name;
  final String surname;
  final String username;
  final String avatar;
  final int conversationId;
  final bool isOnline;
  LastMessage? lastMessage;
  bool hasUnreadMessages; // Okunmamış mesaj var mı?
  final bool? isVerified; // Hesap doğrulama durumu

  ChatModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.username,
    required this.avatar,
    required this.conversationId,
    required this.isOnline,
    this.lastMessage,
    this.hasUnreadMessages = false,
    this.isVerified,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? '',
      conversationId: json['conversation_id'] ?? 0,
      isOnline: json['is_online'] ?? false,
      lastMessage: json['last_message'] != null
          ? LastMessage.fromJson(json['last_message'])
          : null,
      hasUnreadMessages: false, // Başlangıçta false
      isVerified: json['is_verified'],
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
      'last_message': lastMessage?.toJson(),
      'has_unread_messages': hasUnreadMessages,
      'is_verified': isVerified,
    };
  }
}
