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
      //debugPrint('--- APIden gelen notification verileri (toJson) ---');
      //for (var notif in fetched) {
      //debugPrint(notif.toJson().toString());
      //}
      notifications.value = fetched;
    } catch (e) {
      debugPrint("❗ Bildirimleri çekerken hata: $e");
    }
    isLoading.value = false;
  }

  /// Bildirimleri tarihe göre gruplar
  List<GroupedNotifications> groupNotificationsByDate(
      List<NotificationModel> notifs) {
    final now = DateTime.now();
    List<GroupedNotifications> grouped = [];

    List<NotificationModel> today = [];
    List<NotificationModel> yesterday = [];
    List<NotificationModel> thisWeek = [];
    List<NotificationModel> older = [];

    for (var notif in notifs) {
      final date = notif.timestamp;

      if (isSameDay(date, now)) {
        today.add(notif);
      } else if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
        yesterday.add(notif);
      } else if (date.isAfter(now.subtract(const Duration(days: 7)))) {
        thisWeek.add(notif);
      } else {
        older.add(notif);
      }
    }

    if (today.isNotEmpty) {
      grouped.add(GroupedNotifications(label: "Bugün", notifications: today));
    }
    if (yesterday.isNotEmpty) {
      grouped.add(GroupedNotifications(label: "Dün", notifications: yesterday));
    }
    if (thisWeek.isNotEmpty) {
      grouped.add(
          GroupedNotifications(label: "Son 7 Gün", notifications: thisWeek));
    }
    if (older.isNotEmpty) {
      grouped
          .add(GroupedNotifications(label: "Daha Önce", notifications: older));
    }

    return grouped;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Takip isteğini kabul veya reddet
  Future<void> handleFollowRequest(String userId, String decision) async {
    try {
      final response = await NotificationService.acceptOrDeclineFollowRequest(
        userId: userId,
        decision: decision,
      );

      // Eğer istek zaten yanıtlanmışsa
      if (response['already_responded'] == true) {
        // Bildirimleri yenile
        fetchNotifications();
        return;
      }

      // Bildirimleri güncelle
      final updatedNotifications = notifications.map((notif) {
        if (notif.senderUserId == userId &&
            notif.type == 'follow-join-request') {
          return NotificationModel(
            id: notif.id,
            userId: notif.userId,
            senderUserId: notif.senderUserId,
            userName: notif.userName,
            profileImageUrl: notif.profileImageUrl,
            type: notif.type,
            message: notif.message,
            timestamp: notif.timestamp,
            isRead: notif.isRead,
            groupId: notif.groupId,
            eventId: notif.eventId,
            groupName: notif.groupName,
            isAccepted: true,
            isFollowing: decision == 'accept',
            isFollowingPending: false,
          );
        }
        return notif;
      }).toList();

      notifications.value = updatedNotifications;

      // Yeni bildirimleri çek
      fetchNotifications();
    } catch (e) {
      debugPrint("❗ Takip isteği onaylanamadı: $e");
      rethrow;
    }
  }

  /// Kullanıcıyı takip et
  Future<void> followUser(String userId) async {
    try {
      await NotificationService.followUser(userId: userId);

      // Bildirimleri yenile
      fetchNotifications();
    } catch (e) {
      debugPrint("❗ Takip işlemi başarısız: $e");
      Get.snackbar(
        "Hata",
        "Takip işlemi başarısız: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }

  /// Kullanıcıyı takipten çıkar
  Future<void> unfollowUser(String userId) async {
    try {
      await NotificationService.unfollowUser(userId: userId);

    

      // Bildirimleri yenile
      fetchNotifications();
    } catch (e) {
      debugPrint("❗ Takipten çıkarma işlemi başarısız: $e");
 
    }
  }

  /// Grup katılma isteğini kabul veya reddet
  Future<void> handleGroupJoinRequest(
      String userId, String groupId, String decision) async {
    try {
      await NotificationService.acceptOrDeclineGroupJoinRequest(
        userId: userId,
        groupId: groupId,
        decision: decision,
      );
      fetchNotifications();
    } catch (e) {
      debugPrint("❗ Grup katılma isteği onaylanamadı: $e");
    }
  }

  /// Etkinlik oluşturma isteğini kabul veya reddet
  Future<void> handleEventCreateRequest(
      String userId, String groupId, String eventId, String decision) async {
    try {
      await NotificationService.acceptOrDeclineEventCreateRequest(
        userId: userId,
        groupId: groupId,
        eventId: eventId,
        decision: decision,
      );
      fetchNotifications();
    } catch (e) {
      debugPrint("❗ Etkinlik oluşturma isteği onaylanamadı: $e");
    }
  }
}
