

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
    
    // Tarih formatını düzelt
    String formattedTime = '';
    try {
      final timeString = json['last_message_time'] ?? '';
      if (timeString.isNotEmpty) {
        // ISO 8601 formatındaki tarihi parse et
        final dateTime = DateTime.tryParse(timeString);
        if (dateTime != null) {
          // HH:mm formatında göster
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
          
          if (messageDate == today) {
            // Bugün: sadece saat
            formattedTime = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
          } else if (messageDate == today.subtract(Duration(days: 1))) {
            // Dün: "Dün HH:mm"
            formattedTime = 'Dün ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
          } else {
            // Diğer günler: "DD.MM HH:mm"
            formattedTime = '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
          }
        } else {
          formattedTime = timeString;
        }
      }
    } catch (e) {
      formattedTime = json['last_message_time'] ?? '';
    }
    
    return GroupChatModel(
      groupId: json['group_id'] ?? 0,
      groupName: json['group_name'] ?? '',
      groupImage: json['group_image'] ?? '',
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: formattedTime,
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
