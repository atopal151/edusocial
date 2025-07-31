import 'package:edusocial/models/group_models/grouped_notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/socket_services.dart';
import '../services/onesignal_service.dart';
import '../services/language_service.dart';
import 'dart:async';

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;
  var unreadCount = 0.obs;

  // Socket servisi için
  late SocketService _socketService;
  late OneSignalService _oneSignalService;
  late LanguageService _languageService;
  late StreamSubscription _notificationSubscription;
  late StreamSubscription _commentNotificationSubscription;
  late StreamSubscription _userNotificationSubscription;

  /// Okunmamış bildirim sayısını hesapla ve güncelle
  void _updateUnreadCount() {
    final unreadNotifications = notifications.where((n) => !n.isRead).toList();
    final readNotifications = notifications.where((n) => n.isRead).toList();
    
    unreadCount.value = unreadNotifications.length;
    
    //debugPrint('📊 === BADGE SAYISI HESAPLAMA ===');
    //debugPrint('📊 Toplam bildirim sayısı: ${notifications.length}');
    //debugPrint('📊 Okunmuş bildirim sayısı: ${readNotifications.length}');
    //debugPrint('📊 Okunmamış bildirim sayısı: ${unreadCount.value}');
    
    if (unreadNotifications.isNotEmpty) {
      debugPrint('📊 Okunmamış bildirimler:');
      for (var notif in unreadNotifications) {
        debugPrint('  - ID: ${notif.id} | Type: ${notif.type} | isRead: ${notif.isRead} | Message: ${notif.message}');
      }
    } else {
      debugPrint('📊 Okunmamış bildirim yok');
    }
    
    debugPrint('📊 ================================');
  }

  @override
  void onInit() {
    super.onInit();
    _socketService = Get.find<SocketService>();
    _oneSignalService = Get.find<OneSignalService>();
    _languageService = Get.find<LanguageService>();
    _setupSocketListener();
  }

  @override
  void onClose() {
    _notificationSubscription.cancel();
    _commentNotificationSubscription.cancel();
    _userNotificationSubscription.cancel();
    super.onClose();
  }

  /// Socket event dinleyicisini ayarla
  void _setupSocketListener() {
    _notificationSubscription = _socketService.onNotification.listen((data) {
      debugPrint('🔔 Yeni bildirim geldi (NotificationController): $data');
      // API'den verileri yeniden çek
      isLoading.value = true;
      fetchNotifications();
    });
    
    _commentNotificationSubscription = _socketService.onCommentNotification.listen((data) {
      debugPrint('💬 Yeni yorum bildirimi geldi (NotificationController): $data');
      // API'den verileri yeniden çek
      isLoading.value = true;
      fetchNotifications();
    });
    
    _userNotificationSubscription = _socketService.onUserNotification.listen((data) {
      debugPrint('👤 Yeni user notification geldi (NotificationController): $data');
      // API'den verileri yeniden çek
      isLoading.value = true;
      fetchNotifications();
      
      // OneSignal bildirimi gönder
      _sendOneSignalNotificationFromData(data);
    });
  }

  /// Yeni bildirim geldiğinde listeye ekle
  void _handleNewNotification(dynamic data) {
    try {
      // Socket'ten gelen veriyi NotificationModel'e çevir
      final notification = NotificationModel.fromJson(data);
      
      // Aynı bildirim zaten var mı kontrol et
      final existingIndex = notifications.indexWhere((n) => n.id == notification.id);
      
      if (existingIndex == -1) {
        // Yeni bildirim ise listeye ekle
        notifications.insert(0, notification);
        debugPrint('✅ Yeni bildirim listeye eklendi: ${notification.message}');
      } else {
        // Mevcut bildirimi güncelle
        notifications[existingIndex] = notification;
        debugPrint('🔄 Mevcut bildirim güncellendi: ${notification.message}');
      }
      
      // Okunmamış sayısını güncelle
      _updateUnreadCount();
      
      // Snackbar kaldırıldı - sadece badge güncellenir
      
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
      
      // API'den gelen isRead değerlerini kontrol et
      //debugPrint('📊 === API\'DEN GELEN BİLDİRİMLER ===');
      for (var notif in fetched) {
        //debugPrint('📊 ID: ${notif.id} | Type: ${notif.type} | isRead: ${notif.isRead} | Message: ${notif.message}');
      }
      //debugPrint('📊 ================================');
      
      // Okunmamış bildirimleri ayrıca listele
      final unreadNotifications = fetched.where((n) => !n.isRead).toList();
      if (unreadNotifications.isNotEmpty) {
        //debugPrint('📊 === OKUNMAMIŞ BİLDİRİMLER (API) ===');
        for (var notif in unreadNotifications) {
          //debugPrint('📊 ID: ${notif.id} | Type: ${notif.type} | isRead: ${notif.isRead} | Message: ${notif.message}');
        }
        //debugPrint('📊 ====================================');
      }
      
      // Yeni verileri set et ve UI'ı güncelle
      notifications.value = fetched;
      
      // Okunmamış sayısını güncelle
      _updateUnreadCount();
      
      //  debugPrint('✅ Notification listesi güncellendi: ${fetched.length} bildirim');
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

  /// OneSignal bildirimi gönder
  void _sendOneSignalNotificationFromData(dynamic data) async {
    try {
      debugPrint('📱 NotificationController: OneSignal bildirimi gönderiliyor...');
      debugPrint('📱 Data: $data');
      
      if (data is Map<String, dynamic> && data.containsKey('notification_data')) {
        final notificationData = data['notification_data'] as Map<String, dynamic>?;
        final notificationFullData = notificationData?['notification_full_data'] as Map<String, dynamic>?;
        final notificationType = notificationData?['type']?.toString() ?? '';
        
        if (notificationFullData != null) {
          final userData = notificationFullData['user'] as Map<String, dynamic>?;
          final postData = notificationFullData['post'] as Map<String, dynamic>?;
          
          final userName = userData?['name'] ?? 'Bilinmeyen';
          final userAvatar = userData?['avatar_url'] ?? userData?['profile_image'] ?? '';
          
          String title = '';
          String message = '';
          
          // Bildirim tipine göre mesaj oluştur
          switch (notificationType) {
            case 'post-like':
              final postContent = postData?['content'] ?? _languageService.tr('notifications.messages.likedPost');
              message = '$userName: $postContent';
              title = _languageService.tr('slidingNotifications.newLike');
              break;
            case 'post-comment':
              final postContent = postData?['content'] ?? _languageService.tr('notifications.messages.commentedPost');
              message = '$userName: $postContent';
              title = _languageService.tr('slidingNotifications.newComment');
              break;
            case 'follow-request':
              message = '$userName ${_languageService.tr('notifications.messages.wantsToFollow')}';
              title = _languageService.tr('slidingNotifications.followRequest');
              break;
            default:
              message = '$userName ${_languageService.tr('notifications.messages.sentMessage')}';
              title = _languageService.tr('slidingNotifications.newMessage');
          }
          
          // OneSignal bildirimi gönder
          _oneSignalService.sendCustomMessageNotification(
            senderName: title,
            message: message,
            senderAvatar: userAvatar,
            conversationId: 'notification',
            data: data,
          );
          
          debugPrint('✅ NotificationController: OneSignal bildirimi gönderildi');
        }
      }
    } catch (e) {
      debugPrint('❌ NotificationController: OneSignal bildirimi gönderilemedi: $e');
    }
  }
}
