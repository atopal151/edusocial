import 'package:edusocial/models/group_models/grouped_notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/socket_services.dart';
import 'dart:async';

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;
  var unreadCount = 0.obs;

  // Socket servisi için
  late SocketService _socketService;
  late StreamSubscription _notificationSubscription;

  /// Okunmamış bildirim sayısını hesapla ve güncelle
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
    debugPrint('📊 Okunmamış bildirim sayısı güncellendi: ${unreadCount.value}');
  }

  @override
  void onInit() {
    super.onInit();
    _socketService = Get.find<SocketService>();
    _setupSocketListener();
  }

  @override
  void onClose() {
    _notificationSubscription.cancel();
    super.onClose();
  }

  /// Socket event dinleyicisini ayarla
  void _setupSocketListener() {
    _notificationSubscription = _socketService.onNotification.listen((data) {
      debugPrint('🔔 Yeni bildirim geldi (NotificationController): $data');
      _handleNewNotification(data);
    });
  }

  /// Yeni bildirim geldiğinde listeye ekle
  void _handleNewNotification(dynamic data) {
    try {
      // Socket'ten gelen veriyi NotificationModel'e çevir
      final notification = NotificationModel.fromJson(data);
      
      // Listeye en başa ekle (en yeni önce olsun)
      notifications.insert(0, notification);
      
      // Okunmamış sayısını güncelle
      _updateUnreadCount();
      
      debugPrint('✅ Yeni bildirim listeye eklendi: ${notification.message}');
      
      // İsteğe bağlı: Kullanıcıya bildirim göster
      Get.snackbar(
        'Yeni Bildirim',
        notification.message,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFFEEF3F8),
        colorText: Color(0xFF414751),
        icon: Icon(Icons.notifications, color: Color(0xFFFF7743)),
      );
      
    } catch (e) {
      debugPrint('❌ Socket bildirim işleme hatası: $e');
    }
  }

  /// Bildirimi okundu olarak işaretle
  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      // NotificationModel immutable olduğu için yeni bir instance oluştur
      final notification = notifications[index];
      final updatedNotification = NotificationModel(
        id: notification.id,
        userId: notification.userId,
        senderUserId: notification.senderUserId,
        userName: notification.userName,
        profileImageUrl: notification.profileImageUrl,
        type: notification.type,
        message: notification.message,
        timestamp: notification.timestamp,
        isRead: true, // Okundu olarak işaretle
        groupId: notification.groupId,
        eventId: notification.eventId,
        groupName: notification.groupName,
        isAccepted: notification.isAccepted,
        isFollowing: notification.isFollowing,
        isFollowingPending: notification.isFollowingPending,
        isRejected: notification.isRejected,
      );
      
      notifications[index] = updatedNotification;
      debugPrint('📖 Bildirim okundu olarak işaretlendi: $notificationId');
      
      // Okunmamış sayısını güncelle
      _updateUnreadCount();
    }
  }

  /// Tüm bildirimleri okundu olarak işaretle
  void markAllAsRead() {
    bool hasChanges = false;
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        // Her bir bildirimi işaretle ama _updateUnreadCount çağırma
        final notification = notifications[i];
        final updatedNotification = NotificationModel(
          id: notification.id,
          userId: notification.userId,
          senderUserId: notification.senderUserId,
          userName: notification.userName,
          profileImageUrl: notification.profileImageUrl,
          type: notification.type,
          message: notification.message,
          timestamp: notification.timestamp,
          isRead: true,
          groupId: notification.groupId,
          eventId: notification.eventId,
          groupName: notification.groupName,
          isAccepted: notification.isAccepted,
          isFollowing: notification.isFollowing,
          isFollowingPending: notification.isFollowingPending,
          isRejected: notification.isRejected,
        );
        notifications[i] = updatedNotification;
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      debugPrint('📚 Tüm bildirimler okundu olarak işaretlendi');
      // Sadece değişiklik varsa güncelle
      _updateUnreadCount();
    }
  }

  /// Bildirimleri çek
  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final fetched = await NotificationService.fetchMobileNotifications();
      //debugPrint('--- APIden gelen notification verileri (toJson) ---');
      //for (var notif in fetched) {
      //debugPrint(notif.toJson().toString());
      //}
      notifications.value = fetched;
      
      // Okunmamış sayısını güncelle
      _updateUnreadCount();
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
      // Önce local güncelleme yap
      final updatedNotifications = notifications.map((notif) {
        if (notif.senderUserId == userId &&
            (notif.type == 'follow-join-request' || notif.type == 'follow-request')) {
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
            isAccepted: decision == 'accept',
            isRejected: decision == 'decline',
            isFollowing: decision == 'accept',
            isFollowingPending: false,
          );
        }
        return notif;
      }).toList();

      // UI'ı hemen güncelle
      notifications.value = updatedNotifications;

      // API'ye istek gönder
      final response = await NotificationService.acceptOrDeclineFollowRequest(
        userId: userId,
        decision: decision,
      );

      // Eğer istek zaten yanıtlanmışsa veya başarılıysa
      if (response['already_responded'] == true || response['status'] == true) {
        // Bildirimleri yenile
        fetchNotifications();
        return;
      }

      // Hata durumunda eski haline geri döndür
      fetchNotifications();
    } catch (e) {
      debugPrint("❗ Takip isteği onaylanamadı: $e");
      // Hata durumunda bildirimleri yenile
      fetchNotifications();
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
      final response = await NotificationService.acceptOrDeclineGroupJoinRequest(
        userId: userId,
        groupId: groupId,
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
            notif.type == 'group-join-request' &&
            notif.groupId == groupId) {
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
            isAccepted: decision == 'accept',
            isRejected: decision == 'decline',
            isFollowing: notif.isFollowing,
            isFollowingPending: notif.isFollowingPending,
          );
        }
        return notif;
      }).toList();

      notifications.value = updatedNotifications;

      // Yeni bildirimleri çek
      fetchNotifications();

      // Başarı mesajı göster
      
    } catch (e) {
      debugPrint("❗ Grup katılma isteği onaylanamadı: $e");
      Get.snackbar(
        "Hata",
        "Grup katılma isteği işlenemedi: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
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
