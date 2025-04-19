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
}
