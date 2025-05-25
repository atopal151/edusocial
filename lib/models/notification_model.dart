class NotificationModel {
  final String id;
  final String userId;
  final String userName;
  final String profileImageUrl;
  final String type;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.profileImageUrl,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.isRead,
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
    );
  }
}
