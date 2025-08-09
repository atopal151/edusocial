import 'package:flutter/foundation.dart';

class GroupChatModel {
  final int groupId;
  final String groupName;
  final String groupImage;
  String lastMessage;
  String lastMessageTime;
  int unreadCount;

  GroupChatModel({
    required this.groupId,
    required this.groupName,
    required this.groupImage,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory GroupChatModel.fromJson(Map<String, dynamic> json) {
    // Önce unread_messages_total_count'u dene, yoksa unread_count'u kullan
    final unreadCount = json['unread_messages_total_count'] ?? json['unread_count'] ?? 0;
    
    debugPrint("📊 GroupChatModel.fromJson Debug:");
    debugPrint("  - Group: ${json['group_name']}");
    debugPrint("  - Raw unread_messages_total_count: ${json['unread_messages_total_count']}");
    debugPrint("  - Raw unread_count: ${json['unread_count']}");
    debugPrint("  - Parsed unreadCount: $unreadCount");
    
    return GroupChatModel(
      groupId: json['group_id'] ?? 0,
      groupName: json['group_name'] ?? '',
      groupImage: json['group_image'] ?? '',
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['last_message_time'] ?? '',
      unreadCount: unreadCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'group_name': groupName,
      'group_image': groupImage,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'unread_count': unreadCount,
    };
  }
}
