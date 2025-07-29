import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'onesignal_service.dart';

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

  // Public streams that other parts of the app can listen to
  Stream<dynamic> get onPrivateMessage => _privateMessageController.stream;
  Stream<dynamic> get onGroupMessage => _groupMessageController.stream;
  Stream<dynamic> get onUnreadMessageCount => _unreadMessageCountController.stream;
  Stream<dynamic> get onNotification => _notificationController.stream;
  Stream<dynamic> get onPostNotification => _postNotificationController.stream;

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

    // 5. Post bildirimi (yeni)
    _socket!.on('post:notification', (data) {
      debugPrint('📝 Post bildirimi geldi (SocketService): $data');
      _postNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('post', data);
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
    debugPrint('🔍 ===========================');
  }

  // Test mesajı gönder
  void sendTestGroupMessage() {
    debugPrint('🧪 Test grup mesajı gönderiliyor...');
    if (_socket != null && _socket!.connected) {
      _socket!.emit('test', {'message': 'Test grup mesajı'});
      debugPrint('✅ Test mesajı gönderildi');
    } else {
      debugPrint('❌ Socket bağlı değil, test mesajı gönderilemedi');
    }
  }

  // Test bildirimi gönder
  void sendTestNotification() {
    debugPrint('🧪 Test bildirimi gönderiliyor...');
    if (_socket != null && _socket!.connected) {
      _socket!.emit('test_notification', {
        'message': 'Test bildirimi',
        'timestamp': DateTime.now().toIso8601String()
      });
      debugPrint('✅ Test bildirimi gönderildi');
    } else {
      debugPrint('❌ Socket bağlı değil, test bildirimi gönderilemedi');
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
    disconnect();
    super.onClose();
  }
}
