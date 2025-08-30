import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'package:flutter/material.dart'; // Added for Color

class OneSignalService extends GetxService {
  static const String _appId = "a26f3c4c-771d-4b68-85d6-a33c1ef1766f";
  static const String _apiKey = "os_v2_app_ujxtytdxdvfwrbowum6b54lwn42leac7osveteft3loukqcw4ndd4f2a22mvo6y6raq74vu5lgieu4qbbfk33ja3d3low5wewkkuftq";
  
  final ApiService _apiService = Get.find<ApiService>();
  
  // Bildirim yöneticisi - çoklu bildirim önlemek için
  final Map<String, DateTime> _activeNotifications = {};
  final Duration _notificationCooldown = const Duration(seconds: 10);
  
  // Global bildirim kontrolü - aynı anda sadece bir bildirim göster
  bool _isShowingNotification = false;
  
  @override
  void onInit() {
    super.onInit();
    _initializeOneSignal();
  }

  Future<void> _initializeOneSignal() async {
    try {
      debugPrint('🚀 OneSignal başlatılıyor...');
      
      // OneSignal'i başlat
      OneSignal.initialize(_appId);

      // Bildirim izinlerini iste
      OneSignal.Notifications.requestPermission(true);

      // Bildirim açıldığında ne olacağını ayarla
      OneSignal.Notifications.addClickListener((event) {
        _handleNotificationClick(event);
      });

      // Bildirim alındığında ne olacağını ayarla
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        _handleNotificationReceived(event);
      });

      // Player ID'yi almak için biraz bekle
      await Future.delayed(Duration(seconds: 2));
      
      // Player ID'yi al ve kaydet
      await _getAndSavePlayerId();
      
      debugPrint('✅ OneSignal başarıyla başlatıldı');
    } catch (e) {
      debugPrint('❌ OneSignal başlatılırken hata: $e');
    }
  }

  Future<void> _getAndSavePlayerId() async {
    try {
      debugPrint('🔍 OneSignal Player ID alınıyor...');
      
      // Birkaç kez deneme yap
      String? playerId;
      int attempts = 0;
      const maxAttempts = 5;
      
      while (playerId == null && attempts < maxAttempts) {
        attempts++;
        debugPrint('📱 Player ID deneme $attempts/$maxAttempts...');
        
        // Player ID'yi al
        playerId =  OneSignal.User.pushSubscription.id;
        
        if (playerId == null) {
          debugPrint('⏳ Player ID henüz hazır değil, bekleniyor...');
          await Future.delayed(Duration(seconds: 1));
        }
      }
      
      debugPrint('📱 Player ID: $playerId');
      
      if (playerId != null && playerId.isNotEmpty) {
        // SharedPreferences'a kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('player_id', playerId);
        debugPrint('💾 Player ID kaydedildi');
        
        // API'ye gönder
        await _sendDeviceInfoToServer(playerId);
      } else {
        debugPrint('❌ Player ID alınamadı veya boş');
        // Alternatif olarak SharedPreferences'tan almayı dene
        final prefs = await SharedPreferences.getInstance();
        final savedPlayerId = prefs.getString('player_id');
        if (savedPlayerId != null) {
          debugPrint('💾 Kaydedilmiş Player ID kullanılıyor: $savedPlayerId');
          await _sendDeviceInfoToServer(savedPlayerId);
        }
      }
    } catch (e) {
      debugPrint('❌ OneSignal Player ID alınamadı: $e');
    }
  }

  Future<void> _sendDeviceInfoToServer(String playerId) async {
    try {
                debugPrint('🌐 Cihaz bilgisi sunucuya gönderiliyor...');
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      debugPrint('🔑 Token: ${token?.substring(0, 20)}...');
      
      if (token == null) {
        debugPrint('❌ Token bulunamadı, cihaz bilgisi gönderilemedi');
        return;
      }

      // Platform bilgisini al
      String platform = 'android';
      if (GetPlatform.isIOS) {
        platform = 'ios';
      }
      
      debugPrint('📱 Platform: $platform');

      // Cihaz adını al
      String deviceName = 'Unknown Device';
      try {
        deviceName =  OneSignal.User.pushSubscription.id ?? 'Unknown Device';
      } catch (e) {
        debugPrint('❌ Cihaz adı alınamadı: $e');
      }

      debugPrint('📋 Gönderilecek veri:');
      debugPrint('   - player_id: $playerId');
      debugPrint('   - device_name: $deviceName');
      debugPrint('   - platform: $platform');

      // API'ye gönder
      final response = await _apiService.post(
        '/set-user-device',
        {
          'player_id': playerId,
          'device_name': deviceName,
          'platform': platform,
        },
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('📡 API Response Status: ${response.statusCode}');
      debugPrint('📡 API Response Body: ${response.data}');

      if (response.statusCode == 200) {
        debugPrint('✅ Cihaz bilgisi başarıyla gönderildi');
      } else {
        debugPrint('❌ Cihaz bilgisi gönderilemedi: ${response.statusCode}');
        debugPrint('❌ Hata detayı: ${response.data}');
      }
    } catch (e) {
      debugPrint('❌ Cihaz bilgisi gönderilirken hata: $e');
    }
  }

  void _handleNotificationClick(OSNotificationClickEvent event) {
    // Bildirim tıklandığında yapılacak işlemler
    debugPrint('Bildirim tıklandı: ${event.notification.jsonRepresentation()}');
    
    // Bildirim verilerini kontrol et ve uygun sayfaya yönlendir
    final data = event.notification.additionalData;
    if (data != null) {
      _navigateBasedOnNotification(data);
    }
  }

  void _handleNotificationReceived(OSNotificationWillDisplayEvent event) {
    // Uygulama açıkken bildirim alındığında yapılacak işlemler
    debugPrint('Bildirim alındı: ${event.notification.jsonRepresentation()}');
    
    // Bildirim türüne göre filtreleme yap
    _shouldShowNotification(event.notification).then((shouldShow) {
      if (shouldShow) {
        // Bildirimi göster
        event.notification.display();
      } else {
        // Bildirimi gizle - OneSignal'da preventDefault yok, sadece göstermiyoruz
        debugPrint('Bildirim filtrelendi: ${event.notification.notificationId}');
      }
    });
  }

  // Bildirim türüne göre gösterilip gösterilmeyeceğini kontrol et
  Future<bool> _shouldShowNotification(OSNotification notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = notification.additionalData;
      
      // Önce genel bildirim iznini kontrol et
      final hasPermission = await hasNotificationPermission();
      if (!hasPermission) {
        debugPrint('❌ Bildirim izni yok, bildirim gösterilmeyecek');
        return false;
      }
      
      if (data == null || data['type'] == null) {
        debugPrint('⚠️ Bildirim tipi belirtilmemiş, varsayılan olarak gösteriliyor');
        return true; // Tip belirtilmemişse göster
      }

      final type = data['type'] as String;
      debugPrint('🔍 Bildirim tipi kontrol ediliyor: $type');
      debugPrint('🔍 Bildirim data: $data');
      debugPrint('🔍 Bildirim ayarları kontrol ediliyor...');
      
      bool shouldShow = true;
      
      switch (type) {
        case 'post':
        case 'like':
        case 'comment':
          shouldShow = prefs.getBool('post_notifications') ?? true;
          debugPrint('🔍 Post bildirimleri kontrol edildi: $shouldShow');
          break;
        case 'message':
          shouldShow = prefs.getBool('message_notifications') ?? true;
          debugPrint('🔍 Mesaj bildirimleri kontrol edildi: $shouldShow');
          break;
        case 'group':
          shouldShow = prefs.getBool('message_notifications') ?? true; // Group chat mesajları
          debugPrint('🔍 Grup bildirimleri kontrol edildi: $shouldShow');
          
          // Grup bazlı mute kontrolü ekle
          if (shouldShow) {
            final groupId = data['group_id']?.toString();
            if (groupId != null) {
              final isGroupMuted = prefs.getBool('group_muted_$groupId') ?? false;
              if (isGroupMuted) {
                shouldShow = false;
                debugPrint('🔇 Grup sessize alınmış: $groupId');
              }
            }
          }
          break;
        case 'group_join_request':
        case 'group_join_accepted':
        case 'group_join_declined':
          shouldShow = prefs.getBool('group_notifications') ?? true;
          break;
        case 'event_invitation':
          shouldShow = prefs.getBool('event_notifications') ?? true;
          break;
        case 'follow':
        case 'follow_request':
        case 'follow_accepted':
        case 'follow_declined':
          shouldShow = prefs.getBool('follow_notifications') ?? true;
          break;
        case 'notification':
          // Notification tipindeki alt türleri kontrol et
          final notificationData = data['notification_data'] as Map<String, dynamic>?;
          final notificationType = notificationData?['type']?.toString() ?? '';
          debugPrint('🔍 Notification alt tipi: $notificationType');
          
          switch (notificationType) {
            case 'post-like':
            case 'post-comment':
              shouldShow = prefs.getBool('post_notifications') ?? true;
              debugPrint('🔍 Post bildirimleri (notification) kontrol edildi: $shouldShow');
              break;
            case 'follow-request':
            case 'follow-accepted':
            case 'follow-declined':
              shouldShow = prefs.getBool('follow_notifications') ?? true;
              debugPrint('🔍 Follow bildirimleri (notification) kontrol edildi: $shouldShow');
              break;
            case 'group-join-request':
            case 'group-join-accepted':
            case 'group-join-declined':
              shouldShow = prefs.getBool('group_notifications') ?? true;
              debugPrint('🔍 Group bildirimleri (notification) kontrol edildi: $shouldShow');
              break;
            default:
              shouldShow = prefs.getBool('system_notifications') ?? true;
              debugPrint('🔍 System bildirimleri (notification) kontrol edildi: $shouldShow');
          }
          break;
        default:
          debugPrint('⚠️ Bilinmeyen bildirim tipi: $type, varsayılan olarak gösteriliyor');
          shouldShow = true; // Bilinmeyen tip için göster
      }
      
      if (!shouldShow) {
        debugPrint('🚫 Bildirim filtrelendi: $type');
        if (type == 'notification') {
          final notificationData = data['notification_data'] as Map<String, dynamic>?;
          final notificationType = notificationData?['type']?.toString() ?? '';
          debugPrint('🚫 Alt bildirim tipi: $notificationType');
        }
      } else {
        debugPrint('✅ Bildirim gösterilecek: $type');
        if (type == 'notification') {
          final notificationData = data['notification_data'] as Map<String, dynamic>?;
          final notificationType = notificationData?['type']?.toString() ?? '';
          debugPrint('✅ Alt bildirim tipi: $notificationType');
        }
      }
      
      return shouldShow;
    } catch (e) {
      debugPrint('❌ Bildirim filtreleme hatası: $e');
      return true; // Hata durumunda göster
    }
  }

  void _navigateBasedOnNotification(Map<String, dynamic> data) {
    // Bildirim tipine göre yönlendirme
    final type = data['type'];
    final id = data['id'];
    
    switch (type) {
      case 'post':
        Get.toNamed('/post-detail', arguments: {'post_id': id});
        break;
      case 'message':
        Get.toNamed('/chat-detail', arguments: {'conversation_id': id});
        break;
      case 'group':
        Get.toNamed('/group-detail', arguments: {'group_id': id});
        break;
      case 'event':
        Get.toNamed('/event-detail', arguments: {'event_id': id});
        break;
      case 'user_notification':
        Get.toNamed('/user-notifications');
        break;
      case 'comment':
        Get.toNamed('/post-detail', arguments: {'post_id': id});
        break;
      case 'follow':
        Get.toNamed('/user-profile', arguments: {'user_id': id});
        break;
      case 'like':
        Get.toNamed('/post-detail', arguments: {'post_id': id});
        break;
      case 'post_mention':
        Get.toNamed('/post-detail', arguments: {'post_id': id});
        break;
      case 'comment_mention':
        Get.toNamed('/post-detail', arguments: {'post_id': id});
        break;
      case 'system_notification':
        // Sistem bildirimleri genellikle kullanıcıya özgü olmadığı için ana sayfaya yönlendir
        Get.offAllNamed('/home');
        break;
      default:
        // Varsayılan olarak ana sayfaya git
        Get.offAllNamed('/home');
        break;
    }
  }

  // Player ID'yi manuel olarak almak için
  Future<String?> getPlayerId() async {
    try {
      return OneSignal.User.pushSubscription.id;
    } catch (e) {
      debugPrint('Player ID alınamadı: $e');
      return null;
    }
  }

  // Bildirim izinlerini kontrol et
  Future<bool> hasNotificationPermission() async {
    try {
        return  OneSignal.Notifications.permission;
    } catch (e) {
      debugPrint('Bildirim izni kontrol edilemedi: $e');
      return false;
    }
  }

  // Uygulama kapalıyken sunucudan gelen bildirimler için OneSignal kullan
  Future<void> sendServerNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
    List<String>? playerIds,
  }) async {
    try {
      debugPrint('📱 =======================================');
      debugPrint('📱 Sunucu bildirimi OneSignal ile gönderiliyor...');
      debugPrint('📱 Title: $title');
      debugPrint('📱 Message: $message');
      debugPrint('📱 Type: $type');
      debugPrint('📱 Data: $data');
      
      // Player ID'leri al
      List<String> targetPlayerIds = [];
      
      if (playerIds != null && playerIds.isNotEmpty) {
        // Belirli kullanıcılara gönder
        targetPlayerIds = playerIds;
        debugPrint('📱 Belirli kullanıcılara gönderiliyor: $targetPlayerIds');
      } else {
        // Tüm kullanıcılara gönder
        final currentPlayerId = await getPlayerId();
        if (currentPlayerId != null) {
          targetPlayerIds = [currentPlayerId];
          debugPrint('📱 Mevcut kullanıcıya gönderiliyor: $currentPlayerId');
        } else {
          debugPrint('❌ Player ID bulunamadı');
          return;
        }
      }
      
      // Bildirim verilerini hazırla
      final notificationData = {
        'app_id': _appId,
        'include_player_ids': targetPlayerIds,
        'contents': {'en': message},
        'headings': {'en': title},
        'data': {
          'type': type,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?data,
        },
        'android_channel_id': 'default',
        'priority': 10,
        'android_accent_color': 'FFEF5050',
        'android_led_color': 'FFEF5050',
        'android_sound': 'default',
        'ios_sound': 'default',
      };
      
      debugPrint('📱 OneSignal API\'ye gönderilecek veri: $notificationData');
      
      // OneSignal REST API ile bildirim gönder
      final response = await _apiService.post(
        'https://onesignal.com/api/v1/notifications',
        notificationData,
        headers: {
          'Authorization': 'Basic $_apiKey',
          'Content-Type': 'application/json'
        },
      );
      
      debugPrint('📱 OneSignal API Response: ${response.statusCode}');
      debugPrint('📱 Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        debugPrint('✅ Sunucu bildirimi başarıyla gönderildi');
        
        // Eğer invalid_player_ids hatası varsa
        if (response.data['errors'] != null && 
            response.data['errors']['invalid_player_ids'] != null) {
          debugPrint('⚠️ OneSignal Dashboard konfigürasyonu eksik!');
          debugPrint('🔧 Lütfen OneSignal Dashboard\'da şunları kontrol edin:');
          debugPrint('   1. App Settings → Android Configuration');
          debugPrint('   2. Package Name: com.social.edusocial');
          debugPrint('   3. App ID: $_appId');
          debugPrint('   4. REST API Key: $_apiKey');
          debugPrint('   5. Google Project Number (opsiyonel)');
        }
      } else {
        debugPrint('❌ Sunucu bildirimi gönderilemedi: ${response.statusCode}');
        debugPrint('❌ Hata detayı: ${response.data}');
      }
    } catch (e) {
      debugPrint('❌ Sunucu bildirimi gönderilirken hata: $e');
    }
  }

  // Bildirim izinlerini iste
  Future<void> requestNotificationPermission() async {
    try {
      debugPrint('🔐 Bildirim izni isteniyor...');
      await OneSignal.Notifications.requestPermission(true);
      
      // İzin durumunu kontrol et
      final hasPermission = await hasNotificationPermission();
      debugPrint('🔐 Bildirim izni durumu: $hasPermission');
      
      if (hasPermission) {
        debugPrint('✅ Bildirim izni verildi');
      } else {
        debugPrint('❌ Bildirim izni reddedildi');
      }
    } catch (e) {
      debugPrint('❌ Bildirim izni istenirken hata: $e');
    }
  }

  // Flag'i sıfırla (debug için)
  void resetNotificationFlag() {
    _isShowingNotification = false;
    debugPrint('🔧 Flag sıfırlandı: $_isShowingNotification');
  }

  // Test bildirimi gönder
  Future<void> sendTestNotification() async {
    try {
      debugPrint('🧪 Test bildirimi gönderiliyor...');
      
      final playerId = await getPlayerId();
      if (playerId != null) {
            debugPrint('📱 Player ID: $playerId');
        
        // OneSignal REST API ile test bildirimi gönder
        final response = await _apiService.post(
          'https://onesignal.com/api/v1/notifications',
          {
            'app_id': _appId,
            'include_player_ids': [playerId],
            'contents': {
              'en': 'Test Bildirimi - EduSocial'
            },
            'headings': {
              'en': 'EduSocial Test'
            },
            'data': {
              'type': 'test',
              'message': 'Bu bir test bildirimidir'
            }
          },
          headers: {
            'Authorization': 'Basic $_apiKey',
            'Content-Type': 'application/json'
          },
        );
        
        debugPrint('📡 OneSignal API Response: ${response.statusCode}');
        debugPrint('📡 Response Data: ${response.data}');
        
        if (response.statusCode == 200) {
          debugPrint('✅ Test bildirimi başarıyla gönderildi');
          
          // Eğer invalid_player_ids hatası varsa
          if (response.data['errors'] != null && 
              response.data['errors']['invalid_player_ids'] != null) {
            debugPrint('⚠️ OneSignal Dashboard konfigürasyonu eksik!');
            debugPrint('🔧 Lütfen OneSignal Dashboard\'da şunları kontrol edin:');
            debugPrint('   1. App Settings → Android Configuration');
            debugPrint('   2. Package Name: com.social.edusocial');
            debugPrint('   3. App ID: $_appId');
            debugPrint('   4. REST API Key: $_apiKey');
            debugPrint('   5. Google Project Number (opsiyonel)');
          }
        } else {
          debugPrint('❌ Test bildirimi gönderilemedi: ${response.statusCode}');
        }
      } else {
        debugPrint('❌ Player ID alınamadı');
      }
    } catch (e) {
      debugPrint('❌ Test bildirimi gönderilirken hata: $e');
    }
  }

  // Yerel bildirim gönder (uygulama açıkken)
  Future<void> sendLocalNotification(String title, String message, Map<String, dynamic>? data) async {
    try {
      debugPrint('📱 sendLocalNotification çağrıldı: title=$title, message=$message');
      debugPrint('📱 Data: $data');
      debugPrint('📱 Data type: ${data.runtimeType}');
      debugPrint('📱 Data type field: ${data?['type']}');
      
      // Bildirim iznini kontrol et
      final hasPermission = await hasNotificationPermission();
      if (!hasPermission) {
        debugPrint('❌ Bildirim izni yok, yerel bildirim gösterilmeyecek');
        return;
      }
      
      // Bildirim tipini belirle
      String notificationType = 'general';
      if (data != null && data['type'] != null) {
        notificationType = data['type'] as String;
      }
      
      // Bildirim ayarlarını kontrol et
      final prefs = await SharedPreferences.getInstance();
      bool shouldShow = true;
      
      switch (notificationType) {
        case 'post':
        case 'like':
        case 'comment':
          shouldShow = prefs.getBool('post_notifications') ?? true;
          debugPrint('🔍 sendLocalNotification - Post bildirimleri kontrol edildi: $shouldShow');
          break;
        case 'message':
          shouldShow = prefs.getBool('message_notifications') ?? true;
          debugPrint('🔍 sendLocalNotification - Mesaj bildirimleri kontrol edildi: $shouldShow');
          break;
        case 'group':
          shouldShow = prefs.getBool('message_notifications') ?? true; // Group chat mesajları
          debugPrint('🔍 sendLocalNotification - Grup bildirimleri kontrol edildi: $shouldShow');
          break;
        case 'group_join_request':
        case 'group_join_accepted':
        case 'group_join_declined':
          shouldShow = prefs.getBool('group_notifications') ?? true;
          break;
        case 'event_invitation':
          shouldShow = prefs.getBool('event_notifications') ?? true;
          break;
        case 'follow':
        case 'follow_request':
        case 'follow_accepted':
        case 'follow_declined':
          shouldShow = prefs.getBool('follow_notifications') ?? true;
          break;
        case 'notification':
          // Notification tipindeki alt türleri kontrol et
          final notificationData = data?['notification_data'] as Map<String, dynamic>?;
          final notificationType = notificationData?['type']?.toString() ?? '';
          debugPrint('🔍 sendLocalNotification - Notification alt tipi: $notificationType');
          
          switch (notificationType) {
            case 'post-like':
            case 'post-comment':
              shouldShow = prefs.getBool('post_notifications') ?? true;
              debugPrint('🔍 sendLocalNotification - Post bildirimleri (notification) kontrol edildi: $shouldShow');
              break;
            case 'follow-request':
            case 'follow-accepted':
            case 'follow-declined':
              shouldShow = prefs.getBool('follow_notifications') ?? true;
              debugPrint('🔍 sendLocalNotification - Follow bildirimleri (notification) kontrol edildi: $shouldShow');
              break;
            case 'group-join-request':
            case 'group-join-accepted':
            case 'group-join-declined':
              shouldShow = prefs.getBool('group_notifications') ?? true;
              debugPrint('🔍 sendLocalNotification - Group bildirimleri (notification) kontrol edildi: $shouldShow');
              break;
            default:
              shouldShow = prefs.getBool('system_notifications') ?? true;
              debugPrint('🔍 sendLocalNotification - System bildirimleri (notification) kontrol edildi: $shouldShow');
          }
          break;
        default:
          shouldShow = true; // Genel bildirimler için varsayılan olarak göster
      }
      
      if (!shouldShow) {
        debugPrint('🚫 Yerel bildirim filtrelendi: $notificationType');
        return;
      }
      
      // Çoklu bildirim kontrolü için benzersiz ID oluştur
      final notificationId = _generateNotificationId(title, message, data);
      
      // Çoklu bildirim kontrolü - çok daha sıkı kontrol
      if (_activeNotifications.containsKey(notificationId)) {
        final lastNotificationTime = _activeNotifications[notificationId]!;
        final timeSinceLastNotification = DateTime.now().difference(lastNotificationTime);
        
        if (timeSinceLastNotification < _notificationCooldown) {
          debugPrint('⚠️ Çoklu bildirim önlendi: $notificationId (${timeSinceLastNotification.inMilliseconds}ms)');
          return;
        }
      }
      
      // Aktif bildirimleri temizle (eski olanları)
      _activeNotifications.removeWhere((key, value) {
        return DateTime.now().difference(value) > _notificationCooldown;
      });
      
      // Yeni bildirimi kaydet
      _activeNotifications[notificationId] = DateTime.now();
      
      debugPrint('📱 Bildirim gönderiliyor: $notificationId');
      debugPrint('📱 Aktif bildirim sayısı: ${_activeNotifications.length}');
      
      // Global bildirim kontrolü - aynı anda sadece bir bildirim göster
      if (_isShowingNotification) {
        debugPrint('⚠️ Başka bir bildirim gösteriliyor, bu bildirim atlanıyor');
        debugPrint('🔍 Flag durumu: $_isShowingNotification');
        return;
      }
      
      _isShowingNotification = true;
      debugPrint('🔍 Flag true yapıldı: $_isShowingNotification');
      
      // Eğer notification tipi ise özel tasarım kullan
      if (notificationType == 'notification' && data != null) {
        debugPrint('📱 Özel notification tasarımı kullanılacak');
        await _sendCustomNotificationFromData(data);
        _isShowingNotification = false;
        return;
      }
      
      // Eğer mesaj bildirimi ise özel tasarım kullan
      if ((title == 'Yeni Mesaj' || title == 'message') && data != null) {
        debugPrint('📱 Özel mesaj bildirimi kullanılacak');
        await _sendCustomMessageNotificationFromData(data);
        return;
      }
      
      // Eğer grup mesajı bildirimi ise özel tasarım kullan
      if (data != null && data['type'] == 'group') {
        debugPrint('📱 Özel grup mesajı bildirimi kullanılacak');
        await _sendCustomGroupMessageNotificationFromData(data);
        return;
      }
      
      // Diğer bildirimler için normal tasarım
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        snackStyle: SnackStyle.FLOATING,
        icon: const Icon(Icons.notifications, color: Color(0xFFEF5050)),
      );
      
      debugPrint('✅ Yerel bildirim gösterildi: $title - $message');
      
      // Bildirim gösterildikten sonra flag'i false yap
      _isShowingNotification = false;
      debugPrint('🔍 Flag false yapıldı (normal): $_isShowingNotification');
    } catch (e) {
      debugPrint('❌ Yerel bildirim gösterilemedi: $e');
      // Hata durumunda da flag'i false yap
      _isShowingNotification = false;
      debugPrint('🔍 Flag false yapıldı (hata - normal): $_isShowingNotification');
    }
  }

  // Data'dan özel notification bildirimi gönder (profil resmi ve isim ile)
  Future<void> _sendCustomNotificationFromData(Map<String, dynamic> data) async {
    try {
      debugPrint('📱 Özel notification bildirimi gösteriliyor...');
      
      // Bildirim iznini kontrol et
      final hasPermission = await hasNotificationPermission();
      if (!hasPermission) {
        debugPrint('❌ Bildirim izni yok, notification bildirimi gösterilmeyecek');
        return;
      }
      
      // Notification data'sını al
      final notificationData = data['notification_data'] as Map<String, dynamic>?;
      final notificationFullData = notificationData?['notification_full_data'] as Map<String, dynamic>?;
      final notificationType = notificationData?['type']?.toString() ?? '';
      
      if (notificationFullData == null) {
        debugPrint('❌ Notification full data bulunamadı');
        return;
      }
      
      // Kullanıcı bilgilerini al
      final userData = notificationFullData['user'] as Map<String, dynamic>?;
      final userName = userData?['name'] ?? 'Bilinmeyen';
      final userAvatar = userData?['avatar_url'] ?? userData?['profile_image'] ?? '';
      
      // Bildirim tipine göre mesaj oluştur
      String title = '';
      String message = '';
      
      switch (notificationType) {
        case 'post-like':
          title = 'Yeni Beğeni';
          message = '$userName gönderinizi beğendi';
          break;
        case 'post-comment':
          title = 'Yeni Yorum';
          message = '$userName gönderinize yorum yaptı';
          break;
        case 'follow-request':
          title = 'Takip İsteği';
          message = '$userName sizi takip etmek istiyor';
          break;
        case 'group-join-request':
          title = 'Grup Katılma İsteği';
          message = '$userName grubunuza katılmak istiyor';
          break;
        default:
          title = 'Yeni Bildirim';
          message = '$userName size bildirim gönderdi';
      }
      
      // Çoklu bildirim kontrolü - daha sıkı kontrol
      final notificationId = 'notification_${notificationData?['id'] ?? DateTime.now().millisecondsSinceEpoch}';
      
      if (_activeNotifications.containsKey(notificationId)) {
        final lastNotificationTime = _activeNotifications[notificationId]!;
        final timeSinceLastNotification = DateTime.now().difference(lastNotificationTime);
        
        if (timeSinceLastNotification < _notificationCooldown) {
          debugPrint('⚠️ Çoklu notification önlendi: $notificationId (${timeSinceLastNotification.inMilliseconds}ms)');
          return;
        }
      }
      
      // Aktif bildirimleri temizle
      _activeNotifications.removeWhere((key, value) {
        return DateTime.now().difference(value) > _notificationCooldown;
      });
      
      // Yeni bildirimi kaydet
      _activeNotifications[notificationId] = DateTime.now();
      
      debugPrint('📱 Özel notification gönderiliyor: $notificationId');
      debugPrint('📱 Aktif bildirim sayısı: ${_activeNotifications.length}');
      
      // Global bildirim kontrolü
      if (_isShowingNotification) {
        debugPrint('⚠️ Başka bir bildirim gösteriliyor, bu notification atlanıyor');
        return;
      }
      
      _isShowingNotification = true;
      
      // Beyaz arka planlı, profil resmi ile bildirim
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        snackStyle: SnackStyle.FLOATING,
        icon: userAvatar.isNotEmpty
            ? CircleAvatar(
                backgroundImage: NetworkImage(
                  userAvatar.startsWith('http') 
                      ? userAvatar 
                      : 'https://stageapi.edusocial.pl/storage/$userAvatar',
                ),
                radius: 16,
              )
            : const CircleAvatar(
                radius: 16,
                child: Icon(Icons.person, size: 16),
              ),
      );
      
      debugPrint('✅ Özel notification bildirimi gösterildi');
      debugPrint('📱 Bildirim detayları: title=$title, message=$message, user=$userName, avatar=$userAvatar');
      _isShowingNotification = false;
      debugPrint('🔍 Flag false yapıldı (notification): $_isShowingNotification');
    } catch (e) {
      debugPrint('❌ Özel notification bildirimi gösterilemedi: $e');
      _isShowingNotification = false;
      debugPrint('🔍 Flag false yapıldı (hata - notification): $_isShowingNotification');
    }
  }

  // Data'dan özel grup mesajı bildirimi gönder
  Future<void> _sendCustomGroupMessageNotificationFromData(Map<String, dynamic> data) async {
    try {
      debugPrint('📱 Özel grup mesajı bildirimi gösteriliyor...');
      
      // Bildirim iznini kontrol et
      final hasPermission = await hasNotificationPermission();
      debugPrint('🔍 Bildirim izni durumu: $hasPermission');
      if (!hasPermission) {
        debugPrint('❌ Bildirim izni yok, grup mesajı bildirimi gösterilmeyecek');
        _isShowingNotification = false;
        debugPrint('🔍 Flag false yapıldı (izin yok): $_isShowingNotification');
        return;
      }
      
      // Grup bildirimleri ayarını kontrol et
      final prefs = await SharedPreferences.getInstance();
      final groupNotificationsEnabled = prefs.getBool('group_notifications') ?? true;
      debugPrint('🔍 Grup bildirimleri ayarı: $groupNotificationsEnabled');
      
      if (!groupNotificationsEnabled) {
        debugPrint('🚫 Grup bildirimleri kapalı, bildirim gösterilmeyecek');
        _isShowingNotification = false;
        debugPrint('🔍 Flag false yapıldı (grup bildirimleri kapalı): $_isShowingNotification');
        return;
      }
      
      // Grup bazlı mute kontrolü
      final muteGroupId = data['group_id']?.toString();
      if (muteGroupId != null) {
        final isGroupMuted = prefs.getBool('group_muted_$muteGroupId') ?? false;
        if (isGroupMuted) {
          debugPrint('🔇 Grup sessize alınmış: $muteGroupId, bildirim gösterilmeyecek');
          _isShowingNotification = false;
          debugPrint('🔍 Flag false yapıldı (grup sessize alınmış): $_isShowingNotification');
          return;
        }
      }
      
      // Grup mesajı verilerini al
      final groupName = data['group_name'] ?? 'Grup';
      final senderName = data['sender_name'] ?? 'Bilinmeyen';
      final message = data['message'] ?? '';
      final groupAvatar = data['group_avatar'] ?? '';
      
      debugPrint('👥 Grup mesajı detayları: group=$groupName, sender=$senderName, message=$message');
      
      // Bildirim ID'si oluştur (çoklu bildirim önlemek için)
      final groupId = data['group_id'] ?? '';
      final notificationId = 'group_message_$groupId';
      
      // Çoklu bildirim kontrolü - daha sıkı kontrol
      if (_activeNotifications.containsKey(notificationId)) {
        final lastNotificationTime = _activeNotifications[notificationId]!;
        final timeSinceLastNotification = DateTime.now().difference(lastNotificationTime);
        
        if (timeSinceLastNotification < _notificationCooldown) {
          debugPrint('⚠️ Çoklu grup mesajı bildirimi önlendi: $notificationId (${timeSinceLastNotification.inMilliseconds}ms)');
          return;
        }
      }
      
      // Aktif bildirimleri temizle (eski olanları)
      _activeNotifications.removeWhere((key, value) {
        return DateTime.now().difference(value) > _notificationCooldown;
      });
      
      // Yeni bildirimi kaydet
      _activeNotifications[notificationId] = DateTime.now();
      
      debugPrint('📱 Özel grup mesajı notification gönderiliyor: $notificationId');
      debugPrint('📱 Aktif bildirim sayısı: ${_activeNotifications.length}');
      
      // Özel grup mesajı bildirim widget'ı oluştur
      Get.snackbar(
        groupName, // Başlık olarak grup adı
        '$senderName: $message', // Mesaj içeriği: "Gönderen: Mesaj"
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        borderRadius: 16,
        snackStyle: SnackStyle.FLOATING,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        icon: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              color: Colors.grey.shade100,
            ),
            child: ClipOval(
              child: groupAvatar.isNotEmpty && !groupAvatar.endsWith('/0')
                  ? Image.network(
                      groupAvatar.startsWith('http') 
                          ? groupAvatar 
                          : 'https://stageapi.edusocial.pl/storage/$groupAvatar',
                      fit: BoxFit.cover,
                      width: 35,
                      height: 35,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.group, color: Colors.grey, size: 16),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.group, color: Colors.grey, size: 16),
                    ),
            ),
          ),
        ),
        snackbarStatus: (status) {
          debugPrint('👥 Grup mesajı bildirim durumu: $status');
        },
        // Kapatma butonu
        mainButton: TextButton(
          onPressed: () {
            // Bildirimi kapat
            Get.closeCurrentSnackbar();
          },
          child: const Icon(Icons.close, color: Colors.grey, size: 20),
        ),
      );
      
      debugPrint('✅ Özel grup mesajı bildirimi gösterildi: $groupName - $senderName: $message');
      _isShowingNotification = false;
      debugPrint('🔍 Flag false yapıldı (group): $_isShowingNotification');
    } catch (e) {
      debugPrint('❌ Özel grup mesajı bildirimi gösterilemedi: $e');
      _isShowingNotification = false;
      debugPrint('🔍 Flag false yapıldı (hata - group): $_isShowingNotification');
    }
  }

  // Data'dan özel mesaj bildirimi gönder
  Future<void> _sendCustomMessageNotificationFromData(Map<String, dynamic> data) async {
    try {
      // Bildirim iznini kontrol et
      final hasPermission = await hasNotificationPermission();
      if (!hasPermission) {
        debugPrint('❌ Bildirim izni yok, mesaj bildirimi gösterilmeyecek');
        return;
      }
      
      // Mesaj bildirimleri ayarını kontrol et
      final prefs = await SharedPreferences.getInstance();
      final messageNotificationsEnabled = prefs.getBool('message_notifications') ?? true;
      
      if (!messageNotificationsEnabled) {
        debugPrint('🚫 Mesaj bildirimleri kapalı, bildirim gösterilmeyecek');
        return;
      }
      
      // Mesaj verilerini al
      final message = data['message'] ?? '';
      
      // Sender bilgilerini doğru şekilde al
      String senderName = 'Bilinmeyen';
      String senderAvatar = '';
      
      if (data['sender'] is Map<String, dynamic>) {
        final sender = data['sender'] as Map<String, dynamic>;
        senderName = '${sender['name'] ?? ''} ${sender['surname'] ?? ''}'.trim();
        if (senderName.isEmpty) {
          senderName = sender['username'] ?? 'Bilinmeyen';
        }
        senderAvatar = sender['avatar'] ?? sender['avatar_url'] ?? '';
      } else if (data['sender_name'] != null) {
        senderName = data['sender_name'].toString();
      }
      
      final conversationId = data['conversation_id'];
      
      debugPrint('💬 Mesaj detayları: sender=$senderName, message=$message');
      
      // Kendi mesajım ise bildirim gösterme (TEST için geçici olarak kapatıldı)
      final isMyMessage = data['is_me'] == true;
      if (isMyMessage) {
          debugPrint('📤 Kendi mesajım, bildirim gösterilmeyecek (TEST için geçici olarak kapatıldı)');
        // return; // TEST için geçici olarak kapatıldı
      }
      
      // Bildirim ID'si oluştur (çoklu bildirim önlemek için)
      final notificationId = 'message_$conversationId';
      
      // Çoklu bildirim kontrolü - daha sıkı kontrol
      if (_activeNotifications.containsKey(notificationId)) {
        final lastNotificationTime = _activeNotifications[notificationId]!;
        final timeSinceLastNotification = DateTime.now().difference(lastNotificationTime);
        
        if (timeSinceLastNotification < _notificationCooldown) {
          debugPrint('⚠️ Çoklu bildirim önlendi: $notificationId (${timeSinceLastNotification.inMilliseconds}ms)');
          return;
        }
      }
      
      // Aktif bildirimleri temizle (eski olanları)
      _activeNotifications.removeWhere((key, value) {
        return DateTime.now().difference(value) > _notificationCooldown;
      });
      
      // Yeni bildirimi kaydet
      _activeNotifications[notificationId] = DateTime.now();
      
      debugPrint('📱 Özel mesaj notification gönderiliyor: $notificationId');
      debugPrint('📱 Aktif bildirim sayısı: ${_activeNotifications.length}');
      
      // Özel bildirim widget'ı oluştur
      Get.snackbar(
        senderName, // Başlık olarak kullanıcı adı
        message, // Mesaj içeriği
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        borderRadius: 16,
        snackStyle: SnackStyle.FLOATING,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                icon: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              color: Colors.grey.shade100,
            ),
            child: ClipOval(
              child: senderAvatar.isNotEmpty && !senderAvatar.endsWith('/0')
                  ? Image.network(
                      senderAvatar.startsWith('http') 
                          ? senderAvatar 
                          : 'https://stageapi.edusocial.pl/storage/$senderAvatar',
                      fit: BoxFit.cover,
                      width: 35,
                      height: 35,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.person, color: Colors.grey, size: 16),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, color: Colors.grey, size: 16),
                    ),
            ),
          ),
        ),
        snackbarStatus: (status) {
          debugPrint('💬 Bildirim durumu: $status');
        },
        // Kapatma butonu
        mainButton: TextButton(
          onPressed: () {
            // Bildirimi kapat
            Get.closeCurrentSnackbar();
          },
          child: const Icon(Icons.close, color: Colors.grey, size: 20),
        ),
      );
      
      debugPrint('✅ Özel mesaj bildirimi gösterildi: $senderName - $message');
      _isShowingNotification = false;
      debugPrint('🔍 Flag false yapıldı (message): $_isShowingNotification');
    } catch (e) {
      debugPrint('❌ Özel mesaj bildirimi gösterilemedi: $e');
      _isShowingNotification = false;
      debugPrint('🔍 Flag false yapıldı (hata - message): $_isShowingNotification');
    }
  }

  // Özel mesaj bildirimi gönder (profil resmi ve kullanıcı adı ile) - İKİNCİ METOD
  Future<void> sendCustomMessageNotification({
    required String senderName,
    required String message,
    required String senderAvatar,
    required dynamic conversationId,
    required Map<String, dynamic> data,
  }) async {
    try {
      debugPrint('💬 Özel mesaj bildirimi gösteriliyor...');
      
      // Bildirim iznini kontrol et
      final hasPermission = await hasNotificationPermission();
      if (!hasPermission) {
        debugPrint('❌ Bildirim izni yok, mesaj bildirimi gösterilmeyecek');
        return;
      }
      
      // Mesaj bildirimleri ayarını kontrol et
      final prefs = await SharedPreferences.getInstance();
      final messageNotificationsEnabled = prefs.getBool('message_notifications') ?? true;
      
      if (!messageNotificationsEnabled) {
        debugPrint('🚫 Mesaj bildirimleri kapalı, bildirim gösterilmeyecek');
        return;
      }
      
      // Bildirim ID'si oluştur (çoklu bildirim önlemek için)
      final notificationId = 'message_$conversationId';
      
      // Çoklu bildirim kontrolü - daha sıkı kontrol
      if (_activeNotifications.containsKey(notificationId)) {
        final lastNotificationTime = _activeNotifications[notificationId]!;
        final timeSinceLastNotification = DateTime.now().difference(lastNotificationTime);
        
        if (timeSinceLastNotification < _notificationCooldown) {
          debugPrint('⚠️ Çoklu bildirim önlendi: $notificationId (${timeSinceLastNotification.inMilliseconds}ms)');
          return;
        }
      }
      
      // Aktif bildirimleri temizle (eski olanları)
      _activeNotifications.removeWhere((key, value) {
        return DateTime.now().difference(value) > _notificationCooldown;
      });
      
      // Yeni bildirimi kaydet
      _activeNotifications[notificationId] = DateTime.now();
      
      debugPrint('📱 Özel mesaj notification gönderiliyor: $notificationId');
      debugPrint('📱 Aktif bildirim sayısı: ${_activeNotifications.length}');
      
      // Eski tasarımı kullan (kırmızı arka plan)
      Get.snackbar(
        senderName,
        message,
        snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
        colorText: Colors.black87,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        snackStyle: SnackStyle.FLOATING,
         icon: senderAvatar.isNotEmpty
            ? CircleAvatar(
                backgroundImage: NetworkImage(
                  senderAvatar.startsWith('http') 
                      ? senderAvatar 
                      : 'https://stageapi.edusocial.pl/storage/$senderAvatar',
                ),
                radius: 16,
              )
            : const CircleAvatar(
                radius: 16,
                child: Icon(Icons.person, size: 16),
              ),
      );
      
      debugPrint('✅ Local notification gönderildi');
      debugPrint('📱 Bildirim detayları: title=$senderName, message=$message, avatar=$senderAvatar');
      _isShowingNotification = false;
      debugPrint('🔍 Flag false yapıldı (local message): $_isShowingNotification');
    } catch (e) {
      debugPrint('❌ OneSignal local notification gönderilemedi: $e');
      _isShowingNotification = false;
      debugPrint('🔍 Flag false yapıldı (hata - local message): $_isShowingNotification');
    }
  }

  // Benzersiz bildirim ID'si oluştur
  String _generateNotificationId(String title, String message, Map<String, dynamic>? data) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final type = data?['type']?.toString() ?? 'general';
    final notificationData = data?['notification_data'] as Map<String, dynamic>?;
    final notificationType = notificationData?['type']?.toString() ?? '';
    final notificationId = notificationData?['id']?.toString() ?? '';
    
    // Daha benzersiz ID oluştur
    final id = '${type}_${notificationType}_${notificationId}_${title.hashCode}_${message.hashCode}_$timestamp';
    debugPrint('🔑 Bildirim ID oluşturuldu: $id');
    return id;
  }

  // Local test notification (OneSignal Dashboard konfigürasyonu olmadan da çalışır)
  Future<void> sendLocalTestNotification() async {
    try {
      debugPrint('🧪 Local test bildirimi gönderiliyor...');
      
      Get.snackbar(
        'Test Bildirimi',
        'Bu bir local test bildirimidir',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        snackStyle: SnackStyle.FLOATING,
        icon: const Icon(Icons.notifications, color: Colors.white),
      );
      
      debugPrint('✅ Local test bildirimi gösterildi');
    } catch (e) {
      debugPrint('❌ Local test bildirimi gösterilemedi: $e');
    }
  }

  // OneSignal Dashboard konfigürasyonu kontrol et
  Future<void> checkOneSignalConfiguration() async {
    try {
      debugPrint('🔧 OneSignal konfigürasyonu kontrol ediliyor...');
      
      final playerId = await getPlayerId();
      if (playerId != null) {
        debugPrint('✅ Player ID mevcut: $playerId');
        
        // Test bildirimi gönder ve sonucu kontrol et
        final response = await _apiService.post(
          'https://onesignal.com/api/v1/notifications',
          {
            'app_id': _appId,
            'include_player_ids': [playerId],
            'contents': {'en': 'Config Test'},
            'headings': {'en': 'Config Test'},
          },
          headers: {
            'Authorization': 'Basic $_apiKey',
            'Content-Type': 'application/json'
          },
        );
        
        if (response.statusCode == 200) {
          if (response.data['errors'] != null && 
              response.data['errors']['invalid_player_ids'] != null) {
                debugPrint('❌ OneSignal Dashboard konfigürasyonu eksik!');
            debugPrint('📋 Gerekli adımlar:');
            debugPrint('   1. OneSignal Dashboard → App Settings → Android Configuration');
            debugPrint('   2. Package Name: com.social.edusocial');
            debugPrint('   3. App ID: $_appId');
            debugPrint('   4. REST API Key: $_apiKey');
            debugPrint('   5. Google Project Number (opsiyonel)');
          } else {
            debugPrint('✅ OneSignal konfigürasyonu doğru');
          }
        }
      } else {
        debugPrint('❌ Player ID bulunamadı');
      }
    } catch (e) {
      debugPrint('❌ Konfigürasyon kontrolü hatası: $e');
    }
  }

  // Bildirim ayarlarını güncelle
  Future<void> updateNotificationSettings({
    required bool postNotifications,
    required bool messageNotifications,
    required bool groupNotifications,
    required bool eventNotifications,
    required bool followNotifications,
    required bool systemNotifications,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('post_notifications', postNotifications);
    await prefs.setBool('message_notifications', messageNotifications);
    await prefs.setBool('group_notifications', groupNotifications);
    await prefs.setBool('event_notifications', eventNotifications);
    await prefs.setBool('follow_notifications', followNotifications);
    await prefs.setBool('system_notifications', systemNotifications);
  }

  // Bildirim ayarlarını al
  Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'post_notifications': prefs.getBool('post_notifications') ?? true,
      'message_notifications': prefs.getBool('message_notifications') ?? true,
      'group_notifications': prefs.getBool('group_notifications') ?? true,
      'event_notifications': prefs.getBool('event_notifications') ?? true,
      'follow_notifications': prefs.getBool('follow_notifications') ?? true,
      'system_notifications': prefs.getBool('system_notifications') ?? true,
    };
  }

  // Grup bazlı mute fonksiyonları
  Future<void> muteGroup(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('group_muted_$groupId', true);
    debugPrint('🔇 Grup sessize alındı: $groupId');
  }

  Future<void> unmuteGroup(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('group_muted_$groupId', false);
    debugPrint('🔊 Grup sesi açıldı: $groupId');
  }

  Future<bool> isGroupMuted(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('group_muted_$groupId') ?? false;
  }

  // Tüm sessize alınmış grupları al
  Future<List<String>> getMutedGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final mutedGroups = <String>[];
    
    for (final key in keys) {
      if (key.startsWith('group_muted_') && prefs.getBool(key) == true) {
        final groupId = key.replaceFirst('group_muted_', '');
        mutedGroups.add(groupId);
      }
    }
    
    return mutedGroups;
  }

  // Tüm grup mute ayarlarını temizle
  Future<void> clearAllGroupMutes() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith('group_muted_')) {
        await prefs.remove(key);
      }
    }
    
    debugPrint('🗑️ Tüm grup mute ayarları temizlendi');
  }

  // OneSignal'ın kendi servisi ile test notification (Firebase gerektirmez)
  Future<void> sendOneSignalTestNotification() async {
    String? playerId;
    
    try {
      debugPrint('🧪 OneSignal test bildirimi gönderiliyor...');
      
      playerId = await getPlayerId();
      if (playerId != null) {
        debugPrint('📱 Player ID: $playerId');
        
        // OneSignal REST API ile test - basit format
        final response = await _apiService.post(
          'https://onesignal.com/api/v1/notifications',
          {
            'app_id': _appId,
            'include_player_ids': [playerId],
            'contents': {
              'en': 'Test Bildirimi - EduSocial'
            },
            'headings': {
              'en': 'EduSocial Test'
            },
            'data': {
              'type': 'test',
              'message': 'Bu bir test bildirimidir'
            }
          },
          headers: {
            'Authorization': 'Basic $_apiKey',
            'Content-Type': 'application/json'
          },
        );
        
        debugPrint('📡 OneSignal API Response: ${response.statusCode}');
        debugPrint('📡 Response Data: ${response.data}');
        
        if (response.statusCode == 200) {
          debugPrint('✅ OneSignal test bildirimi başarıyla gönderildi');
          if (response.data['id'] != null) {
            debugPrint('📋 Notification ID: ${response.data['id']}');
          }
        } else {
          debugPrint('❌ Test bildirimi gönderilemedi: ${response.statusCode}');
          debugPrint('❌ Hata detayı: ${response.data}');
        }
      } else {
        debugPrint('❌ Player ID alınamadı');
      }
    } catch (e) {
      debugPrint('❌ OneSignal test bildirimi gönderilirken hata: $e');
      
      // Hata detaylarını göster
      if (e.toString().contains('400')) {
          debugPrint('🔧 400 hatası - Request formatı kontrol ediliyor...');
        debugPrint('📋 Kullanılan parametreler:');
        debugPrint('   - App ID: $_appId');
        debugPrint('   - Player ID: $playerId');
        debugPrint('   - API Key: ${_apiKey.substring(0, 20)}...');
      }
    }
  }

  // Basit test notification (sadece console'da bilgi gösterir)
  Future<void> sendSimpleTestNotification() async {
    try {
      debugPrint('🧪 Basit test bildirimi gönderiliyor...');
      
      final playerId = await getPlayerId();
      if (playerId != null) {
        debugPrint('📱 Player ID: $playerId');
        debugPrint('🔧 OneSignal Konfigürasyonu:');
        debugPrint('   - App ID: $_appId');
        debugPrint('   - API Key: ${_apiKey.substring(0, 20)}...');
        debugPrint('   - Package Name: com.social.edusocial');
        
        // Test için snackbar göster
        Get.snackbar(
          'OneSignal Test',
          'Player ID: ${playerId.substring(0, 8)}...',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF2196F3),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.info, color: Colors.white),
        );
        
        debugPrint('✅ Test bilgileri gösterildi');
        debugPrint('📋 OneSignal Dashboard\'da şunları kontrol edin:');
        debugPrint('   1. App Settings → Android Configuration');
        debugPrint('   2. Package Name: com.social.edusocial');
        debugPrint('   3. App ID: $_appId');
        debugPrint('   4. REST API Key: $_apiKey');
      } else {
        debugPrint('❌ Player ID alınamadı');
      }
    } catch (e) {
      debugPrint('❌ Basit test bildirimi hatası: $e');
    }
  }

  // Platform tespiti ile test notification
  Future<void> sendPlatformAwareTestNotification() async {
    try {
      debugPrint('🧪 Platform-aware test bildirimi gönderiliyor...');
      
      final playerId = await getPlayerId();
      if (playerId != null) {
        debugPrint('📱 Player ID: $playerId');
        
        // Platform tespiti
        String platform = 'android';
        String platformName = 'Android';
        if (GetPlatform.isIOS) {
          platform = 'ios';
          platformName = 'iOS';
        }
        
        debugPrint('🔧 Platform: $platformName');
        debugPrint('🔧 OneSignal Konfigürasyonu:');
        debugPrint('   - App ID: $_appId');
        debugPrint('   - API Key: ${_apiKey.substring(0, 20)}...');
          debugPrint('   - Package/Bundle ID: com.social.edusocial');
        debugPrint('   - Platform: $platformName');
        
        // OneSignal REST API ile test
        final response = await _apiService.post(
          'https://onesignal.com/api/v1/notifications',
          {
            'app_id': _appId,
            'include_player_ids': [playerId],
            'contents': {
              'en': 'Test Bildirimi - $platformName'
            },
            'headings': {
              'en': 'EduSocial $platformName Test'
            },
            'data': {
              'type': 'test',
              'message': 'Bu bir $platformName test bildirimidir'
            }
          },
          headers: {
            'Authorization': 'Basic $_apiKey',
            'Content-Type': 'application/json'
          },
        );
        
        debugPrint('📡 OneSignal API Response: ${response.statusCode}');
        debugPrint('📡 Response Data: ${response.data}');
        
        if (response.statusCode == 200) {
          if (response.data['errors'] != null && 
              response.data['errors']['invalid_player_ids'] != null) {
            debugPrint('❌ OneSignal Dashboard konfigürasyonu eksik!');
            debugPrint('📋 $platformName için gerekli adımlar:');
            debugPrint('   2. Package/Bundle ID: com.social.edusocial');
            debugPrint('   3. App ID: $_appId');
            debugPrint('   4. REST API Key: $_apiKey');
            if (platform == 'ios') {
              debugPrint('   5. APNs Certificate (opsiyonel)');
            } else {
              debugPrint('   5. Google Project Number (opsiyonel)');
            }
          } else {
            debugPrint('✅ OneSignal test bildirimi başarıyla gönderildi');
            if (response.data['id'] != null) {
              debugPrint('📋 Notification ID: ${response.data['id']}');
            }
          }
        } else {
          debugPrint('❌ Test bildirimi gönderilemedi: ${response.statusCode}');
        }
      } else {
          debugPrint('❌ Player ID alınamadı');
      }
    } catch (e) {
      debugPrint('❌ Platform-aware test bildirimi hatası: $e');
    }
  }
} 