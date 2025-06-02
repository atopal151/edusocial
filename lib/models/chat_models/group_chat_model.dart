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
    return GroupChatModel(
      groupId: json['group_id'] ?? 0,
      groupName: json['group_name'] ?? '',
      groupImage: json['group_image'] ?? '',
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['last_message_time'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
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
