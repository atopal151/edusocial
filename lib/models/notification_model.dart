class NotificationModel {
  final String id;
  final String userId;
  final String userName;
  final String profileImageUrl;
  final String type;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? groupId;
  final String? eventId;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.profileImageUrl,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.groupId,
    this.eventId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final fullData = json['notification_full_data'] ?? {};
    final user = fullData['user'] ?? {};

    return NotificationModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      userName: user['username'] ?? 'Kullanıcı',
      profileImageUrl: user['avatar_url'] ?? '',
      type: json['type'] ?? 'other',
      message: fullData['text'] ?? '',
      timestamp: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      groupId: fullData['group_id']?.toString(),
      eventId: fullData['event_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'profileImageUrl': profileImageUrl,
      'type': type,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'groupId': groupId,
      'eventId': eventId,
    };
  }
}
