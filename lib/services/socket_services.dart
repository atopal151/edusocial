import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'onesignal_service.dart';
import 'package:get_storage/get_storage.dart';

class SocketService extends GetxService {
  io.Socket? _socket;
  final RxBool isConnected = false.obs;
  
  // OneSignal service
  final OneSignalService _oneSignalService = Get.find<OneSignalService>();

  // Stream Controllers for broadcasting events
  final _privateMessageController = StreamController<dynamic>.broadcast();
  final _groupMessageController = StreamController<dynamic>.broadcast();
  final _unreadMessageCountController = StreamController<dynamic>.broadcast();
  final _notificationController = StreamController<dynamic>.broadcast();
  final _postNotificationController = StreamController<dynamic>.broadcast();
  final _userNotificationController = StreamController<dynamic>.broadcast();
  final _commentNotificationController = StreamController<dynamic>.broadcast();

  // Public streams that other parts of the app can listen to
  Stream<dynamic> get onPrivateMessage => _privateMessageController.stream;
  Stream<dynamic> get onGroupMessage => _groupMessageController.stream;
  Stream<dynamic> get onUnreadMessageCount => _unreadMessageCountController.stream;
  Stream<dynamic> get onNotification => _notificationController.stream;
  Stream<dynamic> get onPostNotification => _postNotificationController.stream;
  Stream<dynamic> get onUserNotification => _userNotificationController.stream;
  Stream<dynamic> get onCommentNotification => _commentNotificationController.stream;

  // Bağlantı adresi - farklı endpoint'leri deneyeceğiz
  static const String _socketUrl = 'https://stageapi.edusocial.pl';
  static const String _socketUrlWithPort = 'https://stageapi.edusocial.pl:3000';
  static const String _socketUrlWithPath = 'https://stageapi.edusocial.pl/socket.io';

  // Socket başlat
  void connect(String jwtToken) {
    debugPrint('🔌 SocketService.connect() çağrıldı');
    debugPrint('🔌 Token: ${jwtToken.substring(0, 20)}...');
    
    if (_socket != null && _socket!.connected) {
      debugPrint('🔌 Socket zaten bağlı, yeni bağlantı kurulmuyor');
      return;
    }

    // Farklı URL'leri dene
    _tryConnectWithUrl(_socketUrl, jwtToken, 'Ana URL');
  }

  void _tryConnectWithUrl(String url, String jwtToken, String urlName) {
    debugPrint('🔌 $urlName ile bağlantı deneniyor: $url');
    
    // Socket.IO options
    final options = io.OptionBuilder()
        .setTransports(['websocket']) // Sadece websocket kullan
        .setAuth({
          "auth": {
            "token": jwtToken
          }
        })
        .setExtraHeaders({
          'Authorization': 'Bearer $jwtToken'
        })
        .disableAutoConnect() // Manuel bağlanacağız
        .enableReconnection() // Yeniden bağlanmayı etkinleştir
        .setReconnectionAttempts(3) // 3 kez dene
        .setReconnectionDelay(2000) // 2 saniye bekle
        .setReconnectionDelayMax(5000) // Max 5 saniye bekle
        .setTimeout(10000) // 10 saniye timeout
        .build();

    _socket = io.io(url, options);

    debugPrint('🔌 Socket event dinleyicileri ayarlanıyor...');
    
    // Bağlantı eventleri
    _socket!.onConnect((_) {
      isConnected.value = true;
      debugPrint('✅ Socket bağlı! ($urlName)');
      debugPrint('✅ Socket ID: ${_socket!.id}');
      
      // Bağlantı kurulduktan sonra tüm kanallara join ol
      Future.delayed(Duration(seconds: 1), () {
        _joinAllChannelsAfterConnection();
      });
    });
    
    _socket!.onDisconnect((_) {
      isConnected.value = false;
      debugPrint('❌ Socket bağlantısı kesildi! ($urlName)');
    });
    
    _socket!.onConnectError((err) {
      isConnected.value = false;
      debugPrint('❌ Socket bağlantı hatası ($urlName): $err');
      debugPrint('❌ Hata tipi: ${err.runtimeType}');
      
      // Eğer bu URL başarısız olursa, diğer URL'leri dene
      if (url == _socketUrl) {
        debugPrint('🔄 Diğer URL\'ler deneniyor...');
        Future.delayed(Duration(seconds: 2), () {
          _tryConnectWithUrl(_socketUrlWithPort, jwtToken, 'Port 3000');
        });
      } else if (url == _socketUrlWithPort) {
        debugPrint('🔄 Son URL deneniyor...');
        Future.delayed(Duration(seconds: 2), () {
          _tryConnectWithUrl(_socketUrlWithPath, jwtToken, 'Socket.io Path');
        });
      } else {
        debugPrint('❌ Tüm URL\'ler başarısız oldu!');
        debugPrint('🔍 Lütfen sunucu yöneticisi ile iletişime geçin.');
      }
    });
    
    _socket!.onError((err) {
      isConnected.value = false;
      debugPrint('❌ Socket genel hata ($urlName): $err');
    });

    // Reconnection events
    _socket!.onReconnect((_) {
      debugPrint('🔄 Socket yeniden bağlandı! ($urlName)');
    });
    
    _socket!.onReconnectAttempt((attemptNumber) {
      debugPrint('🔄 Yeniden bağlanma denemesi ($urlName): $attemptNumber');
    });
    
    _socket!.onReconnectError((error) {
      debugPrint('❌ Yeniden bağlanma hatası ($urlName): $error');
    });

    // Event dinleyiciler
    debugPrint('🔌 Event dinleyicileri ayarlanıyor...');
    // 1. Yeni özel mesaj
    _socket!.on('conversation:new_message', (data) {
      debugPrint('💬 Yeni özel mesaj (SocketService): $data');
      _privateMessageController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('message', data);
    });

    // 2. Yeni grup mesajı
    _socket!.on('group_conversation:new_message', (data) {
      debugPrint('👥 Yeni grup mesajı (SocketService): $data');
      _groupMessageController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('group', data);
    });

    // 3. Okunmamış mesaj sayısı
    _socket!.on('conversation:un_read_message_count', (data) {
      debugPrint('📨 Okunmamış mesaj sayısı (SocketService): $data');
      _unreadMessageCountController.add(data);
    });

    // 4. Yeni bildirim
    _socket!.on('notification:new', (data) {
      debugPrint('🔔 Yeni bildirim geldi (SocketService): $data');
      _notificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('notification', data);
    });

    // 5. Notification event (private chat'teki gibi global)
    _socket!.on('notification:event', (data) {
      debugPrint('🔔 Notification event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 6. Comment notification (global)
    _socket!.on('comment:event', (data) {
      debugPrint('💬 Comment event geldi (SocketService): $data');
      _commentNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 7. Like notification (global)
    _socket!.on('like:event', (data) {
      debugPrint('❤️ Like event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 8. Follow notification (global)
    _socket!.on('follow:event', (data) {
      debugPrint('👥 Follow event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 9. Post notification (global)
    _socket!.on('post:event', (data) {
      debugPrint('📝 Post event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 10. Group join request notification (global)
    _socket!.on('group:join_request', (data) {
      debugPrint('👥 Group join request event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 11. Group join accepted notification (global)
    _socket!.on('group:join_accepted', (data) {
      debugPrint('✅ Group join accepted event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 12. Group join declined notification (global)
    _socket!.on('group:join_declined', (data) {
      debugPrint('❌ Group join declined event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 13. Follow request notification (global)
    _socket!.on('follow:request', (data) {
      debugPrint('👤 Follow request event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 14. Follow accepted notification (global)
    _socket!.on('follow:accepted', (data) {
      debugPrint('✅ Follow accepted event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 15. Follow declined notification (global)
    _socket!.on('follow:declined', (data) {
      debugPrint('❌ Follow declined event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 16. Event invitation notification (global)
    _socket!.on('event:invitation', (data) {
      debugPrint('📅 Event invitation event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 17. Event reminder notification (global)
    _socket!.on('event:reminder', (data) {
      debugPrint('⏰ Event reminder event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 18. Post mention notification (global)
    _socket!.on('post:mention', (data) {
      debugPrint('📝 Post mention event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 19. Comment mention notification (global)
    _socket!.on('comment:mention', (data) {
      debugPrint('💬 Comment mention event geldi (SocketService): $data');
      _commentNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 20. System notification (global)
    _socket!.on('system:notification', (data) {
      debugPrint('🔔 System notification event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 21. User notification (user:{user_id} kanalı)
    _socket!.on('user:notification', (data) {
      debugPrint('👤 User notification geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 22. User specific notification (user:{user_id} formatı)
    _socket!.on('user:*', (data) {
      debugPrint('👤 User specific notification geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 23. Private notification (alternatif event ismi)
    _socket!.on('private:notification', (data) {
      debugPrint('🔒 Private notification geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 24. User message (alternatif event ismi)
    _socket!.on('user:message', (data) {
      debugPrint('👤 User message geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 25. Direct notification (alternatif event ismi)
    _socket!.on('direct:notification', (data) {
      debugPrint('📨 Direct notification geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 26. Personal notification (alternatif event ismi)
    _socket!.on('personal:notification', (data) {
      debugPrint('👤 Personal notification geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 27. Post comment notification
    _socket!.on('post:comment', (data) {
      debugPrint('💬 Post comment notification geldi (SocketService): $data');
      _commentNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 28. Comment notification (alternatif event ismi)
    _socket!.on('comment:new', (data) {
      debugPrint('💬 Comment notification geldi (SocketService): $data');
      _commentNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 29. Post activity notification
    _socket!.on('post:activity', (data) {
      debugPrint('📝 Post activity notification geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 30. Timeline notification
    _socket!.on('timeline:notification', (data) {
      debugPrint('📅 Timeline notification geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 31. Follow notification
    _socket!.on('follow:notification', (data) {
      debugPrint('👥 Follow notification geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 32. Like notification
    _socket!.on('like:notification', (data) {
      debugPrint('❤️ Like notification geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 33. Group notification
    _socket!.on('group:notification', (data) {
      debugPrint('👥 Group notification geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 34. Event notification
    _socket!.on('event:notification', (data) {
      debugPrint('📅 Event notification geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 35. General activity notification
    _socket!.on('activity:notification', (data) {
      debugPrint('🎯 Activity notification geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 36. Real-time notification (genel)
    _socket!.on('realtime:notification', (data) {
      debugPrint('⚡ Real-time notification geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 37. All notifications (catch-all)
    _socket!.on('*', (data) {
      debugPrint('🔔 Wildcard notification geldi (SocketService): $data');
      _notificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 38. Tüm event'leri yakalamak için wildcard listener
    _socket!.onAny((event, data) {
      debugPrint('🎯 === SOCKET EVENT YAKALANDI ===');
      debugPrint('🎯 Event: $event');
      debugPrint('🎯 Data: $data');
      debugPrint('🎯 Data Type: ${data.runtimeType}');
      
      // Data'yı daha detaylı analiz et
      if (data is Map) {
        debugPrint('🎯 Data Keys: ${data.keys.toList()}');
        if (data.containsKey('type')) {
          debugPrint('🎯 Notification Type: ${data['type']}');
        }
        if (data.containsKey('message')) {
          debugPrint('🎯 Message: ${data['message']}');
        }
        if (data.containsKey('user_id')) {
          debugPrint('🎯 User ID: ${data['user_id']}');
        }
      }
      
      debugPrint('🎯 ================================');
      
      // Eğer user kanalından gelen bir event ise
      if (event.toString().contains('user') || 
          event.toString().contains('notification') ||
          event.toString().contains('comment') ||
          event.toString().contains('like') ||
          event.toString().contains('follow') ||
          event.toString().contains('post')) {
        
        debugPrint('✅ User kanalından gelen event tespit edildi!');
        _userNotificationController.add(data);
        
        // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
      }
    });

    debugPrint('🔌 Socket bağlantısı başlatılıyor... ($urlName)');
    _socket!.connect();
    
    // Bağlantı durumunu kontrol et
    Future.delayed(Duration(seconds: 5), () {
      debugPrint('🔍 Socket bağlantı durumu kontrol ediliyor... ($urlName)');
      debugPrint('🔍 isConnected.value: ${isConnected.value}');
      debugPrint('🔍 _socket?.connected: ${_socket?.connected}');
      debugPrint('🔍 _socket?.id: ${_socket?.id}');
    });
  }

  // Mesaj gönderme
  void sendMessage(String event, dynamic data) {
    debugPrint('📤 Mesaj gönderiliyor: $event');
    debugPrint('📤 Data: $data');
    if (_socket != null && _socket!.connected) {
      _socket!.emit(event, data);
      debugPrint('✅ Mesaj gönderildi');
    } else {
      debugPrint('❌ Socket bağlı değil, mesaj gönderilemedi');
      debugPrint('❌ Socket durumu: ${_socket?.connected}');
    }
  }

  /// Test için manuel event gönder
  void sendTestEvent(String eventName, Map<String, dynamic> data) {
    if (_socket != null && _socket!.connected) {
      debugPrint('🧪 Test event gönderiliyor: $eventName');
      debugPrint('🧪 Test data: $data');
      _socket!.emit(eventName, data);
      debugPrint('✅ Test event gönderildi');
    } else {
      debugPrint('❌ Socket bağlı değil, test event gönderilemedi');
    }
  }

  // Socket durumunu kontrol etme
  void checkSocketStatus() {
    debugPrint('🔍 === SOCKET DURUM RAPORU ===');
    debugPrint('🔍 Socket nesnesi: ${_socket != null ? "✅ Var" : "❌ Yok"}');
    debugPrint('🔍 Bağlantı durumu: ${_socket?.connected ?? false ? "✅ Bağlı" : "❌ Bağlı değil"}');
    debugPrint('🔍 Socket ID: ${_socket?.id ?? "Yok"}');
    debugPrint('🔍 isConnected observable: ${isConnected.value}');
    debugPrint('🔍 Dinlenen event\'ler:');
    debugPrint('  - conversation:new_message');
    debugPrint('  - group_conversation:new_message');
    debugPrint('  - conversation:un_read_message_count');
    debugPrint('  - notification:new');
    debugPrint('  - notification:event');
    debugPrint('  - comment:event');
    debugPrint('  - like:event');
    debugPrint('  - follow:event');
    debugPrint('  - post:event');
    debugPrint('  - group:join_request');
    debugPrint('  - group:join_accepted');
    debugPrint('  - group:join_declined');
    debugPrint('  - follow:request');
    debugPrint('  - follow:accepted');
    debugPrint('  - follow:declined');
    debugPrint('  - event:invitation');
    debugPrint('  - event:reminder');
    debugPrint('  - post:mention');
    debugPrint('  - comment:mention');
    debugPrint('  - system:notification');
    debugPrint('  - user:notification');
    debugPrint('  - user:*');
    debugPrint('  - private:notification');
    debugPrint('  - user:message');
    debugPrint('  - direct:notification');
    debugPrint('  - personal:notification');
    debugPrint('  - post:comment');
    debugPrint('  - comment:new');
    debugPrint('  - post:activity');
    debugPrint('  - timeline:notification');
    debugPrint('  - follow:notification');
    debugPrint('  - like:notification');
    debugPrint('  - group:notification');
    debugPrint('  - event:notification');
    debugPrint('  - activity:notification');
    debugPrint('  - realtime:notification');
    debugPrint('  - * (wildcard)');
    debugPrint('  - onAny (tüm event\'ler)');
    debugPrint('🔍 ===========================');
  }

  /// User kanalına join ol
  void joinUserChannel(String userId) {
    if (_socket != null && _socket!.connected) {
      debugPrint('👤 User kanalına join olunuyor: user:$userId');
      debugPrint('👤 Socket ID: ${_socket!.id}');
      debugPrint('👤 Socket connected: ${_socket!.connected}');
      
      // User kanalı
      _socket!.emit('join', {'channel': 'user:$userId'});
      _socket!.emit('subscribe', {'channel': 'user:$userId'});
      _socket!.emit('join:user', {'user_id': userId});
      _socket!.emit('subscribe:user', {'user_id': userId});
      
      // Alternatif join yöntemleri
      _socket!.emit('join', {'user_id': userId});
      _socket!.emit('subscribe', {'user_id': userId});
      _socket!.emit('user:join', {'user_id': userId});
      _socket!.emit('user:subscribe', {'user_id': userId});
      
      // Farklı kanal isimleri
      _socket!.emit('join', {'channel': 'notifications'});
      _socket!.emit('subscribe', {'channel': 'notifications'});
      _socket!.emit('join', {'channel': 'user_notifications'});
      _socket!.emit('subscribe', {'channel': 'user_notifications'});
      _socket!.emit('join', {'channel': 'user_$userId'});
      _socket!.emit('subscribe', {'channel': 'user_$userId'});
      
      // Genel notification kanalları
      _socket!.emit('join', {'channel': 'comments'});
      _socket!.emit('subscribe', {'channel': 'comments'});
      _socket!.emit('join', {'channel': 'likes'});
      _socket!.emit('subscribe', {'channel': 'likes'});
      _socket!.emit('join', {'channel': 'follows'});
      _socket!.emit('subscribe', {'channel': 'follows'});
      
      debugPrint('✅ User kanalına join istekleri gönderildi');
    } else {
      debugPrint('❌ Socket bağlı değil, user kanalına join olunamıyor');
    }
  }

  /// User kanalından ayrıl
  void leaveUserChannel(String userId) {
    if (_socket != null && _socket!.connected) {
      debugPrint('👤 User kanalından ayrılıyor: user:$userId');
      
      // Farklı event isimlerini dene
      _socket!.emit('leave', {'channel': 'user:$userId'});
      _socket!.emit('unsubscribe', {'channel': 'user:$userId'});
      _socket!.emit('leave:user', {'user_id': userId});
      _socket!.emit('unsubscribe:user', {'user_id': userId});
      
      debugPrint('✅ User kanalından ayrılma istekleri gönderildi');
    } else {
      debugPrint('❌ Socket bağlı değil, user kanalından ayrılamıyor');
    }
  }

  /// Tüm bildirim kanallarına join ol
  void joinAllNotificationChannels(String userId) {
    if (_socket != null && _socket!.connected) {
      debugPrint('🔔 User kanalına join olunuyor: user:$userId');
      
      // User kanalı
      _socket!.emit('join', {'channel': 'user:$userId'});
      _socket!.emit('subscribe', {'channel': 'user:$userId'});
      _socket!.emit('join:user', {'user_id': userId});
      _socket!.emit('subscribe:user', {'user_id': userId});
      
      debugPrint('✅ User kanalına join istekleri gönderildi');
    } else {
      debugPrint('❌ Socket bağlı değil, user kanalına join olunamıyor');
    }
  }

  /// Bağlantı kurulduktan sonra tüm kanallara join ol
  void _joinAllChannelsAfterConnection() {
    try {
      // Token'dan user ID'yi çıkar
      final token = GetStorage().read('token');
      if (token != null) {
        debugPrint('🔔 Bağlantı sonrası user kanalına join olunuyor...');
        
        // User kanalına join ol (user ID olmadan genel join)
        _socket!.emit('join', {'channel': 'user'});
        _socket!.emit('subscribe', {'channel': 'user'});
        
        debugPrint('✅ Bağlantı sonrası user kanalına join istekleri gönderildi');
      }
    } catch (e) {
      debugPrint('❌ Bağlantı sonrası user kanalına join olma hatası: $e');
    }
  }

  // OneSignal bildirimi gönder (uygulama açıkken)
  void _sendOneSignalNotification(String type, dynamic data) {
    try {
      debugPrint('📱 OneSignal bildirimi gönderiliyor: $type');
      
      // Bildirim içeriğini hazırla
      String title = '';
      String message = '';
      
      switch (type) {
        case 'message':
          title = 'Yeni Mesaj';
          message = data['message'] ?? 'Yeni bir mesajınız var';
          break;
        case 'group':
          title = 'Grup Mesajı';
          message = data['message'] ?? 'Grup sohbetinde yeni mesaj';
          break;
        case 'notification':
          title = 'Yeni Bildirim';
          message = data['message'] ?? 'Yeni bir bildiriminiz var';
          break;
        case 'post':
          title = 'Post Aktivitesi';
          message = data['message'] ?? 'Post\'unuzda yeni aktivite';
          break;
        case 'user_notification':
          title = 'Kişisel Bildirim';
          message = data['message'] ?? 'Yeni bir kişisel bildiriminiz var';
          break;
        case 'comment':
          title = 'Yeni Yorum';
          message = data['message'] ?? 'Post\'unuza yeni yorum geldi';
          break;
        case 'follow':
          title = 'Yeni Takipçi';
          message = data['message'] ?? 'Yeni bir takipçiniz var';
          break;
        case 'like':
          title = 'Yeni Beğeni';
          message = data['message'] ?? 'Post\'unuza yeni beğeni geldi';
          break;
        case 'group':
          title = 'Grup Bildirimi';
          message = data['message'] ?? 'Grup aktivitesi';
          break;
        case 'event':
          title = 'Etkinlik Bildirimi';
          message = data['message'] ?? 'Yeni etkinlik bildirimi';
          break;
        case 'activity':
          title = 'Aktivite Bildirimi';
          message = data['message'] ?? 'Yeni aktivite';
          break;
        case 'realtime':
          title = 'Anlık Bildirim';
          message = data['message'] ?? 'Yeni anlık bildirim';
          break;
        case 'general':
          title = 'Bildirim';
          message = data['message'] ?? 'Yeni bildirim';
          break;
        default:
          title = 'Bildirim';
          message = data['message'] ?? 'Yeni bildirim';
      }
      
      // OneSignal bildirimi gönder
      _oneSignalService.sendLocalNotification(title, message, data);
      
      debugPrint('✅ OneSignal bildirimi gönderildi: $title - $message');
    } catch (e) {
      debugPrint('❌ OneSignal bildirimi gönderilemedi: $e');
    }
  }

  // Bağlantıyı kapat
  void disconnect() {
    debugPrint('🔌 Socket bağlantısı kapatılıyor...');
    _socket?.disconnect();
    isConnected.value = false;
    debugPrint('✅ Socket bağlantısı kapatıldı');
  }

  // Dinleyicileri temizle
  void removeAllListeners() {
    debugPrint('🔌 Socket dinleyicileri temizleniyor...');
    _socket?.clearListeners();
    debugPrint('✅ Socket dinleyicileri temizlendi');
  }

  @override
  void onClose() {
    _privateMessageController.close();
    _groupMessageController.close();
    _unreadMessageCountController.close();
    _notificationController.close();
    _postNotificationController.close();
    _userNotificationController.close();
    _commentNotificationController.close();
    disconnect();
    super.onClose();
  }

  /// Socket nesnesi
  io.Socket? get socket => _socket;
}
