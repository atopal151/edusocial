import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends GetxService {
  static SocketService get to => Get.find();

  late IO.Socket _socket;
  final _isConnected = false.obs;

  bool get isConnected => _isConnected.value;

  // Socket URL (Backend tarafından 443 portu için onaylanmış)
  final String _socketUrl = 'https://stageapi.edusocial.pl';

  // Socket bağlantısını başlat
  void connectSocket(String token) {
    //debugPrint('🔑 Gelen Token: $token');
    if (_isConnected.value) {
      //debugPrint('🔌 Socket zaten bağlı.');
      return;
    }

    try {
      _socket = IO.io(
        _socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket']) // websocket harici transport kapalı
            .enableForceNew() // yeni bağlantı açılır
            .setAuth({'token': 'Bearer $token'}) // token set edilir
            .setTimeout(10000) // 10 saniye timeout
            .build(),
      );

     // debugPrint('🪝 Socket yapılandırması yapıldı.');

      // Bağlantı sağlandığında
      _socket.onConnect((_) {
       // debugPrint('✅ Socket bağlantısı sağlandı.');
        //debugPrint('🟢 Socket ID: ${_socket.id}');
        _isConnected.value = true;
      });

      // Bağlantı koparsa
      _socket.onDisconnect((_) {
        debugPrint('❌ Socket bağlantısı kesildi.');
        _isConnected.value = false;
      });

      // Bağlantı hatası alırsak
      _socket.onConnectError((data) {
        debugPrint('⚠️ Socket bağlantı hatası: $data');
      });

      // Genel hata yakalayıcı
      _socket.onError((data) {
        debugPrint('❌ Socket genel hatası: $data');
      });

      // Dinlenecek eventler
      _socket.on('conversation:new_message', (data) {
        debugPrint('📥 Yeni birebir mesaj: $data');
        // Burada ilgili controller'a yönlendirebilirsin.
      });

      _socket.on('group_conversation:new_message', (data) {
        debugPrint('👥 Yeni grup mesajı: $data');
        // Burada da grup mesaj servisine gönder.
      });

      _socket.on('conversation:un_read_message_count', (data) {
        debugPrint('📬 Okunmamış mesaj sayısı: ${data['count']}');
        // UI veya controller ile paylaşabilirsin.
      });
    } catch (e) {
      debugPrint('🚨 Socket bağlantısı sırasında beklenmeyen hata: $e');
    }
  }

  // Mesaj gönderme örneği
  void sendMessage(String eventName, dynamic message) {
    if (_isConnected.value) {
      _socket.emit(eventName, message);
      debugPrint('📤 Mesaj gönderildi: $eventName => $message');
    } else {
      debugPrint('❌ Socket bağlantısı yok, mesaj gönderilemedi.');
    }
  }

  // Socket bağlantısını kapat
  void disconnectSocket() {
    if (_isConnected.value) {
      _socket.disconnect();
      _isConnected.value = false;
      debugPrint('🔌 Socket bağlantısı kapatıldı.');
    }
  }
}
