import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'onesignal_service.dart';
import 'package:get_storage/get_storage.dart';
import 'group_services/group_service.dart';
import '../components/print_full_text.dart';
import '../controllers/chat_controllers/chat_controller.dart';

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
  
  // JOIN DEBOUNCE: Çoklu join işlemlerini engellemek için
  bool _isJoiningChannels = false;
  DateTime? _lastJoinTime;
  static const Duration _joinDebounce = Duration(seconds: 5);

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

  // Bağlantı adresi
  static const String _socketUrl = 'https://stage.edusocial.pl';

  // Socket başlat
  void connect(String jwtToken) {
    debugPrint('🔌 SocketService.connect() çağrıldı');
    debugPrint('🔌 Token: ${jwtToken.substring(0, 20)}...');
    
    if (_socket != null && _socket!.connected) {
      debugPrint('🔌 Socket zaten bağlı, yeni bağlantı kurulmuyor');
      return;
    }

    // Ana URL'ye bağlan
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
      Future.delayed(Duration(seconds: 2), () async {
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
      debugPrint('🔍 Lütfen sunucu yöneticisi ile iletişime geçin.');
    });
    
    _socket!.onError((err) {
      isConnected.value = false;
      debugPrint('❌ Socket genel hata ($urlName): $err');
    });

    // Reconnection events
    _socket!.onReconnect((_) {
      debugPrint('🔄 Socket yeniden bağlandı! ($urlName)');
      
      // Yeniden bağlandıktan sonra tüm kanallara tekrar join ol
      Future.delayed(Duration(seconds: 1), () async {
        debugPrint('🔄 Yeniden bağlantı sonrası kanallara join olunuyor...');
        await _joinAllChannelsAfterConnection();
      });
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
      
      // Pin durumu kontrolü - hem direkt data hem de message objesi içinde kontrol et
      bool pinStatusDetected = false;
      
      if (data is Map<String, dynamic>) {
        // Önce message objesi içinde kontrol et - güvenli tip kontrolü
        if (data.containsKey('message')) {
          Map<String, dynamic>? messageData;
          if (data['message'] is Map<String, dynamic>) {
            messageData = data['message'] as Map<String, dynamic>;
          } else {
            debugPrint('⚠️ Message data is not a Map: ${data['message']}');
            messageData = null;
          }
          
          if (messageData != null && messageData.containsKey('is_pinned')) {
            final messageId = messageData['id']?.toString();
            final isPinned = messageData['is_pinned'] ?? false;
            final conversationId = messageData['conversation_id']?.toString();
            debugPrint('📌 [SocketService] conversation:new_message içinde pin durumu tespit edildi (message objesi): Message ID=$messageId, Conversation ID=$conversationId, isPinned=$isPinned');
            pinStatusDetected = true;
            
            // Pin durumu değişikliği için özel event gönder
            if (messageId != null && conversationId != null) {
              final pinUpdateEvent = {
                'message_id': messageId,
                'conversation_id': conversationId,
                'is_pinned': isPinned,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'source': 'conversation:new_message',
                'message_data': messageData,
              };
              
              debugPrint('📌 [SocketService] Conversation pin durumu değişikliği event\'i gönderiliyor: $pinUpdateEvent');
              _pinMessageController.add(pinUpdateEvent);
            }
          }
        }
        
        // Eğer message objesi içinde yoksa, direkt data içinde kontrol et
        if (!pinStatusDetected && data.containsKey('is_pinned')) {
          final messageId = data['id']?.toString();
          final isPinned = data['is_pinned'] ?? false;
          final conversationId = data['conversation_id']?.toString();
          debugPrint('📌 [SocketService] conversation:new_message içinde pin durumu tespit edildi (direkt data): Message ID=$messageId, Conversation ID=$conversationId, isPinned=$isPinned');
          pinStatusDetected = true;
          
          // Pin durumu değişikliği için özel event gönder
          if (messageId != null && conversationId != null) {
            final pinUpdateEvent = {
              'message_id': messageId,
              'conversation_id': conversationId,
              'is_pinned': isPinned,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'source': 'conversation:new_message',
              'message_data': data,
            };
            
            debugPrint('📌 [SocketService] Conversation pin durumu değişikliği event\'i gönderiliyor: $pinUpdateEvent');
            _pinMessageController.add(pinUpdateEvent);
          }
        }
        
        if (pinStatusDetected) {
          debugPrint('📌 [SocketService] Conversation pin event\'i tetiklendi ve ChatDetailController güncellenmeli');
        } else {
          debugPrint('📌 [SocketService] Conversation pin durumu tespit edilmedi - normal mesaj event\'i');
        }
      }
      
      _privateMessageController.add(data);
      
      // Mesaj bildirimi gönder (uygulama açıkken)
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 3. Okunmamış mesaj sayısı (toplam)
    _socket!.on('conversation:un_read_message_count', (data) {
      _unreadMessageCountController.add(data);
    });

    // 3.1. Grup okunmamış mesaj sayısı (toplam)
    _socket!.on('group:un_read_message_count', (data) {
      debugPrint('📨 Grup okunmamış mesaj sayısı (group:un_read_message_count): $data');
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

    // Pin/Unpin message events
    _socket!.on('conversation:message_pinned', (data) {
      debugPrint('📌 Conversation message pinned geldi (SocketService): $data');
      _pinMessageController.add(data);
      
      // Pin message controller'a da gönder (pin işlemi için)
      if (data is Map<String, dynamic>) {
        // Message data'yı parse et - güvenli tip kontrolü
        Map<String, dynamic> messageData;
        if (data.containsKey('message')) {
          if (data['message'] is Map<String, dynamic>) {
            messageData = data['message'] as Map<String, dynamic>;
          } else {
            debugPrint('⚠️ Message data is not a Map: ${data['message']}');
            messageData = data;
          }
        } else {
          messageData = data;
        }
        
        final messageId = messageData['id']?.toString();
        final conversationId = messageData['conversation_id']?.toString();
        
        debugPrint('📌 [SocketService] conversation:message_pinned - Message ID: $messageId, Conversation ID: $conversationId');
        
        // Özel pin event'i oluştur
        final pinEvent = {
          'message_id': messageId,
          'conversation_id': conversationId,
          'is_pinned': true, // Pin durumu
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'source': 'conversation:message_pinned',
          'message_data': messageData,
          'action': 'pin',
        };
        
        debugPrint('📌 [SocketService] Conversation pin event\'i gönderiliyor: $pinEvent');
        _pinMessageController.add(pinEvent);
      }
    });

    _socket!.on('conversation:message_unpinned', (data) {
      debugPrint('📌 Conversation message unpinned geldi (SocketService): $data');
      _pinMessageController.add(data);
      
      // Pin message controller'a da gönder (unpin işlemi için)
      if (data is Map<String, dynamic>) {
        // Message data'yı parse et - güvenli tip kontrolü
        Map<String, dynamic> messageData;
        if (data.containsKey('message')) {
          if (data['message'] is Map<String, dynamic>) {
            messageData = data['message'] as Map<String, dynamic>;
          } else {
            debugPrint('⚠️ Message data is not a Map: ${data['message']}');
            messageData = data;
          }
        } else {
          messageData = data;
        }
        
        final messageId = messageData['id']?.toString();
        final conversationId = messageData['conversation_id']?.toString();
        
        debugPrint('📌 [SocketService] conversation:message_unpinned - Message ID: $messageId, Conversation ID: $conversationId');
        
        // Özel unpin event'i oluştur
        final unpinEvent = {
          'message_id': messageId,
          'conversation_id': conversationId,
          'is_pinned': false, // Unpin durumu
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'source': 'conversation:message_unpinned',
          'message_data': messageData,
          'action': 'unpin',
        };
        
        debugPrint('📌 [SocketService] Conversation unpin event\'i gönderiliyor: $unpinEvent');
        _pinMessageController.add(unpinEvent);
      }
    });

    // Group pin/unpin events
    _socket!.on('group:message_pinned', (data) {
      debugPrint('📌 Group message pinned geldi (SocketService): $data');
      _pinMessageController.add(data);
      
      // Pin message controller'a da gönder (pin işlemi için)
      if (data is Map<String, dynamic>) {
        // Message data'yı parse et - güvenli tip kontrolü
        Map<String, dynamic> messageData;
        if (data.containsKey('message')) {
          if (data['message'] is Map<String, dynamic>) {
            messageData = data['message'] as Map<String, dynamic>;
          } else {
            debugPrint('⚠️ Message data is not a Map: ${data['message']}');
            messageData = data;
          }
        } else {
          messageData = data;
        }
        
        final messageId = messageData['id']?.toString();
        final groupId = messageData['group_id']?.toString();
        
        debugPrint('📌 [SocketService] group:message_pinned - Message ID: $messageId, Group ID: $groupId');
        
        // Özel pin event'i oluştur
        final pinEvent = {
          'message_id': messageId,
          'group_id': groupId,
          'is_pinned': true, // Pin durumu
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'source': 'group:message_pinned',
          'message_data': messageData,
          'action': 'pin',
        };
        
        debugPrint('📌 [SocketService] Pin event\'i gönderiliyor: $pinEvent');
        _pinMessageController.add(pinEvent);
      }
    });

    _socket!.on('group:message_unpinned', (data) {
      _pinMessageController.add(data);
    });

    // Alternative event names for pin/unpin
    _socket!.on('message:pinned', (data) {
      _pinMessageController.add(data);
    });

    _socket!.on('message:unpinned', (data) {
      _pinMessageController.add(data);
    });

    // Custom pin/unpin events that we send
    _socket!.on('conversation:pin_message', (data) {
      _pinMessageController.add(data);
    });

    // Handle pin/unpin events from onAny listener
    _socket!.onAny((event, data) {
      // Check if this is a pin/unpin related event
      if (data is Map<String, dynamic> && 
          data.containsKey('is_pinned') && 
          (data.containsKey('conversation_id') || data.containsKey('group_id'))) {
        
        // Prevent duplicate events by checking if this is already a pin/unpin specific event
        if (event.toString().contains('pin') || 
            event.toString().contains('unpin') ||
            event.toString().contains('conversation:pin_message') ||
            event.toString().contains('group:pin_message')) {
          
          debugPrint('📌 [SocketService] Skipping duplicate pin event from onAny: $event');
          return;
        }
        
        debugPrint('📌 [SocketService] Pin event detected in onAny: $event');
        // Broadcast to pin message listeners
        _pinMessageController.add(data);
      }
    });

    _socket!.on('group:pin_message', (data) {
      _pinMessageController.add(data);
    });

    // Pin durumu kontrolü için event'ler
    _socket!.on('group:pinned_messages', (data) {
      _pinMessageController.add(data);
    });

    _socket!.on('group:pin_status_update', (data) {
      _pinMessageController.add(data);
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

    // Grup bazında unread count event'lerini dinle
    _socket!.on('group:unread_count', (data) {
      debugPrint('📨 Grup bazında unread count (group:unread_count): $data');
      _handlePerGroupUnreadCount(data);
    });

    _socket!.on('group:count', (data) {
      debugPrint('📨 Grup bazında unread count (group:count): $data');
      _handlePerGroupUnreadCount(data);
    });

    _socket!.on('user:group_unread', (data) {
      debugPrint('📨 Grup bazında unread count (user:group_unread): $data');
      _handlePerGroupUnreadCount(data);
    });

    _socket!.on('unread:group', (data) {
      debugPrint('📨 Grup bazında unread count (unread:group): $data');
      _handlePerGroupUnreadCount(data);
    });

    _socket!.on('group:unpin_message', (data) {
      debugPrint('📌 Group unpin message geldi (SocketService): $data');
      _pinMessageController.add(data);
      
      // Pin message controller'a da gönder (unpin işlemi için)
      if (data is Map<String, dynamic>) {
        // Message data'yı parse et - güvenli tip kontrolü
        Map<String, dynamic> messageData;
        if (data.containsKey('message')) {
          if (data['message'] is Map<String, dynamic>) {
            messageData = data['message'] as Map<String, dynamic>;
          } else {
            debugPrint('⚠️ Message data is not a Map: ${data['message']}');
            messageData = data;
          }
        } else {
          messageData = data;
        }
        
        final messageId = messageData['id']?.toString();
        final groupId = messageData['group_id']?.toString();
        
        debugPrint('📌 [SocketService] group:unpin_message - Message ID: $messageId, Group ID: $groupId');
        
        // Özel unpin event'i oluştur
        final unpinEvent = {
          'message_id': messageId,
          'group_id': groupId,
          'is_pinned': false, // Unpin durumu
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'source': 'group:unpin_message',
          'message_data': messageData,
          'action': 'unpin',
        };
        
        debugPrint('📌 [SocketService] Unpin event\'i gönderiliyor: $unpinEvent');
        _pinMessageController.add(unpinEvent);
      }
    });

    // 4. Yeni bildirim
    _socket!.on('notification:new', (data) {
      debugPrint('🔔 Yeni bildirim geldi (SocketService): $data');
      _notificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
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

    // 6. Like notification (global)
    _socket!.on('like:event', (data) {
      debugPrint('❤️ Like event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 7. Follow notification (global)
    _socket!.on('follow:event', (data) {
      debugPrint('👥 Follow event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 8. Post notification (global)
    _socket!.on('post:event', (data) {
      debugPrint('📝 Post event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 9. Group join request notification (global)
    _socket!.on('group:join_request', (data) {
      debugPrint('👥 Group join request event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 10. Group join accepted notification (global)
    _socket!.on('group:join_accepted', (data) {
      debugPrint('✅ Group join accepted event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 11. Group join declined notification (global)
    _socket!.on('group:join_declined', (data) {
      debugPrint('❌ Group join declined event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 12. Follow request notification (global)
    _socket!.on('follow:request', (data) {
      debugPrint('👤 Follow request event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 13. Follow accepted notification (global)
    _socket!.on('follow:accepted', (data) {
      debugPrint('✅ Follow accepted event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 14. Follow declined notification (global)
    _socket!.on('follow:declined', (data) {
      debugPrint('❌ Follow declined event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 15. Event invitation notification (global)
    _socket!.on('event:invitation', (data) {
      debugPrint('📅 Event invitation event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 16. Event reminder notification (global)
    _socket!.on('event:reminder', (data) {
      debugPrint('⏰ Event reminder event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 17. Post mention notification (global)
    _socket!.on('post:mention', (data) {
      debugPrint('📝 Post mention event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 18. Comment mention notification (global)
    _socket!.on('comment:mention', (data) {
      debugPrint('💬 Comment mention event geldi (SocketService): $data');
      _commentNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 19. System notification (global)
    _socket!.on('system:notification', (data) {
      debugPrint('🔔 System notification event geldi (SocketService): $data');
      _userNotificationController.add(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 21. User notification (user:{user_id} kanalı)
    _socket!.on('user:notification', (data) {
      printFullText('👤 User notification geldi (SocketService): $data');
      
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
      
      // Bildirim tipini belirle - güvenli tip kontrolü
      String notificationType = 'notification';
      if (data is Map<String, dynamic> && data.containsKey('notification_data')) {
        Map<String, dynamic>? notificationData;
        if (data['notification_data'] is Map<String, dynamic>) {
          notificationData = data['notification_data'] as Map<String, dynamic>;
        } else {
          debugPrint('⚠️ Notification data is not a Map: ${data['notification_data']}');
          notificationData = null;
        }
        
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
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
      debugPrint('👤 Socket notification işlendi - OneSignal bildirimi kaldırıldı');
      debugPrint('👤 =======================================');
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
      
      // Pin/Unpin event'lerini yakala
      if (data is Map<String, dynamic> && 
          data.containsKey('is_pinned') && 
          (data.containsKey('conversation_id') || data.containsKey('group_id'))) {
        
        debugPrint('📌 Pin/Unpin event detected in onAny: $event');
        debugPrint('📌 Event data: $data');
        
        // Broadcast to pin message listeners
        _pinMessageController.add(data);
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

    // 21.5. Group message notification (user:{user_id} kanalından)
    _socket!.on('user:group_message', (data) {
      printFullText('👥 Group message notification geldi (SocketService): $data');
      
      if (data is Map<String, dynamic>) {
        printFullText('👥 === GROUP MESSAGE DETAYLI ANALİZ ===');
        
        // Grup ID'sini doğru yerden al - güvenli tip kontrolü
        dynamic groupId = data['group_id'];
        if (data.containsKey('message')) {
          if (data['message'] is Map<String, dynamic>) {
            final messageData = data['message'] as Map<String, dynamic>;
            groupId = messageData['group_id'] ?? data['group_id'];
          } else {
            debugPrint('⚠️ Message data is not a Map: ${data['message']}');
          }
        }
        printFullText('👥 Group ID: $groupId');
        
        // 🔴 GROUP UNREAD MESSAGE ANALİZİ - Private chat'teki gibi
        final isRead = data['is_read'] ?? false;
        
        if (!isRead) {
          debugPrint('🔴 GRUP KIRMIZI NOKTA GÖSTERİLECEK: Okunmamış grup mesajı (is_read: $isRead)');
        } else {
          debugPrint('⚪ GRUP KIRMIZI NOKTA GÖSTERİLMEYECEK: Okunmuş grup mesajı (is_read: $isRead)');
        }
        
        // GROUP alanını kontrol et
        if (data.containsKey('group')) {
          final group = data['group'];
          if (group is Map<String, dynamic>) {
            debugPrint('👥 📁 Group keys: ${group.keys.toList()}');
            if (group.containsKey('unread_count')) {
              debugPrint('👥 🔥 GROUP UNREAD COUNT BULUNDU: ${group['unread_count']}');
            }
            if (group.containsKey('unread_messages_count')) {
              debugPrint('👥 🔥 GROUP UNREAD MESSAGES COUNT BULUNDU: ${group['unread_messages_count']}');
            }
          }
        } else {
          debugPrint('👥 ❌ Group alanı yok');
        }
        
        // SENDER alanını kontrol et
        if (data.containsKey('sender')) {
          final sender = data['sender'];
          debugPrint('👥 👤 SENDER ALANı VAR: ${sender.runtimeType}');
          if (sender is Map<String, dynamic>) {
            debugPrint('👥 👤 Sender keys: ${sender.keys.toList()}');
            if (sender.containsKey('unread_messages_total_count')) {
              debugPrint('👥 🔥 SENDER UNREAD COUNT: ${sender['unread_messages_total_count']}');
            }
          }
        }
        
        // MESSAGE alanını kontrol et
        if (data.containsKey('message')) {
          final message = data['message'];
          if (message is Map<String, dynamic>) {
            debugPrint('👥 💬 Message keys: ${message.keys.toList()}');
            if (message.containsKey('is_read')) {
              debugPrint('👥 🔥 MESSAGE IS_READ: ${message['is_read']}');
            }
            if (message.containsKey('is_me')) {
              debugPrint('👥 🔥 MESSAGE IS_ME: ${message['is_me']}');
            }
          }
        }
      }
      
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
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
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
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    // 21.8. User kanalında grup mesajları için ek olası event'ler
    _socket!.on('user:new_group_message', (data) {
      debugPrint('👥 User new group message geldi (SocketService): $data');
      _groupMessageController.add(data);
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('user:chat_message', (data) {
      debugPrint('👥 User chat message geldi (SocketService): $data');
      _groupMessageController.add(data);
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('user:message_group', (data) {
      debugPrint('👥 User message group geldi (SocketService): $data');
      _groupMessageController.add(data);
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('user:group_message_new', (data) {
      debugPrint('👥 User group message new geldi (SocketService): $data');
      _groupMessageController.add(data);
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('user:new_message', (data) {
      debugPrint('👥 User new message geldi (SocketService): $data');
      _groupMessageController.add(data);
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    _socket!.on('user:message_new', (data) {
      debugPrint('👥 User message new geldi (SocketService): $data');
      _groupMessageController.add(data);
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    _socket!.on('user:chat', (data) {
      debugPrint('👥 User chat geldi (SocketService): $data');
      _groupMessageController.add(data);
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    _socket!.on('user:group', (data) {
      debugPrint('👥 User group geldi (SocketService): $data');
      _groupMessageController.add(data);
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
      // OneSignal bildirimi kaldırıldı - sadece badge güncellenir
    });

    // 21.6. Group message (alternatif event isimleri)
    _socket!.on('group:message', (data) {
      printFullText('👥 Group message event geldi (SocketService): $data');
      
      if (data is Map<String, dynamic>) {
        printFullText('👥 === GROUP MESSAGE EVENT DETAYLI ANALİZ ===');
        
        // Grup ID'sini doğru yerden al - güvenli tip kontrolü
        dynamic groupId = data['group_id'];
        if (data.containsKey('message')) {
          if (data['message'] is Map<String, dynamic>) {
            final messageData = data['message'] as Map<String, dynamic>;
            groupId = messageData['group_id'] ?? data['group_id'];
          } else {
            debugPrint('⚠️ Message data is not a Map: ${data['message']}');
          }
        }
        printFullText('👥 Group ID: $groupId');
      }
      
      debugPrint('📡 [SocketService] group:message - _groupMessageController.add() çağrılıyor');
      _groupMessageController.add(data);
      debugPrint('📡 [SocketService] group:message - _groupMessageController.add() tamamlandı');
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
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
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
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
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
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
        
        // Message alanını kontrol et - güvenli tip kontrolü
        if (data.containsKey('message')) {
          if (data['message'] is Map<String, dynamic>) {
            final messageData = data['message'] as Map<String, dynamic>;
            printFullText('👥 📝 MESSAGE ALANı VAR: ${messageData.runtimeType}');
            printFullText('👥 📝 Message data: $messageData');
            printFullText('👥 📝 Message keys: ${messageData.keys.toList()}');
            printFullText('👥 📝 Message text: ${messageData['message']}');
            printFullText('👥 📝 Message is_read: ${messageData['is_read']}');
            printFullText('👥 📝 Message is_me: ${messageData['is_me']}');
          } else {
            debugPrint('⚠️ Message data is not a Map: ${data['message']}');
          }
        }
        
        // User alanını kontrol et - güvenli tip kontrolü
        if (data.containsKey('user')) {
          if (data['user'] is Map<String, dynamic>) {
            final userData = data['user'] as Map<String, dynamic>;
            printFullText('👥 👤 USER ALANı VAR: ${userData.runtimeType}');
            printFullText('👥 👤 User keys: ${userData.keys.toList()}');
            printFullText('👥 👤 User name: ${userData['name']}');
            printFullText('👥 👤 User ID: ${userData['id']}');
          } else {
            debugPrint('⚠️ User data is not a Map: ${data['user']}');
          }
        }
        
        printFullText('👥 === ANALİZ TAMAMLANDI ===');
      }
      
      debugPrint('📡 [SocketService] group:new_message - _groupMessageController.add() çağrılıyor');
      _groupMessageController.add(data);
      debugPrint('📡 [SocketService] group:new_message - _groupMessageController.add() tamamlandı');
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
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
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
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
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
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
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
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
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
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
      
      // Grup unread count'unu güncelle
      _updateGroupUnreadCountFromSocket(data);
      
      // Özel grup mesaj bildirimi gönder (uygulama açıkken)
      debugPrint('👥 Özel grup mesaj bildirimi gönderiliyor...');
      _sendCustomGroupMessageNotification(data);
      debugPrint('👥 Özel grup mesaj bildirimi gönderme tamamlandı');
    });

    _socket!.on('group:chat_message', (data) {
      debugPrint('👥 Group chat message geldi (SocketService): $data');
      _groupMessageController.add(data);
      
      // Pin durumu kontrolü - hem direkt data hem de message objesi içinde kontrol et
      bool pinStatusDetected = false;
      
      if (data is Map<String, dynamic>) {
        // Önce message objesi içinde kontrol et - güvenli tip kontrolü
        if (data.containsKey('message')) {
          Map<String, dynamic>? messageData;
          if (data['message'] is Map<String, dynamic>) {
            messageData = data['message'] as Map<String, dynamic>;
          } else {
            debugPrint('⚠️ Message data is not a Map: ${data['message']}');
            messageData = null;
          }
          
          if (messageData != null && messageData.containsKey('is_pinned')) {
            final messageId = messageData['id']?.toString();
            final isPinned = messageData['is_pinned'] ?? false;
            final groupId = messageData['group_id']?.toString();
            debugPrint('📌 [SocketService] group:chat_message içinde pin durumu tespit edildi (message objesi): Message ID=$messageId, Group ID=$groupId, isPinned=$isPinned');
            pinStatusDetected = true;
            
            // Pin durumu değişikliği için özel event gönder
            if (messageId != null && groupId != null) {
              final pinUpdateEvent = {
                'message_id': messageId,
                'group_id': groupId,
                'is_pinned': isPinned,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'source': 'group:chat_message',
                'message_data': messageData,
              };
              
              debugPrint('📌 [SocketService] Pin durumu değişikliği event\'i gönderiliyor: $pinUpdateEvent');
              _pinMessageController.add(pinUpdateEvent);
            }
          }
        }
        
        // Eğer message objesi içinde yoksa, direkt data içinde kontrol et
        if (!pinStatusDetected && data.containsKey('is_pinned')) {
          final messageId = data['id']?.toString();
          final isPinned = data['is_pinned'] ?? false;
          final groupId = data['group_id']?.toString();
          debugPrint('📌 [SocketService] group:chat_message içinde pin durumu tespit edildi (direkt data): Message ID=$messageId, Group ID=$groupId, isPinned=$isPinned');
          pinStatusDetected = true;
          
          // Pin durumu değişikliği için özel event gönder
          if (messageId != null && groupId != null) {
            final pinUpdateEvent = {
              'message_id': messageId,
              'group_id': groupId,
              'is_pinned': isPinned,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'source': 'group:chat_message',
              'message_data': data,
            };
            
            debugPrint('📌 [SocketService] Pin durumu değişikliği event\'i gönderiliyor: $pinUpdateEvent');
            _pinMessageController.add(pinUpdateEvent);
          }
        }
        
        if (pinStatusDetected) {
          debugPrint('📌 [SocketService] Pin event\'i tetiklendi ve PinnedMessagesWidget güncellenmeli');
        } else {
          debugPrint('📌 [SocketService] Pin durumu tespit edilmedi - normal mesaj event\'i');
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
      // DEBOUNCE: Çoklu join işlemlerini engelle
      final now = DateTime.now();
      if (_isJoiningChannels) {
        debugPrint('🚫 Join işlemi zaten devam ediyor, yeni istek reddedildi');
        return;
      }
      
      if (_lastJoinTime != null && now.difference(_lastJoinTime!) < _joinDebounce) {
        debugPrint('🚫 Join işlemi çok sık çağrılıyor, debounce uygulandı');
        return;
      }
      
      _isJoiningChannels = true;
      _lastJoinTime = now;
      
      debugPrint('🔔 _joinAllChannelsAfterConnection() başlatıldı');
      debugPrint('🔔 Uygulama başlatıldığında veya yeniden bağlandığında grup kanallarına join olunuyor...');
      
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
        
        debugPrint('✅ Tüm kanallara join işlemi tamamlandı - Grup mesajları artık dinleniyor!');
      } else {
        debugPrint('❌ Token bulunamadı, join işlemleri yapılamıyor');
      }
    } catch (e) {
      debugPrint('❌ Bağlantı sonrası user kanalına join olma hatası: $e');
      debugPrint('❌ Hata detayı: ${e.toString()}');
    } finally {
      _isJoiningChannels = false;
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
      
      // Grup unread count istekleri
      _socket!.emit('get:group_unread_count');
      _socket!.emit('request:group_unread_count');
      _socket!.emit('group:get_unread_count');
      _socket!.emit('get:group_unread_counts');
      _socket!.emit('request:per_group_unread');
      _socket!.emit('get:group_unread_details');
      _socket!.emit('request:unread_by_group');
      _socket!.emit('group:get_unread_details');
      
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

  /// Grup bazında unread count'ları handle et
  void _handlePerGroupUnreadCount(dynamic data) {
    debugPrint('🔍 Grup bazında unread count işleniyor: $data');
    debugPrint('🔍 Data type: ${data.runtimeType}');
    debugPrint('🔍 Data keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
    
    if (data is Map<String, dynamic>) {
      debugPrint('🔍 === PER GROUP UNREAD COUNT DETAYI ===');
      debugPrint('🔍 Group ID: ${data['group_id']}');
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
      
      // Socket bağlı mı kontrol et
      if (_socket == null || !_socket!.connected) {
        debugPrint('❌ Socket bağlı değil, gruplara join olunamıyor');
        return;
      }
      
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
            
            // TEST: Join işlemini geçici olarak devre dışı bırak
            // _socket!.emit('group:join', {'group_id': groupId});
            // _socket!.emit('join:group', {'group_id': groupId});
            // _socket!.emit('subscribe:group', {'group_id': groupId});
            
            debugPrint('🧪 TEST: Join işlemi devre dışı bırakıldı - mesajları dinlemeye devam ediyoruz');
            
            // Her grup arasında kısa bir bekleme
            await Future.delayed(Duration(milliseconds: 100));
          } else {
            debugPrint('⚠️ Boş grup ID: ${group.name}');
          }
        }
        
        debugPrint('✅ TEST: Join işlemi olmadan grup mesajları dinleniyor');
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

  

  // Özel grup mesaj bildirimi gönder (grup profil resmi, grup adı ve gönderen bilgisi ile)
  void _sendCustomGroupMessageNotification(dynamic data) async {
    try {
      debugPrint('👥 Özel grup mesaj bildirimi hazırlanıyor...');
      
      // Group mesaj data yapısı: {message: {message: "text", user: {name: "...", avatar_url: "..."}}}
      Map<String, dynamic>? messageData;
      if (data['message'] is Map<String, dynamic>) {
        messageData = data['message'] as Map<String, dynamic>;
      } else {
        debugPrint('⚠️ Message data is not a Map: ${data['message']}');
        messageData = null;
      }
      
      if (messageData == null) {
        debugPrint('❌ Group message data is null');
        return;
      }
      
      // Güvenli tip kontrolü - user alanının Map olduğundan emin ol
      Map<String, dynamic>? userData;
      if (messageData['user'] is Map<String, dynamic>) {
        userData = messageData['user'] as Map<String, dynamic>;
      } else {
        debugPrint('⚠️ User data is not a Map: ${messageData['user']}');
        userData = null;
      }
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
    _pinMessageController.close();
    disconnect();
    super.onClose();
  }

  /// Socket nesnesi
  io.Socket? get socket => _socket;

  /// Socket'ten gelen grup mesajında unread count'u güncelle
  void _updateGroupUnreadCountFromSocket(dynamic data) {
    try {
      debugPrint('📊 [SocketService] Grup unread count güncelleniyor...');
      
      if (data is Map<String, dynamic>) {
        // Grup ID'sini al
        int? groupId;
        bool isMe = false;
        bool isRead = false;
        
        // Direkt data'dan al
        groupId = data['group_id'];
        isMe = data['is_me'] ?? false;
        isRead = data['is_read'] ?? true;
        
        // Message objesi içinden de kontrol et
        if (data.containsKey('message') && data['message'] is Map<String, dynamic>) {
          final messageData = data['message'] as Map<String, dynamic>;
          groupId = messageData['group_id'] ?? groupId;
          isMe = messageData['is_me'] ?? isMe;
          isRead = messageData['is_read'] ?? isRead;
        }
        
        // User objesi içinden unread count'u al
        int unreadCount = 0;
        if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
          final userData = data['user'] as Map<String, dynamic>;
          unreadCount = userData['unread_messages_total_count'] ?? 0;
        }
        
        debugPrint('📊 [SocketService] Grup ID: $groupId, isMe: $isMe, isRead: $isRead, unreadCount: $unreadCount');
        
        // Kendi mesajımız değilse ve grup ID varsa güncelle
        if (!isMe && groupId != null) {
          try {
            final chatController = Get.find<ChatController>();
            // Grup unread count'unu güncelle
            chatController.handleGroupUnreadCount(groupId, unreadCount);
            debugPrint('✅ [SocketService] Grup unread count güncellendi: groupId=$groupId, unreadCount=$unreadCount');
          } catch (e) {
            debugPrint('⚠️ [SocketService] ChatController bulunamadı: $e');
          }
        } else {
          debugPrint('📊 [SocketService] Kendi mesajımız veya grup ID yok, güncelleme yapılmadı');
        }
      }
    } catch (e) {
      debugPrint('❌ [SocketService] Grup unread count güncelleme hatası: $e');
    }
  }

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
