import 'package:get/get.dart';
import '../models/group_models/grouped_notification_model.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  void fetchNotifications() async {
    isLoading.value = true;

    await Future.delayed(Duration(milliseconds: 500));

    notifications.value = [
       NotificationModel(
    id: "1",
    userId: "u1",
    userName: "esrf.ys",
    profileImageUrl: "https://i.pravatar.cc/150?u=u1",
    type: "follow",
    message: "seni takip etmeye başladı",
    timestamp: DateTime.now().subtract(Duration(days: 1, hours: 1)),
    isRead: false,
  ),
  NotificationModel(
    id: "2",
    userId: "u2",
    userName: "alara.cs",
    profileImageUrl: "https://i.pravatar.cc/150?u=u2",
    type: "like",
    message: "gönderini beğendi",
    timestamp: DateTime.now().subtract(Duration(days: 1, hours: 2)),
    isRead: false,
  ),
  NotificationModel(
    id: "3",
    userId: "group1",
    userName: "Murata hayranlar grubu",
    profileImageUrl: "https://i.pravatar.cc/150?u=group1",
    type: "group_accept",
    message: "katılma davetin kabul edildi.",
    timestamp: DateTime.now().subtract(Duration(days: 1, hours: 3)),
    isRead: false,
  ),

  // SON 7 GÜN
  NotificationModel(
    id: "4",
    userId: "u1",
    userName: "esrf.ys",
    profileImageUrl: "https://i.pravatar.cc/150?u=u1",
    type: "follow",
    message: "seni takip etmeye başladı",
    timestamp: DateTime.now().subtract(Duration(days: 3)),
    isRead: true,
  ),
  NotificationModel(
    id: "5",
    userId: "u2",
    userName: "alara.cs",
    profileImageUrl: "https://i.pravatar.cc/150?u=u2",
    type: "like",
    message: "gönderini beğendi",
    timestamp: DateTime.now().subtract(Duration(days: 4)),
    isRead: true,
  ),
  NotificationModel(
    id: "6",
    userId: "group1",
    userName: "Murata hayranlar grubu",
    profileImageUrl: "https://i.pravatar.cc/150?u=group1",
    type: "group_accept",
    message: "katılma davetin kabul edildi.",
    timestamp: DateTime.now().subtract(Duration(days: 5)),
    isRead: true,
  ),
  NotificationModel(
    id: "7",
    userId: "u2",
    userName: "alara.cs",
    profileImageUrl: "https://i.pravatar.cc/150?u=u2",
    type: "comment",
    message: "paylaştığın gönderiye yorum yaptı.",
    timestamp: DateTime.now().subtract(Duration(days: 6)),
    isRead: true,
  ),
    ];

    isLoading.value = false;
  }
List<GroupedNotifications> groupNotificationsByDate(List<NotificationModel> notifs) {
  final now = DateTime.now();
  List<GroupedNotifications> grouped = [];

  List<NotificationModel> today = [];
  List<NotificationModel> yesterday = [];
  List<NotificationModel> thisWeek = [];

  for (var notif in notifs) {
    final date = notif.timestamp;

    if (isSameDay(date, now)) {
      today.add(notif);
    } else if (isSameDay(date, now.subtract(Duration(days: 1)))) {
      yesterday.add(notif);
    } else if (date.isAfter(now.subtract(Duration(days: 7)))) {
      thisWeek.add(notif);
    }
  }

  if (today.isNotEmpty) {
    grouped.add(GroupedNotifications(label: "Bugün", notifications: today));
  }
  if (yesterday.isNotEmpty) {
    grouped.add(GroupedNotifications(label: "Dün", notifications: yesterday));
  }
  if (thisWeek.isNotEmpty) {
    grouped.add(GroupedNotifications(label: "Son 7 Gün", notifications: thisWeek));
  }

  return grouped;
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

}
