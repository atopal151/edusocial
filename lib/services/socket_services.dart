import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends GetxService {
  late IO.Socket _socket;

  IO.Socket get socket => _socket;

  /// Socket bağlantısını başlat
  void connectSocket(String token) {
    _socket = IO.io(
      'https://stageapi.edusocial.pl:3001',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': 'Bearer $token'})
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      debugPrint('✅ Socket bağlantısı başarılı.');
    });

    _socket.onDisconnect((_) {
      debugPrint('⚠️ Socket bağlantısı koptu.');
    });

    _socket.onError((err) {
      debugPrint('❌ Socket hatası: $err');
    });
  }

  /// Socket bağlantısını kapat
  void disconnectSocket() {
    if (_socket.connected) {
      _socket.disconnect();
      debugPrint('⛔️ Socket bağlantısı kapatıldı.');
    }
  }

  /// Birebir mesaj dinleyicisi ekle
  void onPrivateMessage(Function(dynamic data) callback) {
    _socket.on('conversation:new_message', callback);
  }

  /// Grup mesajı dinleyicisi ekle
  void onGroupMessage(Function(dynamic data) callback) {
    _socket.on('group_conversation:new_message', callback);
  }

  /// Okunmamış mesaj sayısı dinleyicisi ekle
  void onUnreadMessageCount(Function(dynamic data) callback) {
    _socket.on('conversation:un_read_message_count', callback);
  }

  /// Dinleyicileri kaldır (sayfa değişince vs.)
  void removeAllListeners() {
    _socket.off('conversation:new_message');
    _socket.off('group_conversation:new_message');
    _socket.off('conversation:un_read_message_count');
    debugPrint('🔌 Tüm socket eventleri kaldırıldı.');
  }
}
