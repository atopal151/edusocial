import 'sender_model.dart';
import 'conversation_model.dart';
import 'message_media_model.dart';
import 'message_link_model.dart';

class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String message;
  final bool isRead;
  final bool isMe;
  final String createdAt;
  final String updatedAt;
  final SenderModel sender;
  final ConversationModel conversation;
  final List<MessageMediaModel> messageMedia;
  final List<MessageLinkModel> messageLink;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.isRead,
    required this.isMe,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
    required this.conversation,
    required this.messageMedia,
    required this.messageLink,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      conversationId: json['conversation_id'] is int
          ? json['conversation_id']
          : int.tryParse(json['conversation_id'].toString()) ?? 0,
      senderId: json['sender_id'] is int
          ? json['sender_id']
          : int.tryParse(json['sender_id'].toString()) ?? 0,
      message: json['message'] ?? '',
      isRead: json['is_read'] == true ||
          (json['is_read'] is int && json['is_read'] == 1),
      isMe: json['is_me'] == true ||
          (json['is_me'] is int && json['is_me'] == 1),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      sender: json['sender'] != null
          ? SenderModel.fromJson(json['sender'])
          : SenderModel.empty(),
      conversation: json['conversation'] != null
          ? ConversationModel.fromJson(json['conversation'])
          : ConversationModel.empty(),
      messageMedia: (json['message_media'] as List<dynamic>?)
              ?.map((e) => MessageMediaModel.fromJson(e))
              .toList() ??
          [],
      messageLink: (json['message_link'] as List<dynamic>?)
              ?.map((e) => MessageLinkModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
