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
      debugPrint('💬 Data type: ${data.runtimeType}');
      debugPrint('💬 Data keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
      
      // CONVERSATION alanını detaylı incele
      if (data is Map<String, dynamic>) {
        debugPrint('💬 === CONVERSATION NEW MESSAGE DETAYLI ANALİZ ===');
        debugPrint('💬 Message: ${data['message']}');
        debugPrint('💬 Conversation ID: ${data['conversation_id']}');
        debugPrint('💬 Sender ID: ${data['sender_id']}');
        debugPrint('💬 Is Me: ${data['is_me']}');
        debugPrint('💬 Is Read: ${data['is_read']}');
        debugPrint('💬 Created At: ${data['created_at']}');
        
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
          debugPrint('💬 📁 CONVERSATION ALANı VAR: ${conversation.runtimeType}');
          debugPrint('💬 📁 Conversation data: $conversation');
          
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
        
        debugPrint('💬 === ANALİZ TAMAMLANDI ===');
      }
      
      _privateMessageController.add(data);
      
      // Mesaj bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('message', data);
      debugPrint('💬 Bildirim gönderme tamamlandı');
    });

    // 3. Okunmamış mesaj sayısı (toplam)
    _socket!.on('conversation:un_read_message_count', (data) {
      debugPrint('📨 Okunmamış mesaj sayısı (SocketService): $data');
      debugPrint('📨 Data type: ${data.runtimeType}');
      debugPrint('📨 Data keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
      
      if (data is Map<String, dynamic>) {
        debugPrint('📨 === TOPLAM UNREAD COUNT DETAYI ===');
        debugPrint('📨 Count: ${data['count']}');
        debugPrint('📨 Total: ${data['total']}');
        debugPrint('📨 Unread: ${data['unread']}');
        debugPrint('📨 Message Count: ${data['message_count']}');
        debugPrint('📨 Conversation Count: ${data['conversation_count']}');
        debugPrint('📨 ================================');
      }
      
      _unreadMessageCountController.add(data);
    });

    // Chat bazında unread count event'lerini dinle
    _socket!.on('conversation:unread_count', (data) {
      debugPrint('📨 Chat bazında unread count (conversation:unread_count): $data');
      _handlePerChatUnreadCount(data);
    });

    _socket!.on('chat:unread_count', (data) {
      debugPrint('📨 Chat bazında unread count (chat:unread_count): $data');
      _handlePerChatUnreadCount(data);
    });

    _socket!.on('conversation:unread', (data) {
      debugPrint('📨 Chat bazında unread count (conversation:unread): $data');
      _handlePerChatUnreadCount(data);
    });

    _socket!.on('chat:unread', (data) {
      debugPrint('📨 Chat bazında unread count (chat:unread): $data');
      _handlePerChatUnreadCount(data);
    });

    _socket!.on('user:conversation_unread', (data) {
      debugPrint('📨 Chat bazında unread count (user:conversation_unread): $data');
      _handlePerChatUnreadCount(data);
    });

    _socket!.on('unread:conversation', (data) {
      debugPrint('📨 Chat bazında unread count (unread:conversation): $data');
      _handlePerChatUnreadCount(data);
    });

    _socket!.on('conversation:count', (data) {
      debugPrint('📨 Chat bazında unread count (conversation:count): $data');
      _handlePerChatUnreadCount(data);
    });

    // 4. Yeni bildirim
    _socket!.on('notification:new', (data) {
      debugPrint('🔔 Yeni bildirim geldi (SocketService): $data');
      debugPrint('🔔 Notification data type: ${data.runtimeType}');
      debugPrint('🔔 Notification data keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
      _notificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('notification', data);
    });

    // 5. Notification event (private chat'teki gibi global)
    _socket!.on('notification:event', (data) {
      debugPrint('🔔 Notification event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('notification', data);
    });

    // 6. Comment notification (global)
    _socket!.on('comment:event', (data) {
      debugPrint('💬 Comment event geldi (SocketService): $data');
      debugPrint('💬 Comment event data type: ${data.runtimeType}');
      debugPrint('💬 Comment event keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
      _commentNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('comment', data);
    });

    // 7. Like notification (global)
    _socket!.on('like:event', (data) {
      debugPrint('❤️ Like event geldi (SocketService): $data');
      debugPrint('❤️ Like event data type: ${data.runtimeType}');
      debugPrint('❤️ Like event keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('like', data);
    });

    // 8. Follow notification (global)
    _socket!.on('follow:event', (data) {
      debugPrint('👥 Follow event geldi (SocketService): $data');
      debugPrint('👥 Follow event data type: ${data.runtimeType}');
      debugPrint('👥 Follow event keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('follow', data);
    });

    // 9. Post notification (global)
    _socket!.on('post:event', (data) {
      debugPrint('📝 Post event geldi (SocketService): $data');
      debugPrint('📝 Post event data type: ${data.runtimeType}');
      debugPrint('📝 Post event keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('post', data);
    });

    // 10. Group join request notification (global)
    _socket!.on('group:join_request', (data) {
      debugPrint('👥 Group join request event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('group_join_request', data);
    });

    // 11. Group join accepted notification (global)
    _socket!.on('group:join_accepted', (data) {
      debugPrint('✅ Group join accepted event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('group_join_accepted', data);
    });

    // 12. Group join declined notification (global)
    _socket!.on('group:join_declined', (data) {
      debugPrint('❌ Group join declined event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('group_join_declined', data);
    });

    // 13. Follow request notification (global)
    _socket!.on('follow:request', (data) {
      debugPrint('👤 Follow request event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('follow_request', data);
    });

    // 14. Follow accepted notification (global)
    _socket!.on('follow:accepted', (data) {
      debugPrint('✅ Follow accepted event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('follow_accepted', data);
    });

    // 15. Follow declined notification (global)
    _socket!.on('follow:declined', (data) {
      debugPrint('❌ Follow declined event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('follow_declined', data);
    });

    // 16. Event invitation notification (global)
    _socket!.on('event:invitation', (data) {
      debugPrint('📅 Event invitation event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi gönder (uygulama açıkken)
      _sendOneSignalNotification('event_invitation', data);
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
      printFullText('👤 =======================================');
      printFullText('👤 User notification geldi (SocketService): $data');
      printFullText('👤 User notification data type: ${data.runtimeType}');
      printFullText('👤 User notification data keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
      
      // is_read alanını kontrol et ve logla
      if (data is Map && data.containsKey('notification_data')) {
        final notificationData = data['notification_data'];
        if (notificationData is Map && notificationData.containsKey('is_read')) {
          final isRead = notificationData['is_read'];
          printFullText('👤 🔍 SocketService - is_read değeri: $isRead (Type: ${isRead.runtimeType})');
          
          if (isRead == true) {
            printFullText('👤 ✅ SocketService - Bildirim zaten okunmuş');
          } else {
            printFullText('👤 🔴 SocketService - Bildirim okunmamış');
          }
        } else {
          printFullText('👤 ⚠️ SocketService - notification_data içinde is_read alanı bulunamadı');
        }
      } else {
        printFullText('👤 ⚠️ SocketService - notification_data alanı bulunamadı');
      }
      

      
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
      debugPrint('👤 OneSignal bildirimi gönderiliyor... Tip: $notificationType');
      _sendOneSignalNotification(notificationType, data);
      debugPrint('👤 OneSignal bildirimi gönderme tamamlandı');
      debugPrint('👤 =======================================');
    });

    // 21.5. Group message notification (user:{user_id} kanalından)
    _socket!.on('user:group_message', (data) {
      printFullText('👥 Group message notification geldi (SocketService): $data');
      printFullText('👥 Data type: ${data.runtimeType}');
      printFullText('👥 Data keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
      
      if (data is Map<String, dynamic>) {
        printFullText('👥 === GROUP MESSAGE DETAYLI ANALİZ ===');
        
        // Grup ID'sini doğru yerden al
        dynamic groupId = data['group_id'];
        if (data.containsKey('message') && data['message'] is Map<String, dynamic>) {
          final messageData = data['message'] as Map<String, dynamic>;
          groupId = messageData['group_id'] ?? data['group_id'];
        }
        printFullText('👥 Group ID: $groupId');
        
        printFullText('👥 Message: ${data['message']}');
        printFullText('👥 Sender ID: ${data['sender_id']}');
        printFullText('👥 Is Me: ${data['is_me']}');
        printFullText('👥 Is Read: ${data['is_read']}');
        printFullText('👥 Created At: ${data['created_at']}');
        printFullText('👥 Message ID: ${data['id']}');
        
        // Message alanını kontrol et
        if (data.containsKey('message') && data['message'] is Map<String, dynamic>) {
          final messageData = data['message'] as Map<String, dynamic>;
          printFullText('👥 📝 MESSAGE ALANı VAR: ${messageData.runtimeType}');
          printFullText('👥 📝 Message data: $messageData');
          printFullText('👥 📝 Message keys: ${messageData.keys.toList()}');
          printFullText('👥 📝 Message text: ${messageData['message']}');
          printFullText('👥 📝 Message is_read: ${messageData['is_read']}');
          printFullText('👥 📝 Message is_me: ${messageData['is_me']}');
        }
        
        // User alanını kontrol et
        if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
          final userData = data['user'] as Map<String, dynamic>;
          printFullText('👥 👤 USER ALANı VAR: ${userData.runtimeType}');
          printFullText('👥 👤 User keys: ${userData.keys.toList()}');
          printFullText('👥 👤 User name: ${userData['name']}');
          printFullText('👥 👤 User ID: ${userData['id']}');
        }
        
        printFullText('👥 === ANALİZ TAMAMLANDI ===');
      }
      
      debugPrint('📡 [SocketService] user:group_message - _groupMessageController.add() çağrılıyor');
      _groupMessageController.add(data);
      debugPrint('📡 [SocketService] user:group_message - _groupMessageController.add() tamamlandı');
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    // 21.6. Group message (alternatif event isimleri)
    _socket!.on('group:message', (data) {
      printFullText('👥 Group message event geldi (SocketService): $data');
      printFullText('👥 Data type: ${data.runtimeType}');
      printFullText('👥 Data keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
      
      if (data is Map<String, dynamic>) {
        printFullText('👥 === GROUP MESSAGE EVENT DETAYLI ANALİZ ===');
        
        // Grup ID'sini doğru yerden al
        dynamic groupId = data['group_id'];
        if (data.containsKey('message') && data['message'] is Map<String, dynamic>) {
          final messageData = data['message'] as Map<String, dynamic>;
          groupId = messageData['group_id'] ?? data['group_id'];
        }
        printFullText('👥 Group ID: $groupId');
        
        printFullText('👥 Message: ${data['message']}');
        printFullText('👥 Sender ID: ${data['sender_id']}');
        printFullText('👥 Is Me: ${data['is_me']}');
        printFullText('👥 Is Read: ${data['is_read']}');
        printFullText('👥 Created At: ${data['created_at']}');
        printFullText('👥 Message ID: ${data['id']}');
        
        // Message alanını kontrol et
        if (data.containsKey('message') && data['message'] is Map<String, dynamic>) {
          final messageData = data['message'] as Map<String, dynamic>;
          printFullText('👥 📝 MESSAGE ALANı VAR: ${messageData.runtimeType}');
          printFullText('👥 📝 Message data: $messageData');
          printFullText('👥 📝 Message keys: ${messageData.keys.toList()}');
          printFullText('👥 📝 Message text: ${messageData['message']}');
          printFullText('👥 📝 Message is_read: ${messageData['is_read']}');
          printFullText('👥 📝 Message is_me: ${messageData['is_me']}');
        }
        
        // User alanını kontrol et
        if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
          final userData = data['user'] as Map<String, dynamic>;
          printFullText('👥 👤 USER ALANı VAR: ${userData.runtimeType}');
          printFullText('👥 👤 User keys: ${userData.keys.toList()}');
          printFullText('👥 👤 User name: ${userData['name']}');
          printFullText('👥 👤 User ID: ${userData['id']}');
        }
        
        printFullText('👥 === ANALİZ TAMAMLANDI ===');
      }
      
      debugPrint('📡 [SocketService] group:message - _groupMessageController.add() çağrılıyor');
      _groupMessageController.add(data);
      debugPrint('📡 [SocketService] group:message - _groupMessageController.add() tamamlandı');
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('group_conversation:new_message', (data) {
      debugPrint('👥 Group conversation new message geldi (SocketService): $data');
      debugPrint('📡 [SocketService] group_conversation:new_message - _groupMessageController.add() çağrılıyor');
      _groupMessageController.add(data);
      debugPrint('📡 [SocketService] group_conversation:new_message - _groupMessageController.add() tamamlandı');
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('conversation:group_message', (data) {
      debugPrint('👥 Conversation group message geldi (SocketService): $data');
      debugPrint('📡 [SocketService] conversation:group_message - _groupMessageController.add() çağrılıyor');
      _groupMessageController.add(data);
      debugPrint('📡 [SocketService] conversation:group_message - _groupMessageController.add() tamamlandı');
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    // 21.7. Ek grup mesaj event'leri (backend'de farklı isimler kullanılıyor olabilir)
    _socket!.on('group:new_message', (data) {
      printFullText('👥 Group new message geldi (SocketService): $data');
      printFullText('👥 Data type: ${data.runtimeType}');
      printFullText('👥 Data keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
      
      if (data is Map<String, dynamic>) {
        printFullText('👥 === GROUP NEW MESSAGE DETAYLI ANALİZ ===');
        printFullText('👥 Group ID: ${data['group_id']}');
        printFullText('👥 Message: ${data['message']}');
        printFullText('👥 Sender ID: ${data['sender_id']}');
        printFullText('👥 Is Me: ${data['is_me']}');
        printFullText('👥 Is Read: ${data['is_read']}');
        printFullText('👥 Created At: ${data['created_at']}');
        printFullText('👥 Message ID: ${data['id']}');
        
        // Message alanını kontrol et
        if (data.containsKey('message') && data['message'] is Map<String, dynamic>) {
          final messageData = data['message'] as Map<String, dynamic>;
          printFullText('👥 📝 MESSAGE ALANı VAR: ${messageData.runtimeType}');
          printFullText('👥 📝 Message data: $messageData');
          printFullText('👥 📝 Message keys: ${messageData.keys.toList()}');
          printFullText('👥 📝 Message text: ${messageData['message']}');
          printFullText('👥 📝 Message is_read: ${messageData['is_read']}');
          printFullText('👥 📝 Message is_me: ${messageData['is_me']}');
        }
        
        // User alanını kontrol et
        if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
          final userData = data['user'] as Map<String, dynamic>;
          printFullText('👥 👤 USER ALANı VAR: ${userData.runtimeType}');
          printFullText('👥 👤 User keys: ${userData.keys.toList()}');
          printFullText('👥 👤 User name: ${userData['name']}');
          printFullText('👥 👤 User ID: ${userData['id']}');
        }
        
        printFullText('👥 === ANALİZ TAMAMLANDI ===');
      }
      
      debugPrint('📡 [SocketService] group:new_message - _groupMessageController.add() çağrılıyor');
      _groupMessageController.add(data);
      debugPrint('📡 [SocketService] group:new_message - _groupMessageController.add() tamamlandı');
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('group_chat:message', (data) {
      debugPrint('👥 Group chat message geldi (SocketService): $data');
      debugPrint('📡 [SocketService] group_chat:message - _groupMessageController.add() çağrılıyor');
      _groupMessageController.add(data);
      debugPrint('📡 [SocketService] group_chat:message - _groupMessageController.add() tamamlandı');
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('group_chat:new_message', (data) {
      debugPrint('👥 Group chat new message geldi (SocketService): $data');
      debugPrint('📡 [SocketService] group_chat:new_message - _groupMessageController.add() çağrılıyor');
      _groupMessageController.add(data);
      debugPrint('📡 [SocketService] group_chat:new_message - _groupMessageController.add() tamamlandı');
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('chat:group_message', (data) {
      debugPrint('👥 Chat group message geldi (SocketService): $data');
      debugPrint('📡 [SocketService] chat:group_message - _groupMessageController.add() çağrılıyor');
      _groupMessageController.add(data);
      debugPrint('📡 [SocketService] chat:group_message - _groupMessageController.add() tamamlandı');
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('message:group', (data) {
      debugPrint('👥 Message group geldi (SocketService): $data');
      debugPrint('📡 [SocketService] message:group - _groupMessageController.add() çağrılıyor');
      _groupMessageController.add(data);
      debugPrint('📡 [SocketService] message:group - _groupMessageController.add() tamamlandı');
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('new:group_message', (data) {
      debugPrint('👥 New group message geldi (SocketService): $data');
      debugPrint('📡 [SocketService] new:group_message - _groupMessageController.add() çağrılıyor');
      _groupMessageController.add(data);
      debugPrint('📡 [SocketService] new:group_message - _groupMessageController.add() tamamlandı');
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('group:chat_message', (data) {
      debugPrint('👥 Group chat message geldi (SocketService): $data');
      debugPrint('📡 [SocketService] group:chat_message - _groupMessageController.add() çağrılıyor');
      _groupMessageController.add(data);
      debugPrint('📡 [SocketService] group:chat_message - _groupMessageController.add() tamamlandı');
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('user:group_chat', (data) {
      debugPrint('👥 User group chat geldi (SocketService): $data');
      debugPrint('📡 [SocketService] user:group_chat - _groupMessageController.add() çağrılıyor');
      _groupMessageController.add(data);
      debugPrint('📡 [SocketService] user:group_chat - _groupMessageController.add() tamamlandı');
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('user:group_chat_message', (data) {
      debugPrint('👥 User group chat message geldi (SocketService): $data');
      debugPrint('📡 [SocketService] user:group_chat_message - _groupMessageController.add() çağrılıyor');
      _groupMessageController.add(data);
      debugPrint('📡 [SocketService] user:group_chat_message - _groupMessageController.add() tamamlandı');
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    // 21.8. User kanalında grup mesajları için ek olası event'ler
    _socket!.on('user:new_group_message', (data) {
      debugPrint('👥 User new group message geldi (SocketService): $data');
      _groupMessageController.add(data);
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('user:chat_message', (data) {
      debugPrint('👥 User chat message geldi (SocketService): $data');
      _groupMessageController.add(data);
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('user:message_group', (data) {
      debugPrint('👥 User message group geldi (SocketService): $data');
      _groupMessageController.add(data);
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('user:group_message_new', (data) {
      debugPrint('👥 User group message new geldi (SocketService): $data');
      _groupMessageController.add(data);
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('user:new_message', (data) {
      debugPrint('👥 User new message geldi (SocketService): $data');
      _groupMessageController.add(data);
      _sendOneSignalNotification('group', data);
    });

    _socket!.on('user:message_new', (data) {
      debugPrint('👥 User message new geldi (SocketService): $data');
      _groupMessageController.add(data);
      _sendOneSignalNotification('group', data);
    });

    _socket!.on('user:chat', (data) {
      debugPrint('👥 User chat geldi (SocketService): $data');
      _groupMessageController.add(data);
      _sendOneSignalNotification('group', data);
    });

    _socket!.on('user:group', (data) {
      debugPrint('👥 User group geldi (SocketService): $data');
      _groupMessageController.add(data);
      _sendOneSignalNotification('group', data);
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
      //debugPrint('🎯 === SOCKET EVENT YAKALANDI ===');
      //debugPrint('🎯 Event: $event');
      //debugPrint('🎯 Data: $data');
      //debugPrint('🎯 Data Type: ${data.runtimeType}');
      
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
        if (data.containsKey('group_id')) {
          debugPrint('🎯 Group ID: ${data['group_id']}');
        }
        if (data.containsKey('conversation_id')) {
          debugPrint('🎯 Conversation ID: ${data['conversation_id']}');
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

    // 39. User kanalından gelen tüm verileri detaylı logla
    _socket!.on('user:*', (data) {
      debugPrint('👤 === USER KANALI DETAYLI LOG ===');
      debugPrint('👤 Event: user:*');
      debugPrint('👤 Raw Data: $data');
      debugPrint('👤 Data Type: ${data.runtimeType}');
      
      if (data is Map<String, dynamic>) {
        debugPrint('👤 === DATA ANALİZİ ===');
        debugPrint('👤 Tüm Keys: ${data.keys.toList()}');
        
        // Her key'i detaylı incele
        data.forEach((key, value) {
          debugPrint('👤 $key: $value (${value.runtimeType})');
        });
        
        // Özel alanları kontrol et
        if (data.containsKey('type')) {
          debugPrint('👤 📝 Event Type: ${data['type']}');
        }
        if (data.containsKey('message')) {
          debugPrint('👤 💬 Message: ${data['message']}');
        }
        if (data.containsKey('user_id')) {
          debugPrint('👤 👤 User ID: ${data['user_id']}');
        }
        if (data.containsKey('group_id')) {
          debugPrint('👤 👥 Group ID: ${data['group_id']}');
        }
        if (data.containsKey('conversation_id')) {
          debugPrint('👤 💭 Conversation ID: ${data['conversation_id']}');
        }
        if (data.containsKey('sender')) {
          debugPrint('👤 👤 Sender: ${data['sender']}');
        }
        if (data.containsKey('receiver')) {
          debugPrint('👤 👤 Receiver: ${data['receiver']}');
        }
        if (data.containsKey('created_at')) {
          debugPrint('👤 ⏰ Created At: ${data['created_at']}');
        }
        if (data.containsKey('updated_at')) {
          debugPrint('👤 ⏰ Updated At: ${data['updated_at']}');
        }
        if (data.containsKey('is_read')) {
          debugPrint('👤 ✅ Is Read: ${data['is_read']}');
        }
        if (data.containsKey('media')) {
          debugPrint('👤 📁 Media: ${data['media']}');
        }
        if (data.containsKey('links')) {
          debugPrint('👤 🔗 Links: ${data['links']}');
        }
        if (data.containsKey('poll_options')) {
          debugPrint('👤 📊 Poll Options: ${data['poll_options']}');
        }
      }
      
      debugPrint('👤 ================================');
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
    /*debugPrint('🔍 === SOCKET DURUM RAPORU ===');
    debugPrint('🔍 Socket nesnesi: ${_socket != null ? "✅ Var" : "❌ Yok"}');
    debugPrint('🔍 Bağlantı durumu: ${_socket?.connected ?? false ? "✅ Bağlı" : "❌ Bağlı değil"}');
    debugPrint('🔍 Socket ID: ${_socket?.id ?? "Yok"}');
    debugPrint('🔍 isConnected observable: ${isConnected.value}');
    debugPrint('🔍 Dinlenen event\'ler:');
    debugPrint('  - conversation:new_message (private mesajlar için)');
    debugPrint('  - user:group_message (group mesajlar için)');
    debugPrint('  - group:message (group mesajlar için)');
    debugPrint('  - group_conversation:new_message (group mesajlar için)');
    debugPrint('  - conversation:group_message (group mesajlar için)');
    debugPrint('  - group:new_message (group mesajlar için)');
    debugPrint('  - group_chat:message (group mesajlar için)');
    debugPrint('  - group_chat:new_message (group mesajlar için)');
    debugPrint('  - chat:group_message (group mesajlar için)');
    debugPrint('  - message:group (group mesajlar için)');
    debugPrint('  - new:group_message (group mesajlar için)');
    debugPrint('  - group:chat_message (group mesajlar için)');
    debugPrint('  - user:group_chat (group mesajlar için)');
    debugPrint('  - user:group_chat_message (group mesajlar için)');
    debugPrint('  - user:new_group_message (group mesajlar için)');
    debugPrint('  - user:chat_message (group mesajlar için)');
    debugPrint('  - user:message_group (group mesajlar için)');
    debugPrint('  - user:group_message_new (group mesajlar için)');
    debugPrint('  - user:new_message (group mesajlar için)');
    debugPrint('  - user:message_new (group mesajlar için)');
    debugPrint('  - user:chat (group mesajlar için)');
    debugPrint('  - user:group (group mesajlar için)');
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
    debugPrint('🔍 ===========================');*/
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

  // Bağlantı kurulduktan sonra tüm kanallara join ol
  Future<void> _joinAllChannelsAfterConnection() async {
    try {
      debugPrint('🔔 _joinAllChannelsAfterConnection() başlatıldı');
      
      // Token'dan user ID'yi çıkar
      final token = GetStorage().read('token');
      debugPrint('🔔 Token var mı: ${token != null}');
      
      if (token != null) {
        debugPrint('🔔 Bağlantı sonrası user kanalına join olunuyor...');
        debugPrint('🔔 Socket bağlı mı: ${_socket?.connected}');
        debugPrint('🔔 Socket ID: ${_socket?.id}');
        
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
      debugPrint('❌ Hata detayı: ${e.toString()}');
    }
  }

  /// Unread count'u iste
  void _requestUnreadCount() {
    if (_socket != null && _socket!.connected) {
      debugPrint('📨 Unread count isteniyor...');
      
      // Farklı event isimlerini dene
      _socket!.emit('get:unread_count');
      _socket!.emit('request:unread_count');
      _socket!.emit('unread:count');
      _socket!.emit('conversation:get_unread_count');
      _socket!.emit('chat:unread_count');
      _socket!.emit('get:conversation_unread_counts');
      _socket!.emit('request:per_chat_unread');
      
      // Chat bazında unread count için yeni event'ler
      _socket!.emit('get:conversation_unread_details');
      _socket!.emit('request:unread_by_conversation');
      _socket!.emit('conversation:get_unread_details');
      _socket!.emit('chat:get_unread_details');
      
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
    debugPrint('🔍 Data type: ${data.runtimeType}');
    debugPrint('🔍 Data keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
    
    if (data is Map<String, dynamic>) {
      debugPrint('🔍 === PER CHAT UNREAD COUNT DETAYI ===');
      debugPrint('🔍 Conversation ID: ${data['conversation_id']}');
      debugPrint('🔍 Chat ID: ${data['chat_id']}');
      debugPrint('🔍 User ID: ${data['user_id']}');
      debugPrint('🔍 Unread Count: ${data['unread_count']}');
      debugPrint('🔍 Count: ${data['count']}');
      debugPrint('🔍 Message Count: ${data['message_count']}');
      debugPrint('🔍 Is Read: ${data['is_read']}');
      debugPrint('🔍 ====================================');
    }
    
    // Chat controller'a gönder
    _perChatUnreadCountController.add(data);
  }

  // Kullanıcının katıldığı gruplara join ol
  Future<void> _joinUserGroups() async {
    try {
      debugPrint('👥 Kullanıcının katıldığı gruplar alınıyor...');
      
      // Kullanıcının katıldığı grupları al
      final userGroups = await _groupServices.getUserGroups();
      
      debugPrint('👥 getUserGroups() sonucu: ${userGroups?.length ?? 0} grup');
      debugPrint('👥 getUserGroups() null mu: ${userGroups == null}');
      debugPrint('👥 getUserGroups() boş mu: ${userGroups?.isEmpty ?? true}');
      
      if (userGroups != null && userGroups.isNotEmpty) {
        debugPrint('👥 ${userGroups.length} adet gruba join olunuyor...');
        
        for (final group in userGroups) {
          final groupId = group.id.toString();
          debugPrint('👥 Grup detayı: ${group.name} (ID: $groupId)');
          
          if (groupId.isNotEmpty) {
            debugPrint('👥 Gruba join olunuyor: ${group.name} (ID: $groupId)');
            
            // Gruba join ol
            _socket!.emit('group:join', {'group_id': groupId});
            
            debugPrint('✅ Gruba join isteği gönderildi: ${group.name}');
          } else {
            debugPrint('⚠️ Boş grup ID: ${group.name}');
          }
        }
        
        debugPrint('✅ Tüm gruplara join istekleri gönderildi');
      } else {
        debugPrint('ℹ️ Kullanıcının katıldığı grup bulunamadı');
        debugPrint('ℹ️ userGroups null: ${userGroups == null}');
        debugPrint('ℹ️ userGroups empty: ${userGroups?.isEmpty ?? true}');
      }
    } catch (e) {
      debugPrint('❌ Gruplara join olma hatası: $e');
      debugPrint('❌ Hata detayı: ${e.toString()}');
    }
  }

  // OneSignal bildirimi gönder (uygulama açıkken)
  void _sendOneSignalNotification(String type, dynamic data) async {
    try {
      debugPrint('📱 =======================================');
      debugPrint('📱 OneSignal bildirimi gönderiliyor...');
      debugPrint('📱 Tip: $type');
      debugPrint('📱 Data: $data');
      debugPrint('📱 Data Type: ${data.runtimeType}');
      debugPrint('📱 Data Keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
      
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
      
      debugPrint('✅ OneSignal bildirimi gönderildi');
      debugPrint('📱 Bildirim detayları: title=$title, message=$message, avatar=$avatar');
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
      debugPrint('👥 Özel grup mesaj bildirimi hazırlanıyor...');
      
      // Group mesaj data yapısı: {message: {message: "text", user: {name: "...", avatar_url: "..."}}}
      final messageData = data['message'] as Map<String, dynamic>?;
      if (messageData == null) {
        debugPrint('❌ Group message data is null');
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
        debugPrint('🚫 Kendi mesajımız için bildirim gönderilmiyor. Sender: $senderUserId, Current: $currentUserId');
        return;
      }
      
      debugPrint('👥 Group mesaj detayları: sender=$senderName, message=$messageText, groupId=$groupId, senderUserId=$senderUserId');
      
      // DEBOUNCE: Aynı mesaj için çoklu bildirim engelle
      final notificationKey = 'group_${groupId}_${messageData['id']}';
      final now = DateTime.now();
      final lastNotification = _lastNotificationTime[notificationKey];
      
      if (lastNotification != null && 
          now.difference(lastNotification) < _notificationDebounce) {
        debugPrint('🚫 Group mesaj bildirimi debounced: $notificationKey');
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
        debugPrint('👥 Grup bilgileri alındı: name=$groupName, avatar=$groupAvatar');
      } catch (e) {
        debugPrint('⚠️ Grup bilgileri alınamadı: $e');
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
      
      debugPrint('✅ Özel grup mesaj bildirimi gönderildi');
      debugPrint('📱 Bildirim detayları: title=$groupName, message=$notificationMessage, avatar=$groupAvatar');
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
    debugPrint('🔌 Socket dinleyicileri temizleniyor...');
    _socket?.clearListeners();
    debugPrint('✅ Socket dinleyicileri temizlendi');
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
    disconnect();
    super.onClose();
  }

  /// Socket nesnesi
  io.Socket? get socket => _socket;

  /// Uygulama başlatıldığında socket durumunu kontrol et
  void checkInitialSocketStatus() {
    //debugPrint('🚀 === UYGULAMA BAŞLATILDI - SOCKET DURUMU ===');
    //debugPrint('🚀 Socket Bağlantı Durumu: ${isConnected.value}');
    //debugPrint('🚀 Socket ID: ${_socket?.id}');
    //debugPrint('🚀 Socket Connected: ${_socket?.connected}');
    //debugPrint('🚀 Socket URL: $_socketUrl');
    //debugPrint('🚀 ===========================================');
    
    // User kanalından gelen tüm event'leri dinlemeye başla
    //debugPrint('👤 User kanalından gelen tüm event\'ler dinleniyor...');
    //  debugPrint('👤 Beklenen event\'ler:');
    //debugPrint('👤  - user:notification');
    //debugPrint('👤  - user:group_message');
    //debugPrint('👤  - user:message');
    //debugPrint('👤  - user:* (wildcard)');
    //debugPrint('👤  - Tüm diğer event\'ler');
    //debugPrint('👤 ===========================================');
  }
}
