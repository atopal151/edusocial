import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends GetxService {
  IO.Socket? _socket;
  final RxBool isConnected = false.obs;

  // Bağlantı adresi - farklı endpoint'leri deneyeceğiz
  static const String _socketUrl = 'https://stageapi.edusocial.pl';
  static const String _socketUrlWithPort = 'https://stageapi.edusocial.pl:3000';
  static const String _socketUrlWithPath = 'https://stageapi.edusocial.pl/socket.io';

  // Socket başlat
  void connect(String jwtToken) {
    print('🔌 SocketService.connect() çağrıldı');
    print('🔌 Token: ${jwtToken.substring(0, 20)}...');
    
    if (_socket != null && _socket!.connected) {
      print('🔌 Socket zaten bağlı, yeni bağlantı kurulmuyor');
      return;
    }

    // Farklı URL'leri dene
    _tryConnectWithUrl(_socketUrl, jwtToken, 'Ana URL');
  }

  void _tryConnectWithUrl(String url, String jwtToken, String urlName) {
    print('🔌 $urlName ile bağlantı deneniyor: $url');
    
    // Socket.IO options
    final options = IO.OptionBuilder()
        .setTransports(['websocket', 'polling']) // Hem websocket hem polling dene
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

    _socket = IO.io(url, options);

    print('🔌 Socket event dinleyicileri ayarlanıyor...');
    
    // Bağlantı eventleri
    _socket!.onConnect((_) {
      isConnected.value = true;
      print('✅ Socket bağlı! ($urlName)');
      print('✅ Socket ID: ${_socket!.id}');
    });
    
    _socket!.onDisconnect((_) {
      isConnected.value = false;
      print('❌ Socket bağlantısı kesildi! ($urlName)');
    });
    
    _socket!.onConnectError((err) {
      isConnected.value = false;
      print('❌ Socket bağlantı hatası ($urlName): $err');
      print('❌ Hata tipi: ${err.runtimeType}');
      
      // Eğer bu URL başarısız olursa, diğer URL'leri dene
      if (url == _socketUrl) {
        print('🔄 Diğer URL\'ler deneniyor...');
        Future.delayed(Duration(seconds: 2), () {
          _tryConnectWithUrl(_socketUrlWithPort, jwtToken, 'Port 3000');
        });
      } else if (url == _socketUrlWithPort) {
        print('🔄 Son URL deneniyor...');
        Future.delayed(Duration(seconds: 2), () {
          _tryConnectWithUrl(_socketUrlWithPath, jwtToken, 'Socket.io Path');
        });
      } else {
        print('❌ Tüm URL\'ler başarısız oldu!');
        print('🔍 Lütfen sunucu yöneticisi ile iletişime geçin.');
      }
    });
    
    _socket!.onError((err) {
      isConnected.value = false;
      print('❌ Socket genel hata ($urlName): $err');
    });

    // Reconnection events
    _socket!.onReconnect((_) {
      print('🔄 Socket yeniden bağlandı! ($urlName)');
    });
    
    _socket!.onReconnectAttempt((attemptNumber) {
      print('🔄 Yeniden bağlanma denemesi ($urlName): $attemptNumber');
    });
    
    _socket!.onReconnectError((error) {
      print('❌ Yeniden bağlanma hatası ($urlName): $error');
    });

    // Event dinleyiciler
    print('🔌 Event dinleyicileri ayarlanıyor...');
    // 1. Birebir mesaj
    _socket!.on('conversation:new_message', (data) {
      print('📨 Birebir mesaj geldi: $data');
      if (onPrivateMessage != null) onPrivateMessage!(data);
    });
    // 2. Grup mesajı
    _socket!.on('group_conversation:new_message', (data) {
      print('📨 Grup mesajı geldi: $data');
      if (onGroupMessage != null) onGroupMessage!(data);
    });
    // 3. Okunmamış mesaj sayısı
    _socket!.on('conversation:un_read_message_count', (data) {
      print('📨 Okunmamış mesaj sayısı: $data');
      if (onUnreadMessageCount != null) onUnreadMessageCount!(data);
    });

    print('🔌 Socket bağlantısı başlatılıyor... ($urlName)');
    _socket!.connect();
    
    // Bağlantı durumunu kontrol et
    Future.delayed(Duration(seconds: 5), () {
      print('🔍 Socket bağlantı durumu kontrol ediliyor... ($urlName)');
      print('🔍 isConnected.value: ${isConnected.value}');
      print('🔍 _socket?.connected: ${_socket?.connected}');
      print('🔍 _socket?.id: ${_socket?.id}');
    });
  }

  // Callback fonksiyonları dışarıdan atanabilir
  Function(dynamic)? onPrivateMessage;
  Function(dynamic)? onGroupMessage;
  Function(dynamic)? onUnreadMessageCount;

  // Mesaj gönderme
  void sendMessage(String event, dynamic data) {
    print('📤 Mesaj gönderiliyor: $event');
    print('📤 Data: $data');
    if (_socket != null && _socket!.connected) {
      _socket!.emit(event, data);
      print('✅ Mesaj gönderildi');
    } else {
      print('❌ Socket bağlı değil, mesaj gönderilemedi');
      print('❌ Socket durumu: ${_socket?.connected}');
    }
  }

  // Bağlantıyı kapat
  void disconnect() {
    print('🔌 Socket bağlantısı kapatılıyor...');
    _socket?.disconnect();
    isConnected.value = false;
    print('✅ Socket bağlantısı kapatıldı');
  }

  // Dinleyicileri temizle
  void removeAllListeners() {
    print('🔌 Socket dinleyicileri temizleniyor...');
    _socket?.clearListeners();
    print('✅ Socket dinleyicileri temizlendi');
  }
}
