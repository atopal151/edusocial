import 'notification_model.dart';

class GroupedNotifications {
  final String label;
  final List<NotificationModel> notifications;

  GroupedNotifications({
    required this.label,
    required this.notifications,
  });
}
