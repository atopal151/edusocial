import '../notification_model.dart';

class GroupedNotifications {
  final String label; // "Bugün", "Dün" vs
  final List<NotificationModel> notifications;

  GroupedNotifications({
    required this.label,
    required this.notifications,
  });
}
