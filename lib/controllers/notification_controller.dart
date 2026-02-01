import 'package:edusocial/models/group_models/grouped_notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'package:get_storage/get_storage.dart';
import '../services/socket_services.dart';
import '../notification/onesignal_service.dart';
import '../services/language_service.dart';
import 'dart:async';
import '../components/print_full_text.dart';

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
    //final readNotifications = notifications.where((n) => n.isRead).toList();
    
    unreadCount.value = unreadNotifications.length;
    
   
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
      
      // Sadece mobile channel'dan gelen bildirimleri işle
      if (data is Map && data.containsKey('channel')) {
        final channel = data['channel']?.toString();
        debugPrint('📱 Channel: $channel');
        
        if (channel != 'mobile') {
          debugPrint('🚫 Web channel bildirimi atlandı, sadece mobile dinleniyor');
          return;
        }
        
        debugPrint('✅ Mobile channel bildirimi işleniyor');
      }
      
      // API'den verileri yeniden çek
      isLoading.value = true;
      fetchNotifications();
    });
    
    _commentNotificationSubscription = _socketService.onCommentNotification.listen((data) {
      debugPrint('💬 Yeni yorum bildirimi geldi (NotificationController): $data');
      
      // Sadece mobile channel'dan gelen bildirimleri işle
      if (data is Map && data.containsKey('channel')) {
        final channel = data['channel']?.toString();
        debugPrint('📱 Channel: $channel');
        
        if (channel != 'mobile') {
          debugPrint('🚫 Web channel bildirimi atlandı, sadece mobile dinleniyor');
          return;
        }
        
        debugPrint('✅ Mobile channel bildirimi işleniyor');
      }
      
      // API'den verileri yeniden çek
      isLoading.value = true;
      fetchNotifications();
    });
    
    _userNotificationSubscription = _socketService.onUserNotification.listen((data) {
      printFullText('👤 Yeni user notification geldi (NotificationController): $data');
      printFullText('👤 Data type: ${data.runtimeType}');
      
      // Sadece mobile channel'dan gelen bildirimleri işle
      if (data is Map && data.containsKey('channel')) {
        final channel = data['channel']?.toString();
        printFullText('📱 Channel: $channel');
        
        if (channel != 'mobile') {
          printFullText('🚫 Web channel bildirimi atlandı, sadece mobile dinleniyor');
          return;
        }
        
        printFullText('✅ Mobile channel bildirimi işleniyor');
      }
      
      if (data is Map) {
        printFullText('👤 === NOTIFICATION CONTROLLER DETAYLI ANALİZ ===');
        printFullText('👤 Data Keys: ${data.keys.toList()}');
        
        // Ana alanları kontrol et
        for (String key in data.keys) {
          printFullText('👤   $key: ${data[key]} (Type: ${data[key].runtimeType})');
        }
        
        // Nested objects'leri detaylı incele
        if (data.containsKey('notification_data') && data['notification_data'] is Map) {
          printFullText('👤 === NOTIFICATION_DATA DETAYLI ===');
          final notificationData = data['notification_data'] as Map;
          for (String key in notificationData.keys) {
            printFullText('👤     $key: ${notificationData[key]} (Type: ${notificationData[key].runtimeType})');
          }
          
          // is_read alanını özel olarak kontrol et
          if (notificationData.containsKey('is_read')) {
            final isRead = notificationData['is_read'];
            printFullText('👤 🔍 is_read değeri: $isRead (Type: ${isRead.runtimeType})');
            
            // Eğer is_read true ise, bu bildirim zaten okunmuş demektir
            if (isRead == true) {
              printFullText('👤 ✅ Socket\'ten gelen bildirim zaten okunmuş (is_read: true)');
            } else {
              printFullText('👤 🔴 Socket\'ten gelen bildirim okunmamış (is_read: false)');
            }
          } else {
            printFullText('👤 ⚠️ notification_data içinde is_read alanı bulunamadı');
          }
        } else {
          printFullText('👤 ⚠️ notification_data alanı bulunamadı veya Map değil');
        }
        
        if (data.containsKey('user') && data['user'] is Map) {
          printFullText('👤 === USER DETAYLI ===');
          final user = data['user'] as Map;
          for (String key in user.keys) {
            printFullText('👤     $key: ${user[key]} (Type: ${user[key].runtimeType})');
          }
        }
        
        printFullText('👤 === ANALİZ TAMAMLANDI ===');
      }
      
      // API'den verileri yeniden çek
      isLoading.value = true;
      fetchNotifications();
      
      // OneSignal bildirimi gönder
      _sendOneSignalNotificationFromData(data);
    });
  }
/*
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
*/


  /// Bildirimleri çek
  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final fetched = await NotificationService.fetchMobileNotifications();
      
      // API'den gelen isRead değerlerini kontrol et
      //debugPrint('📊 === API\'DEN GELEN BİLDİRİMLER ===');
      //for (var notif in fetched) {
        //debugPrint('📊 ID: ${notif.id} | Type: ${notif.type} | isRead: ${notif.isRead} | Message: ${notif.message}');
      //}
      //debugPrint('📊 ================================');
      
      // Okunmamış bildirimleri ayrıca listele
      final unreadNotifications = fetched.where((n) => !n.isRead).toList();
      if (unreadNotifications.isNotEmpty) {
        //debugPrint('📊 === OKUNMAMIŞ BİLDİRİMLER (API) ===');
        //for (var notif in unreadNotifications) {
          //debugPrint('📊 ID: ${notif.id} | Type: ${notif.type} | isRead: ${notif.isRead} | Message: ${notif.message}');
        //}
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
          
          // Self notification guard: skip if sender is current user
          final currentUserId = GetStorage().read('user_id')?.toString();
          final senderId = userData?['id']?.toString();
          if (currentUserId != null && senderId != null && currentUserId == senderId) {
            debugPrint('🚫 NotificationController: self notification skipped (user_id=$currentUserId)');
            return;
          }

          final userName = userData?['name'] ?? 'Bilinmeyen';
          //final userAvatar = userData?['avatar_url'] ?? userData?['profile_image'] ?? '';
          
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
          
          _oneSignalService.sendLocalNotification(
            title,
            message,
            {
              'type': notificationType,
              'notification_data': notificationData,
              ...data,
            },
          );
          
          debugPrint('✅ NotificationController: OneSignal bildirimi gönderildi');
        }
      }
    } catch (e) {
      debugPrint('❌ NotificationController: OneSignal bildirimi gönderilemedi: $e');
    }
  }
}
