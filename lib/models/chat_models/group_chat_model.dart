

class GroupChatModel {
  final int groupId;
  String groupName; // final kaldırıldı
  String groupImage; // final kaldırıldı
  String lastMessage;
  String lastMessageTime;
  int unreadCount;
  bool hasUnreadMessages; // Okunmamış mesaj var mı?
  bool isAdmin; // Admin mi?

  GroupChatModel({
    required this.groupId,
    required this.groupName,
    required this.groupImage,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.hasUnreadMessages = false, // Başlangıçta false
    this.isAdmin = false, // Başlangıçta false
  });

  factory GroupChatModel.fromJson(Map<String, dynamic> json) {
    // Önce unread_messages_total_count'u dene, yoksa unread_count'u kullan
    final unreadCount = json['unread_messages_total_count'] ?? json['unread_count'] ?? 0;
    
    return GroupChatModel(
      groupId: json['group_id'] ?? 0,
      groupName: json['group_name'] ?? '',
      groupImage: json['group_image'] ?? '',
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['last_message_time'] ?? '',
      unreadCount: unreadCount,
      isAdmin: json['is_founder'] ?? false, // is_founder field'ını isAdmin olarak kullan
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
