
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends GetxService {
  static SocketService get to => Get.find();

  IO.Socket? _socket;
  final _isConnected = false.obs;
  final _isConnecting = false.obs;
  final _connectionAttempts = 0.obs;
  static const int maxConnectionAttempts = 3;

  bool get isConnected => _isConnected.value;
  bool get isConnecting => _isConnecting.value;

  // Socket URL ve Port
  final String _socketUrl = 'https://stageapi.edusocial.pl';

  // Socket bağlantısını başlat
  Future<void> connectSocket(String? token) async {
    if (token == null || token.isEmpty) {
      /*debugPrint('❌ Token boş veya null, socket bağlantısı kurulamıyor.');*/
      return;
    }

    if (_isConnected.value) {
      /*debugPrint('🔌 Socket zaten bağlı.');*/
      return;
    }

    if (_isConnecting.value) {
      /*debugPrint('⏳ Socket bağlantısı zaten kuruluyor...');*/
      return;
    }

    if (_connectionAttempts.value >= maxConnectionAttempts) {
      /*debugPrint('❌ Maksimum bağlantı denemesi aşıldı.');*/
      return;
    }

    try {
      _isConnecting.value = true;
      _connectionAttempts.value++;
      /*debugPrint('🔄 Socket bağlantısı başlatılıyor... (Deneme: ${_connectionAttempts.value})');*/
      
      // Token'ı düzenle
      final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      /*debugPrint('🔑 Formatlanmış Token: ${formattedToken.substring(0, 20)}...');*/

      // Önceki socket bağlantısını temizle
      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
      }

      // Yeni socket bağlantısı oluştur
      _socket = IO.io(
        _socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableForceNew()
            .setAuth({'token': formattedToken})
            .setTimeout(10000)
            .disableAutoConnect()
            .setExtraHeaders({
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            })
            .setPath('/socket.io')
            .setQuery({'token': formattedToken})
            .build(),
      );

      // Bağlantı sağlandığında
      _socket!.onConnect((_) {
        /*debugPrint('✅ Socket bağlantısı sağlandı.');
        debugPrint('🟢 Socket ID: ${_socket!.id}');*/
        _isConnected.value = true;
        _isConnecting.value = false;
        _connectionAttempts.value = 0;
      });

      // Bağlantı koparsa
      _socket!.onDisconnect((_) {
        /*debugPrint('❌ Socket bağlantısı kesildi.');*/
        _isConnected.value = false;
        _isConnecting.value = false;
      });

      // Bağlantı hatası alırsak
      _socket!.onConnectError((data) {
        /*debugPrint('⚠️ Socket bağlantı hatası: $data');*/
        _isConnecting.value = false;
      });

      // Genel hata yakalayıcı
      _socket!.onError((data) {
        /*debugPrint('❌ Socket genel hatası: $data');*/
        _isConnecting.value = false;
      });

      // Birebir mesaj dinleyicisi
      _socket!.on('conversation:new_message', (data) {
        /*debugPrint('📥 Yeni birebir mesaj: $data');*/
      });

      // Grup mesajı dinleyicisi
      _socket!.on('group_conversation:new_message', (data) {
        /*debugPrint('👥 Yeni grup mesajı: $data');*/
      });

      // Okunmamış mesaj sayısı dinleyicisi
      _socket!.on('conversation:un_read_message_count', (data) {
        /*debugPrint('📬 Okunmamış mesaj sayısı: ${data['count']}');*/
      });

      // Manuel olarak bağlan
      _socket!.connect();
      
      // Bağlantı durumunu kontrol et
      /*debugPrint('🔍 Socket bağlantı durumu: ${_socket!.connected}');
      debugPrint('🔍 Socket ID: ${_socket!.id}');*/

      // 10 saniye sonra hala bağlantı kurulmadıysa
      Future.delayed(const Duration(seconds: 10), () {
        if (!_isConnected.value && _isConnecting.value) {
          /*debugPrint('⚠️ Socket bağlantısı zaman aşımına uğradı.');*/
          _isConnecting.value = false;
          _socket?.disconnect();
        }
      });
    } catch (e) {
      /*debugPrint('🚨 Socket bağlantısı sırasında beklenmeyen hata: $e');*/
      _isConnecting.value = false;
    }
  }

  // Mesaj gönderme örneği
  void sendMessage(String eventName, dynamic message) {
    if (_socket == null) {
      /*debugPrint('❌ Socket bağlantısı yok, mesaj gönderilemedi.');*/
      return;
    }

    try {
      _socket!.emit(eventName, message);
      /*debugPrint('📤 Mesaj gönderildi: $eventName => $message');*/
    } catch (e) {
      /*debugPrint('❌ Mesaj gönderilirken hata oluştu: $e');*/
    }
  }

  // Yeni mesaj dinleyicisi
  void onNewPrivateMessage(Function(dynamic) callback) {
    if (_socket == null) {
      /*debugPrint('❌ Socket bağlantısı yok, dinleyici eklenemedi.');*/
      return;
    }

    try {
      _socket!.on('conversation:new_message', callback);
      /*debugPrint('👂 Yeni mesaj dinleyicisi eklendi.');*/
    } catch (e) {
      /*debugPrint('❌ Dinleyici eklenirken hata oluştu: $e');*/
    }
  }

  // Socket bağlantısını kapat
  void disconnectSocket() {
    if (_socket != null) {
      try {
        _socket!.disconnect();
        _isConnected.value = false;
        _connectionAttempts.value = 0;
        /*debugPrint('🔌 Socket bağlantısı kapatıldı.');*/
      } catch (e) {
        /*debugPrint('❌ Socket kapatılırken hata oluştu: $e');*/
      }
    }
  }

  @override
  void onClose() {
    disconnectSocket();
    super.onClose();
  }
}
