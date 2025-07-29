import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'package:flutter/material.dart'; // Added for Color

class OneSignalService extends GetxService {
  static const String _appId = "a26f3c4c-771d-4b68-85d6-a33c1ef1766f";
  static const String _apiKey = "os_v2_app_ujxtytdxdvfwrbowum6b54lwn42leac7osveteft3loukqcw4ndd4f2a22mvo6y6raq74vu5lgieu4qbbfk33ja3d3low5wewkkuftq";
  
  final ApiService _apiService = Get.find<ApiService>();
  
  @override
  void onInit() {
    super.onInit();
    _initializeOneSignal();
  }

  Future<void> _initializeOneSignal() async {
    try {
      print('🚀 OneSignal başlatılıyor...');
      
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
      
      print('✅ OneSignal başarıyla başlatıldı');
    } catch (e) {
      print('❌ OneSignal başlatılırken hata: $e');
    }
  }

  Future<void> _getAndSavePlayerId() async {
    try {
      print('🔍 OneSignal Player ID alınıyor...');
      
      // Birkaç kez deneme yap
      String? playerId;
      int attempts = 0;
      const maxAttempts = 5;
      
      while (playerId == null && attempts < maxAttempts) {
        attempts++;
        print('📱 Player ID deneme $attempts/$maxAttempts...');
        
        // Player ID'yi al
        playerId = await OneSignal.User.pushSubscription.id;
        
        if (playerId == null) {
          print('⏳ Player ID henüz hazır değil, bekleniyor...');
          await Future.delayed(Duration(seconds: 1));
        }
      }
      
      print('📱 Player ID: $playerId');
      
      if (playerId != null && playerId.isNotEmpty) {
        // SharedPreferences'a kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('player_id', playerId);
        print('💾 Player ID kaydedildi');
        
        // API'ye gönder
        await _sendDeviceInfoToServer(playerId);
      } else {
        print('❌ Player ID alınamadı veya boş');
        // Alternatif olarak SharedPreferences'tan almayı dene
        final prefs = await SharedPreferences.getInstance();
        final savedPlayerId = prefs.getString('player_id');
        if (savedPlayerId != null) {
          print('💾 Kaydedilmiş Player ID kullanılıyor: $savedPlayerId');
          await _sendDeviceInfoToServer(savedPlayerId);
        }
      }
    } catch (e) {
      print('❌ OneSignal Player ID alınamadı: $e');
    }
  }

  Future<void> _sendDeviceInfoToServer(String playerId) async {
    try {
      print('🌐 Cihaz bilgisi sunucuya gönderiliyor...');
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      print('🔑 Token: ${token?.substring(0, 20)}...');
      
      if (token == null) {
        print('❌ Token bulunamadı, cihaz bilgisi gönderilemedi');
        return;
      }

      // Platform bilgisini al
      String platform = 'android';
      if (GetPlatform.isIOS) {
        platform = 'ios';
      }
      
      print('📱 Platform: $platform');

      // Cihaz adını al
      String deviceName = 'Unknown Device';
      try {
        deviceName = await OneSignal.User.pushSubscription.id ?? 'Unknown Device';
      } catch (e) {
        print('❌ Cihaz adı alınamadı: $e');
      }

      print('📋 Gönderilecek veri:');
      print('   - player_id: $playerId');
      print('   - device_name: $deviceName');
      print('   - platform: $platform');

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

      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ Cihaz bilgisi başarıyla gönderildi');
      } else {
        print('❌ Cihaz bilgisi gönderilemedi: ${response.statusCode}');
        print('❌ Hata detayı: ${response.data}');
      }
    } catch (e) {
      print('❌ Cihaz bilgisi gönderilirken hata: $e');
    }
  }

  void _handleNotificationClick(OSNotificationClickEvent event) {
    // Bildirim tıklandığında yapılacak işlemler
    print('Bildirim tıklandı: ${event.notification.jsonRepresentation()}');
    
    // Bildirim verilerini kontrol et ve uygun sayfaya yönlendir
    final data = event.notification.additionalData;
    if (data != null) {
      _navigateBasedOnNotification(data);
    }
  }

  void _handleNotificationReceived(OSNotificationWillDisplayEvent event) {
    // Uygulama açıkken bildirim alındığında yapılacak işlemler
    print('Bildirim alındı: ${event.notification.jsonRepresentation()}');
    
    // Bildirim türüne göre filtreleme yap
    _shouldShowNotification(event.notification).then((shouldShow) {
      if (shouldShow) {
        // Bildirimi göster
        event.notification.display();
      } else {
        // Bildirimi gizle - OneSignal'da preventDefault yok, sadece göstermiyoruz
        print('Bildirim filtrelendi: ${event.notification.notificationId}');
      }
    });
  }

  // Bildirim türüne göre gösterilip gösterilmeyeceğini kontrol et
  Future<bool> _shouldShowNotification(OSNotification notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = notification.additionalData;
      
      if (data == null || data['type'] == null) {
        return true; // Tip belirtilmemişse göster
      }

      final type = data['type'] as String;
      
      switch (type) {
        case 'post':
          return prefs.getBool('post_notifications') ?? true;
        case 'message':
          return prefs.getBool('message_notifications') ?? true;
        case 'group':
          return prefs.getBool('group_notifications') ?? true;
        case 'event':
          return prefs.getBool('event_notifications') ?? true;
        case 'follow':
          return prefs.getBool('follow_notifications') ?? true;
        default:
          return true; // Bilinmeyen tip için göster
      }
    } catch (e) {
      print('Bildirim filtreleme hatası: $e');
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
      default:
        // Varsayılan olarak ana sayfaya git
        Get.offAllNamed('/home');
        break;
    }
  }

  // Player ID'yi manuel olarak almak için
  Future<String?> getPlayerId() async {
    try {
      return await OneSignal.User.pushSubscription.id;
    } catch (e) {
      print('Player ID alınamadı: $e');
      return null;
    }
  }

  // Bildirim izinlerini kontrol et
  Future<bool> hasNotificationPermission() async {
    try {
      return await OneSignal.Notifications.permission;
    } catch (e) {
      print('Bildirim izni kontrol edilemedi: $e');
      return false;
    }
  }

  // Bildirim izinlerini iste
  Future<void> requestNotificationPermission() async {
    try {
      await OneSignal.Notifications.requestPermission(true);
    } catch (e) {
      print('Bildirim izni istenemedi: $e');
    }
  }

  // Test bildirimi gönder
  Future<void> sendTestNotification() async {
    try {
      print('🧪 Test bildirimi gönderiliyor...');
      
      final playerId = await getPlayerId();
      if (playerId != null) {
        print('📱 Player ID: $playerId');
        
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
        
        print('📡 OneSignal API Response: ${response.statusCode}');
        print('📡 Response Data: ${response.data}');
        
        if (response.statusCode == 200) {
          print('✅ Test bildirimi başarıyla gönderildi');
          
          // Eğer invalid_player_ids hatası varsa
          if (response.data['errors'] != null && 
              response.data['errors']['invalid_player_ids'] != null) {
            print('⚠️ OneSignal Dashboard konfigürasyonu eksik!');
            print('🔧 Lütfen OneSignal Dashboard\'da şunları kontrol edin:');
            print('   1. App Settings → Android Configuration');
            print('   2. Package Name: com.social.edusocial');
            print('   3. App ID: $_appId');
            print('   4. REST API Key: $_apiKey');
            print('   5. Google Project Number (opsiyonel)');
          }
        } else {
          print('❌ Test bildirimi gönderilemedi: ${response.statusCode}');
        }
      } else {
        print('❌ Player ID alınamadı');
      }
    } catch (e) {
      print('❌ Test bildirimi gönderilirken hata: $e');
    }
  }

  // Yerel bildirim gönder (uygulama açıkken)
  Future<void> sendLocalNotification(String title, String message, Map<String, dynamic>? data) async {
    try {
      // Uygulama açıkken bildirim göstermek için Get.snackbar kullan
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF5050),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      print('✅ Yerel bildirim gösterildi: $title - $message');
    } catch (e) {
      print('❌ Yerel bildirim gösterilemedi: $e');
    }
  }

  // Local test notification (OneSignal Dashboard konfigürasyonu olmadan da çalışır)
  Future<void> sendLocalTestNotification() async {
    try {
      print('🧪 Local test bildirimi gönderiliyor...');
      
      Get.snackbar(
        'Test Bildirimi',
        'Bu bir local test bildirimidir',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        icon: const Icon(Icons.notifications, color: Colors.white),
      );
      
      print('✅ Local test bildirimi gösterildi');
    } catch (e) {
      print('❌ Local test bildirimi gösterilemedi: $e');
    }
  }

  // OneSignal Dashboard konfigürasyonu kontrol et
  Future<void> checkOneSignalConfiguration() async {
    try {
      print('🔧 OneSignal konfigürasyonu kontrol ediliyor...');
      
      final playerId = await getPlayerId();
      if (playerId != null) {
        print('✅ Player ID mevcut: $playerId');
        
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
            print('❌ OneSignal Dashboard konfigürasyonu eksik!');
            print('📋 Gerekli adımlar:');
            print('   1. OneSignal Dashboard → App Settings → Android Configuration');
            print('   2. Package Name: com.social.edusocial');
            print('   3. App ID: $_appId');
            print('   4. REST API Key: $_apiKey');
            print('   5. Google Project Number (opsiyonel)');
          } else {
            print('✅ OneSignal konfigürasyonu doğru');
          }
        }
      } else {
        print('❌ Player ID bulunamadı');
      }
    } catch (e) {
      print('❌ Konfigürasyon kontrolü hatası: $e');
    }
  }

  // Bildirim ayarlarını güncelle
  Future<void> updateNotificationSettings({
    required bool postNotifications,
    required bool messageNotifications,
    required bool groupNotifications,
    required bool eventNotifications,
    required bool followNotifications,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('post_notifications', postNotifications);
    await prefs.setBool('message_notifications', messageNotifications);
    await prefs.setBool('group_notifications', groupNotifications);
    await prefs.setBool('event_notifications', eventNotifications);
    await prefs.setBool('follow_notifications', followNotifications);
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
    };
  }

  // OneSignal'ın kendi servisi ile test notification (Firebase gerektirmez)
  Future<void> sendOneSignalTestNotification() async {
    String? playerId;
    
    try {
      print('🧪 OneSignal test bildirimi gönderiliyor...');
      
      playerId = await getPlayerId();
      if (playerId != null) {
        print('📱 Player ID: $playerId');
        
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
        
        print('📡 OneSignal API Response: ${response.statusCode}');
        print('📡 Response Data: ${response.data}');
        
        if (response.statusCode == 200) {
          print('✅ OneSignal test bildirimi başarıyla gönderildi');
          if (response.data['id'] != null) {
            print('📋 Notification ID: ${response.data['id']}');
          }
        } else {
          print('❌ Test bildirimi gönderilemedi: ${response.statusCode}');
          print('❌ Hata detayı: ${response.data}');
        }
      } else {
        print('❌ Player ID alınamadı');
      }
    } catch (e) {
      print('❌ OneSignal test bildirimi gönderilirken hata: $e');
      
      // Hata detaylarını göster
      if (e.toString().contains('400')) {
        print('🔧 400 hatası - Request formatı kontrol ediliyor...');
        print('📋 Kullanılan parametreler:');
        print('   - App ID: $_appId');
        print('   - Player ID: $playerId');
        print('   - API Key: ${_apiKey.substring(0, 20)}...');
      }
    }
  }

  // Basit test notification (sadece console'da bilgi gösterir)
  Future<void> sendSimpleTestNotification() async {
    try {
      print('🧪 Basit test bildirimi gönderiliyor...');
      
      final playerId = await getPlayerId();
      if (playerId != null) {
        print('📱 Player ID: $playerId');
        print('🔧 OneSignal Konfigürasyonu:');
        print('   - App ID: $_appId');
        print('   - API Key: ${_apiKey.substring(0, 20)}...');
        print('   - Package Name: com.social.edusocial');
        
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
        
        print('✅ Test bilgileri gösterildi');
        print('📋 OneSignal Dashboard\'da şunları kontrol edin:');
        print('   1. App Settings → Android Configuration');
        print('   2. Package Name: com.social.edusocial');
        print('   3. App ID: $_appId');
        print('   4. REST API Key: $_apiKey');
      } else {
        print('❌ Player ID alınamadı');
      }
    } catch (e) {
      print('❌ Basit test bildirimi hatası: $e');
    }
  }

  // Platform tespiti ile test notification
  Future<void> sendPlatformAwareTestNotification() async {
    try {
      print('🧪 Platform-aware test bildirimi gönderiliyor...');
      
      final playerId = await getPlayerId();
      if (playerId != null) {
        print('📱 Player ID: $playerId');
        
        // Platform tespiti
        String platform = 'android';
        String platformName = 'Android';
        if (GetPlatform.isIOS) {
          platform = 'ios';
          platformName = 'iOS';
        }
        
        print('🔧 Platform: $platformName');
        print('🔧 OneSignal Konfigürasyonu:');
        print('   - App ID: $_appId');
        print('   - API Key: ${_apiKey.substring(0, 20)}...');
        print('   - Package/Bundle ID: com.social.edusocial');
        print('   - Platform: $platformName');
        
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
        
        print('📡 OneSignal API Response: ${response.statusCode}');
        print('📡 Response Data: ${response.data}');
        
        if (response.statusCode == 200) {
          if (response.data['errors'] != null && 
              response.data['errors']['invalid_player_ids'] != null) {
            print('❌ OneSignal Dashboard konfigürasyonu eksik!');
            print('📋 $platformName için gerekli adımlar:');
            print('   1. OneSignal Dashboard → App Settings → ${platformName} Configuration');
            print('   2. Package/Bundle ID: com.social.edusocial');
            print('   3. App ID: $_appId');
            print('   4. REST API Key: $_apiKey');
            if (platform == 'ios') {
              print('   5. APNs Certificate (opsiyonel)');
            } else {
              print('   5. Google Project Number (opsiyonel)');
            }
          } else {
            print('✅ OneSignal test bildirimi başarıyla gönderildi');
            if (response.data['id'] != null) {
              print('📋 Notification ID: ${response.data['id']}');
            }
          }
        } else {
          print('❌ Test bildirimi gönderilemedi: ${response.statusCode}');
        }
      } else {
        print('❌ Player ID alınamadı');
      }
    } catch (e) {
      print('❌ Platform-aware test bildirimi hatası: $e');
    }
  }
} 