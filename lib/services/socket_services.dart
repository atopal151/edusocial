import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'onesignal_service.dart';
import 'package:get_storage/get_storage.dart';
import 'group_services/group_service.dart';
import '../components/print_full_text.dart';

class SocketService extends GetxService {
  io.Socket? _socket;
  final RxBool isConnected = false.obs;
  
  // OneSignal service
  final OneSignalService _oneSignalService = Get.find<OneSignalService>();
  
  // Group service
  final GroupServices _groupServices = GroupServices();
  
  // DEBOUNCE: Çoklu bildirimleri engellemek için
  final Map<String, DateTime> _lastNotificationTime = {};
  static const Duration _notificationDebounce = Duration(seconds: 10);

  // Stream Controllers for broadcasting events
  final _privateMessageController = StreamController<dynamic>.broadcast();
  final _groupMessageController = StreamController<dynamic>.broadcast();
  final _unreadMessageCountController = StreamController<dynamic>.broadcast();
  final _notificationController = StreamController<dynamic>.broadcast();
  final _postNotificationController = StreamController<dynamic>.broadcast();
  final _userNotificationController = StreamController<dynamic>.broadcast();
  final _commentNotificationController = StreamController<dynamic>.broadcast();
  final _pinMessageController = StreamController<dynamic>.broadcast();

  // Public streams that other parts of the app can listen to
  Stream<dynamic> get onPrivateMessage => _privateMessageController.stream;
  Stream<dynamic> get onGroupMessage => _groupMessageController.stream;
  Stream<dynamic> get onUnreadMessageCount => _unreadMessageCountController.stream;
  Stream<dynamic> get onNotification => _notificationController.stream;
  Stream<dynamic> get onPostNotification => _postNotificationController.stream;
  Stream<dynamic> get onUserNotification => _userNotificationController.stream;
  Stream<dynamic> get onCommentNotification => _commentNotificationController.stream;
  Stream<dynamic> get onPinMessage => _pinMessageController.stream;

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
      Future.delayed(Duration(seconds: 1), () async {
        await _joinAllChannelsAfterConnection();
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
    // 1. Yeni private mesaj
    _socket!.on('conversation:new_message', (data) {
      debugPrint('💬 Yeni private mesaj geldi (SocketService): $data');
      
      // CONVERSATION alanını detaylı incele
      if (data is Map<String, dynamic>) {
       
        
        // KIRMIZI NOKTA MANTIĞI ANALİZİ
        final isRead = data['is_read'] ?? false;
        
        if (!isRead) {
          debugPrint('🔴 KIRMIZI NOKTA GÖSTERİLECEK: Okunmamış mesaj (is_read: $isRead)');
        } else {
          debugPrint('⚪ KIRMIZI NOKTA GÖSTERİLMEYECEK: Okunmuş mesaj (is_read: $isRead)');
        }
        
        // CONVERSATION alanını kontrol et
        if (data.containsKey('conversation')) {
          final conversation = data['conversation'];
         
          
          if (conversation is Map<String, dynamic>) {
            debugPrint('💬 📁 Conversation keys: ${conversation.keys.toList()}');
            if (conversation.containsKey('unread_count')) {
              debugPrint('💬 🔥 UNREAD COUNT BULUNDU: ${conversation['unread_count']}');
            }
            if (conversation.containsKey('unread_messages_count')) {
              debugPrint('💬 🔥 UNREAD MESSAGES COUNT BULUNDU: ${conversation['unread_messages_count']}');
            }
          }
        } else {
          debugPrint('💬 ❌ Conversation alanı yok');
        }
        
        // SENDER alanını kontrol et
        if (data.containsKey('sender')) {
          final sender = data['sender'];
          debugPrint('💬 👤 SENDER ALANı VAR: ${sender.runtimeType}');
          if (sender is Map<String, dynamic>) {
            debugPrint('💬 👤 Sender keys: ${sender.keys.toList()}');
            if (sender.containsKey('unread_messages_total_count')) {
              debugPrint('💬 🔥 SENDER UNREAD COUNT: ${sender['unread_messages_total_count']}');
            }
          }
        }
        
      }
      
      _privateMessageController.add(data);
      
      // Mesaj bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('message', data);
    });

    // 3. Okunmamış mesaj sayısı (toplam)
    _socket!.on('conversation:un_read_message_count', (data) {
      _unreadMessageCountController.add(data);
    });

    // Chat bazında unread count event'lerini dinle
    _socket!.on('conversation:unread_count', (data) {
      debugPrint('📨 Chat bazında unread count: $data');
      _handlePerChatUnreadCount(data);
    });

    // Pin/Unpin message events
    _socket!.on('group:message_pinned', (data) {
      _pinMessageController.add(data);
    });

    _socket!.on('group:unpin_message', (data) {
      _pinMessageController.add(data);
    });

    // 4. Yeni bildirim
    _socket!.on('notification:new', (data) {
      debugPrint('🔔 Yeni bildirim geldi (SocketService): $data');
      _notificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('notification', data);
    });

    // 5. Comment notification (global)
    _socket!.on('comment:event', (data) {
      debugPrint('💬 Comment event geldi (SocketService): $data');
      _commentNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('comment', data);
    });

    // 6. Like notification (global)
    _socket!.on('like:event', (data) {
      debugPrint('❤️ Like event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('like', data);
    });

    // 7. Follow notification (global)
    _socket!.on('follow:event', (data) {
      debugPrint('👥 Follow event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('follow', data);
    });

    // 8. Post notification (global)
    _socket!.on('post:event', (data) {
      debugPrint('📝 Post event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('post', data);
    });

    // 9. Group join request notification (global)
    _socket!.on('group:join_request', (data) {
      debugPrint('👥 Group join request event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('group_join_request', data);
    });

    // 10. Group join accepted notification (global)
    _socket!.on('group:join_accepted', (data) {
      debugPrint('✅ Group join accepted event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('group_join_accepted', data);
    });

    // 11. Group join declined notification (global)
    _socket!.on('group:join_declined', (data) {
      debugPrint('❌ Group join declined event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('group_join_declined', data);
    });

    // 12. Follow request notification (global)
    _socket!.on('follow:request', (data) {
      debugPrint('👤 Follow request event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('follow_request', data);
    });

    // 13. Follow accepted notification (global)
    _socket!.on('follow:accepted', (data) {
      debugPrint('✅ Follow accepted event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('follow_accepted', data);
    });

    // 14. Follow declined notification (global)
    _socket!.on('follow:declined', (data) {
      debugPrint('❌ Follow declined event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('follow_declined', data);
    });

    // 15. Event invitation notification (global)
    _socket!.on('event:invitation', (data) {
      debugPrint('📅 Event invitation event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('event_invitation', data);
    });

    // 21. User notification (user:{user_id} kanalı)
    _socket!.on('user:notification', (data) {
      debugPrint('👤 User notification geldi (SocketService): $data');
      
      // Çoklu bildirim kontrolü
      final notificationId = data['notification_data']?['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final notificationKey = 'user_notification_$notificationId';
      final now = DateTime.now();
      final lastNotification = _lastNotificationTime[notificationKey];
      
      if (lastNotification != null && 
          now.difference(lastNotification) < _notificationDebounce) {
        debugPrint('🚫 User notification debounced: $notificationKey');
        return;
      }
      
      _lastNotificationTime[notificationKey] = now;
      
      _userNotificationController.add(data);
      
      // Bildirim tipini belirle
      String notificationType = 'notification';
      if (data is Map<String, dynamic> && data.containsKey('notification_data')) {
        final notificationData = data['notification_data'] as Map<String, dynamic>?;
        final type = notificationData?['type']?.toString() ?? '';
        
        // Alt türe göre bildirim tipini belirle
        switch (type) {
          case 'post-like':
          case 'post-comment':
            notificationType = 'post';
            break;
          case 'follow-request':
          case 'follow-accepted':
          case 'follow-declined':
            notificationType = 'follow';
            break;
          case 'group-join-request':
          case 'group-join-accepted':
          case 'group-join-declined':
            notificationType = 'group';
            break;
          default:
            notificationType = 'notification';
        }
      }
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification(notificationType, data);
    });

    // 21.5. Group message notification (user:{user_id} kanalından)
    _socket!.on('user:group_message', (data) {
      debugPrint('👥 Group message notification geldi (SocketService): $data');
      _sendCustomGroupMessageNotification(data);
    });

    // 21.6. Group message (alternatif event isimleri)
    _socket!.on('group:message', (data) {
      debugPrint('👥 Group message event geldi (SocketService): $data');
      _groupMessageController.add(data);
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      _sendCustomGroupMessageNotification(data);
    });

    _socket!.on('group:chat_message', (data) {
      debugPrint('👥 Group chat message geldi (SocketService): $data');
      _groupMessageController.add(data);
      
      // Pin durumu kontrolü
      if (data is Map<String, dynamic> && data.containsKey('is_pinned')) {
        final messageId = data['id']?.toString();
        final isPinned = data['is_pinned'] ?? false;
        final groupId = data['group_id']?.toString();
        
        if (messageId != null && groupId != null) {
          final pinUpdateEvent = {
            'message_id': messageId,
            'group_id': groupId,
            'is_pinned': isPinned,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'source': 'group:chat_message',
            'message_data': data,
          };
          _pinMessageController.add(pinUpdateEvent);
        }
      }
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      _sendCustomGroupMessageNotification(data);
    });







    debugPrint('🔌 Socket bağlantısı başlatılıyor... ($urlName)');
    _socket!.connect();
    
    // Bağlantı durumunu kontrol et
    Future.delayed(Duration(seconds: 5), () {
      debugPrint('🔍 Socket bağlantı durumu kontrol ediliyor... ($urlName)');
    });
  }

  // Mesaj gönderme
  void sendMessage(String event, dynamic data) {
    debugPrint('📤 Mesaj gönderiliyor: $event');
    if (_socket != null && _socket!.connected) {
      _socket!.emit(event, data);
      debugPrint('✅ Mesaj gönderildi');
    } else {
      debugPrint('❌ Socket bağlı değil, mesaj gönderilemedi');
    }
  }

  /// Test için manuel event gönder
  void sendTestEvent(String eventName, Map<String, dynamic> data) {
    if (_socket != null && _socket!.connected) {
      debugPrint('🧪 Test event gönderiliyor: $eventName');
      _socket!.emit(eventName, data);
      debugPrint('✅ Test event gönderildi');
    } else {
      debugPrint('❌ Socket bağlı değil, test event gönderilemedi');
    }
  }

  // Socket durumunu kontrol etme
  void checkSocketStatus() {
    // Socket durumu kontrol edildi
  }

  /// User kanalına join ol
  void joinUserChannel(String userId) {
    if (_socket != null && _socket!.connected) {
      debugPrint('👤 User kanalına join olunuyor: user:$userId');
      
      // User kanalı
      _socket!.emit('join', {'channel': 'user:$userId'});
      _socket!.emit('subscribe', {'channel': 'user:$userId'});
      
      debugPrint('✅ User kanalına join istekleri gönderildi');
    } else {
      debugPrint('❌ Socket bağlı değil, user kanalına join olunamıyor');
    }
  }

  /// User kanalından ayrıl
  void leaveUserChannel(String userId) {
    if (_socket != null && _socket!.connected) {
      debugPrint('👤 User kanalından ayrılıyor: user:$userId');
      
      _socket!.emit('leave', {'channel': 'user:$userId'});
      _socket!.emit('unsubscribe', {'channel': 'user:$userId'});
      
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
      
      debugPrint('✅ User kanalına join istekleri gönderildi');
    } else {
      debugPrint('❌ Socket bağlı değil, user kanalına join olunamıyor');
    }
  }

  // Bağlantı kurulduktan sonra tüm kanallara join ol
  Future<void> _joinAllChannelsAfterConnection() async {
    try {
      debugPrint('🔔 _joinAllChannelsAfterConnection() başlatıldı');
      
      // Token'dan user ID'yi çıkar
      final token = GetStorage().read('token');
      
      if (token != null) {
        debugPrint('🔔 Bağlantı sonrası user kanalına join olunuyor...');
        
        // User kanalına join ol (user ID olmadan genel join)
        _socket!.emit('join', {'channel': 'user'});
        _socket!.emit('subscribe', {'channel': 'user'});
        
        debugPrint('✅ Bağlantı sonrası user kanalına join istekleri gönderildi');
        
        // Katıldığımız gruplara join ol
        debugPrint('👥 Gruplara join olma işlemi başlatılıyor...');
        await _joinUserGroups();
        debugPrint('👥 Gruplara join olma işlemi tamamlandı');
        
        // Unread count'u iste
        debugPrint('📨 Unread count isteği başlatılıyor...');
        _requestUnreadCount();
        debugPrint('📨 Unread count isteği tamamlandı');
      } else {
        debugPrint('❌ Token bulunamadı, join işlemleri yapılamıyor');
      }
    } catch (e) {
      debugPrint('❌ Bağlantı sonrası user kanalına join olma hatası: $e');
    }
  }

  /// Unread count'u iste
  void _requestUnreadCount() {
    if (_socket != null && _socket!.connected) {
      debugPrint('📨 Unread count isteniyor...');
      
      _socket!.emit('get:unread_count');
      _socket!.emit('conversation:get_unread_count');
      
      debugPrint('✅ Unread count istekleri gönderildi');
    } else {
      debugPrint('❌ Socket bağlı değil, unread count istenemiyor');
    }
  }

  // Stream Controller for per-chat unread counts
  final _perChatUnreadCountController = StreamController<dynamic>.broadcast();
  
  // Public stream for per-chat unread counts
  Stream<dynamic> get onPerChatUnreadCount => _perChatUnreadCountController.stream;

  /// Chat bazında unread count'ları handle et
  void _handlePerChatUnreadCount(dynamic data) {
    debugPrint('🔍 Chat bazında unread count işleniyor: $data');
    
    // Chat controller'a gönder
    _perChatUnreadCountController.add(data);
  }

  // Kullanıcının katıldığı gruplara join ol
  Future<void> _joinUserGroups() async {
    try {
      debugPrint('👥 Kullanıcının katıldığı gruplar alınıyor...');
      
      // Kullanıcının katıldığı grupları al
      final userGroups = await _groupServices.getUserGroups();
      
      if (userGroups != null && userGroups.isNotEmpty) {
        debugPrint('👥 ${userGroups.length} adet gruba join olunuyor...');
        
        for (final group in userGroups) {
          final groupId = group.id.toString();
          
          if (groupId.isNotEmpty) {
            // Gruba join ol
            _socket!.emit('group:join', {'group_id': groupId});
            debugPrint('✅ Gruba join isteği gönderildi: ${group.name}');
          }
        }
        
        debugPrint('✅ Tüm gruplara join istekleri gönderildi');
      } else {
        debugPrint('ℹ️ Kullanıcının katıldığı grup bulunamadı');
      }
    } catch (e) {
      debugPrint('❌ Gruplara join olma hatası: $e');
    }
  }

  // OneSignal bildirimi gönder (uygulama açıkken)
  void _sendOneSignalNotification(String type, dynamic data) async {
    try {
      // DEBOUNCE: Aynı mesaj için çoklu bildirim engelle
      final notificationKey = '${type}_${data['id'] ?? DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();
      final lastNotification = _lastNotificationTime[notificationKey];
      
      if (lastNotification != null && 
          now.difference(lastNotification) < _notificationDebounce) {
        debugPrint('🚫 Bildirim debounced: $notificationKey');
        return;
      }
      
      _lastNotificationTime[notificationKey] = now;
      
      String title = '';
      String message = '';
      String avatar = '';
      
      // Bildirim tipine göre başlık ve mesaj ayarla
      switch (type) {
        case 'message':
          title = 'Yeni Mesaj';
          // Private mesaj data yapısı: {message: "text", sender: {name: "...", avatar_url: "..."}}
          if (data is Map<String, dynamic> && data.containsKey('sender')) {
            final senderData = data['sender'] as Map<String, dynamic>?;
            final senderName = senderData?['name'] ?? 'Bilinmeyen';
            final messageText = data['message'] ?? 'Yeni bir mesajınız var';
            message = '$senderName: $messageText';
            avatar = senderData?['avatar_url'] ?? senderData?['profile_image'] ?? '';
          } else {
            message = data['message'] ?? 'Yeni bir mesajınız var';
            avatar = data['sender_avatar'] ?? data['profile_image'] ?? '';
          }
          break;
        case 'group':
          // Group mesaj data yapısı: {message: {message: "text", user: {name: "..."}}}
          if (data is Map<String, dynamic> && data.containsKey('message')) {
            final messageData = data['message'] as Map<String, dynamic>?;
            final userData = messageData?['user'] as Map<String, dynamic>?;
            final senderName = userData?['name'] ?? 'Bilinmeyen';
            final messageText = messageData?['message'] ?? 'Grup sohbetinde yeni mesaj';
            title = 'Grup Mesajı';
            message = '$senderName: $messageText';
            avatar = userData?['avatar_url'] ?? '';
          } else {
            title = 'Grup Mesajı';
            message = data['message'] ?? 'Grup sohbetinde yeni mesaj';
            avatar = data['group_avatar'] ?? '';
          }
          break;
        case 'notification':
          title = 'Yeni Bildirim';
          // Notification data yapısı: {notification_data: {notification_full_data: {user: {...}, post: {...}}, type: "post-like"}}
          if (data is Map<String, dynamic> && data.containsKey('notification_data')) {
            final notificationData = data['notification_data'] as Map<String, dynamic>?;
            final notificationFullData = notificationData?['notification_full_data'] as Map<String, dynamic>?;
            final notificationType = notificationData?['type']?.toString() ?? '';
            
            if (notificationFullData != null) {
              final userData = notificationFullData['user'] as Map<String, dynamic>?;
              final postData = notificationFullData['post'] as Map<String, dynamic>?;
              
              final userName = userData?['name'] ?? 'Bilinmeyen';
              final userAvatar = userData?['avatar_url'] ?? userData?['profile_image'] ?? '';
              
              // Bildirim tipine göre mesaj oluştur
              switch (notificationType) {
                case 'post-like':
                  final postContent = postData?['content'] ?? 'Post\'unuzu beğendi';
                  message = '$userName: $postContent';
                  title = 'Yeni Beğeni';
                  break;
                case 'post-comment':
                  final postContent = postData?['content'] ?? 'Post\'unuza yorum geldi';
                  message = '$userName: $postContent';
                  title = 'Yeni Yorum';
                  break;
                case 'follow-request':
                  message = '$userName sizi takip etmek istiyor';
                  title = 'Takip İsteği';
                  break;
                case 'group-join-request':
                  final groupData = notificationFullData['group'] as Map<String, dynamic>?;
                  final groupName = groupData?['name'] ?? 'Grup';
                  message = '$userName $groupName grubuna katılmak istiyor';
                  title = 'Grup Katılma İsteği';
                  break;
                default:
                  message = '$userName size bildirim gönderdi';
                  title = 'Yeni Bildirim';
              }
              
              avatar = userAvatar;
            } else {
              message = data['message'] ?? data['content'] ?? 'Yeni bir bildiriminiz var';
              avatar = data['user_avatar'] ?? data['profile_image'] ?? '';
            }
          } else {
            message = data['message'] ?? data['content'] ?? 'Yeni bir bildiriminiz var';
            avatar = data['user_avatar'] ?? data['profile_image'] ?? '';
          }
          break;
        case 'comment':
          title = 'Yeni Yorum';
          // Comment data yapısı: {user: {name: "...", avatar_url: "..."}, content: "..."}
          if (data is Map<String, dynamic> && data.containsKey('user')) {
            final userData = data['user'] as Map<String, dynamic>?;
            final userName = userData?['name'] ?? 'Bilinmeyen';
            final commentText = data['content'] ?? data['message'] ?? 'Post\'unuza yeni yorum geldi';
            message = '$userName: $commentText';
            avatar = userData?['avatar_url'] ?? userData?['profile_image'] ?? '';
          } else {
            message = data['message'] ?? data['content'] ?? 'Post\'unuza yeni yorum geldi';
            avatar = data['user_avatar'] ?? data['profile_image'] ?? '';
          }
          break;
        case 'like':
          title = 'Yeni Beğeni';
          // Like data yapısı: {user: {name: "...", avatar_url: "..."}, post: {content: "..."}}
          if (data is Map<String, dynamic> && data.containsKey('user')) {
            final userData = data['user'] as Map<String, dynamic>?;
            final userName = userData?['name'] ?? 'Bilinmeyen';
            final postContent = data['post']?['content'] ?? 'Post\'unuza yeni beğeni geldi';
            message = '$userName: $postContent';
            avatar = userData?['avatar_url'] ?? userData?['profile_image'] ?? '';
          } else {
            message = data['message'] ?? data['content'] ?? 'Post\'unuza yeni beğeni geldi';
            avatar = data['user_avatar'] ?? data['profile_image'] ?? '';
          }
          break;
        case 'follow':
          title = 'Yeni Takipçi';
          // Follow data yapısı: {user: {name: "...", avatar_url: "..."}}
          if (data is Map<String, dynamic> && data.containsKey('user')) {
            final userData = data['user'] as Map<String, dynamic>?;
            final userName = userData?['name'] ?? 'Bilinmeyen';
            message = '$userName sizi takip etmeye başladı';
            avatar = userData?['avatar_url'] ?? userData?['profile_image'] ?? '';
          } else {
            message = data['message'] ?? data['content'] ?? 'Yeni bir takipçiniz var';
            avatar = data['user_avatar'] ?? data['profile_image'] ?? '';
          }
          break;
        case 'post':
          title = 'Post Aktivitesi';
          message = data['message'] ?? data['content'] ?? 'Post\'unuzda yeni aktivite';
          avatar = data['user_avatar'] ?? data['profile_image'] ?? '';
          break;
        case 'group_join_request':
          title = 'Grup Katılma İsteği';
          // Group join request data yapısı: {user: {name: "...", avatar_url: "..."}, group: {name: "..."}}
          if (data is Map<String, dynamic> && data.containsKey('user')) {
            final userData = data['user'] as Map<String, dynamic>?;
            final groupData = data['group'] as Map<String, dynamic>?;
            final userName = userData?['name'] ?? 'Bilinmeyen';
            final groupName = groupData?['name'] ?? 'Grup';
            message = '$userName $groupName grubuna katılmak istiyor';
            avatar = userData?['avatar_url'] ?? userData?['profile_image'] ?? '';
          } else {
            message = data['message'] ?? data['content'] ?? 'Grup katılma isteği geldi';
            avatar = data['user_avatar'] ?? data['profile_image'] ?? '';
          }
          break;
        case 'group_join_accepted':
          title = 'Grup Katılma Kabul';
          message = data['message'] ?? data['content'] ?? 'Grup katılma isteğiniz kabul edildi';
          avatar = data['group_avatar'] ?? '';
          break;
        case 'group_join_declined':
          title = 'Grup Katılma Red';
          message = data['message'] ?? data['content'] ?? 'Grup katılma isteğiniz reddedildi';
          avatar = data['group_avatar'] ?? '';
          break;
        case 'follow_request':
          title = 'Takip İsteği';
          // Follow request data yapısı: {user: {name: "...", avatar_url: "..."}}
          if (data is Map<String, dynamic> && data.containsKey('user')) {
            final userData = data['user'] as Map<String, dynamic>?;
            final userName = userData?['name'] ?? 'Bilinmeyen';
            message = '$userName sizi takip etmek istiyor';
            avatar = userData?['avatar_url'] ?? userData?['profile_image'] ?? '';
          } else {
            message = data['message'] ?? data['content'] ?? 'Yeni takip isteği geldi';
            avatar = data['user_avatar'] ?? data['profile_image'] ?? '';
          }
          break;
        case 'follow_accepted':
          title = 'Takip Kabul';
          message = data['message'] ?? data['content'] ?? 'Takip isteğiniz kabul edildi';
          avatar = data['user_avatar'] ?? data['profile_image'] ?? '';
          break;
        case 'follow_declined':
          title = 'Takip Red';
          message = data['message'] ?? data['content'] ?? 'Takip isteğiniz reddedildi';
          avatar = data['user_avatar'] ?? data['profile_image'] ?? '';
          break;
        case 'event_invitation':
          title = 'Etkinlik Daveti';
          message = data['message'] ?? data['content'] ?? 'Yeni etkinlik daveti geldi';
          avatar = data['user_avatar'] ?? data['profile_image'] ?? '';
          break;
        default:
          title = 'Bildirim';
          message = data['message'] ?? data['content'] ?? 'Yeni bildirim';
          avatar = data['user_avatar'] ?? data['profile_image'] ?? '';
      }
      
      // Kendi mesajımız için bildirim gönderme kontrolü
      final currentUserId = GetStorage().read('user_id')?.toString() ?? '';
      if (data is Map<String, dynamic> && data.containsKey('user_id')) {
        final senderUserId = data['user_id']?.toString() ?? '';
        if (senderUserId == currentUserId) {
          debugPrint('🚫 Kendi mesajımız için bildirim gönderilmiyor. Sender: $senderUserId, Current: $currentUserId');
          return;
        }
      }
      
      // OneSignal bildirimi gönder
      _oneSignalService.sendCustomMessageNotification(
        senderName: title,
        message: message,
        senderAvatar: avatar,
        conversationId: data['conversation_id']?.toString() ?? data['group_id']?.toString() ?? '',
        data: data,
      );
    } catch (e) {
      debugPrint('❌ OneSignal bildirimi gönderilemedi: $e');
    }
  }
/*
  // Özel mesaj bildirimi gönder (profil resmi ve kullanıcı adı ile)
  void _sendCustomMessageNotification(dynamic data) {
    try {
      debugPrint('💬 Özel mesaj bildirimi hazırlanıyor...');
      
      // Mesaj verilerini al
      final message = data['message'] ?? '';
      final senderName = data['sender_name'] ?? data['sender'] ?? 'Bilinmeyen';
      final senderAvatar = data['sender_avatar'] ?? data['profile_image'] ?? '';
      final conversationId = data['conversation_id'];
      
      debugPrint('💬 Mesaj detayları: sender=$senderName, message=$message');
      
      // Özel bildirim gönder
      _oneSignalService.sendCustomMessageNotification(
        senderName: senderName,
        message: message,
        senderAvatar: senderAvatar,
        conversationId: conversationId,
        data: data,
      );
      
      debugPrint('✅ Özel mesaj bildirimi gönderildi');
    } catch (e) {
      debugPrint('❌ Özel mesaj bildirimi gönderilemedi: $e');
    }
  }*/

  // Özel grup mesaj bildirimi gönder (grup profil resmi, grup adı ve gönderen bilgisi ile)
  void _sendCustomGroupMessageNotification(dynamic data) async {
    try {
      // Group mesaj data yapısı: {message: {message: "text", user: {name: "...", avatar_url: "..."}}}
      final messageData = data['message'] as Map<String, dynamic>?;
      if (messageData == null) {
        return;
      }
      
      final userData = messageData['user'] as Map<String, dynamic>?;
      final messageText = messageData['message'] ?? '';
      final senderName = userData?['name'] ?? 'Bilinmeyen';
      final senderUserId = messageData['user_id']?.toString() ?? '';
      final groupId = messageData['group_id']?.toString() ?? '';
      
      // Kendi mesajımız için bildirim gönderme
      final currentUserId = GetStorage().read('user_id')?.toString() ?? '';
      if (senderUserId == currentUserId) {
        return;
      }
      
      // DEBOUNCE: Aynı mesaj için çoklu bildirim engelle
      final notificationKey = 'group_${groupId}_${messageData['id']}';
      final now = DateTime.now();
      final lastNotification = _lastNotificationTime[notificationKey];
      
      if (lastNotification != null && 
          now.difference(lastNotification) < _notificationDebounce) {
        return;
      }
      
      _lastNotificationTime[notificationKey] = now;
      
      // Grup bilgilerini al
      String groupName = 'Grup';
      String groupAvatar = '';
      
      try {
        final groupDetail = await _groupServices.fetchGroupDetail(groupId);
        groupName = groupDetail.name;
        groupAvatar = groupDetail.avatarUrl ?? '';
      } catch (e) {
        // Grup bilgileri alınamadı, varsayılan değerler kullanılacak
      }
      
      // Bildirim içeriğini hazırla: "Gönderen Adı: Mesaj"
      final notificationMessage = '$senderName: $messageText';
      
      // Özel grup bildirimi gönder
      _oneSignalService.sendLocalNotification(
        groupName, // Grup adı
        notificationMessage, // "Gönderen: Mesaj" formatı
        {
          'type': 'group', // Group tipi olarak işaretle
          'group_id': groupId,
          'group_name': groupName, // Grup adını da ekle
          'sender_name': senderName,
          'message': messageText,
          'group_avatar': groupAvatar,
        },
      );
    } catch (e) {
      debugPrint('❌ Özel grup mesaj bildirimi gönderilemedi: $e');
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
    _socket?.clearListeners();
  }

  @override
  void onClose() {
    _privateMessageController.close();
    _groupMessageController.close();
    _unreadMessageCountController.close();
    _perChatUnreadCountController.close();
    _notificationController.close();
    _postNotificationController.close();
    _userNotificationController.close();
    _commentNotificationController.close();
    _pinMessageController.close();
    disconnect();
    super.onClose();
  }

  /// Socket nesnesi
  io.Socket? get socket => _socket;

  /// Uygulama başlatıldığında socket durumunu kontrol et
  void checkInitialSocketStatus() {
    // Socket durumu kontrol edildi
  }

}
