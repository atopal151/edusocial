import 'package:edusocial/models/group_models/grouped_notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  /// Bildirimleri çek
  void fetchNotifications() async {
    isLoading.value = true;
    try {
      final fetched = await NotificationService.fetchMobileNotifications();
      notifications.value = fetched;
    } catch (e) {
      debugPrint("❗ Bildirimleri çekerken hata: $e");
    }
    isLoading.value = false;
  }

  /// Bildirimleri tarihe göre gruplar
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
      } else if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
        yesterday.add(notif);
      } else if (date.isAfter(now.subtract(const Duration(days: 7)))) {
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
