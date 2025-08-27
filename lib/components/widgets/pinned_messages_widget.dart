import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../models/chat_models/chat_detail_model.dart';
import '../../models/chat_models/group_message_model.dart';
import '../../controllers/chat_controllers/chat_detail_controller.dart';
import '../../controllers/chat_controllers/group_chat_detail_controller.dart';
import '../../services/pin_message_service.dart';
import '../../services/socket_services.dart';
import 'dart:async'; // Added for StreamSubscription and Timer

class PinnedMessagesWidget extends StatefulWidget {
  final bool isGroupChat;

  const PinnedMessagesWidget({
    super.key,
    required this.isGroupChat,
  });

  @override
  State<PinnedMessagesWidget> createState() => _PinnedMessagesWidgetState();
}

class _PinnedMessagesWidgetState extends State<PinnedMessagesWidget> {
  late StreamSubscription _pinUpdateSubscription;
  late StreamSubscription _groupMessageSubscription;
  bool _isListening = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _setupPinUpdateListener();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _pinUpdateSubscription.cancel();
    _groupMessageSubscription.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    // Her 2 saniyede bir widget'ı yenile
    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (mounted) {
        print('📌 [PinnedMessagesWidget] Periodic refresh triggered');
        setState(() {
          // Widget'ı yeniden oluştur
        });
      }
    });
  }

  void _setupPinUpdateListener() {
    if (widget.isGroupChat) {
      try {
        final socketService = Get.find<SocketService>();
        _pinUpdateSubscription = socketService.onPinMessage.listen((data) {
          if (mounted) {
            print('📌 [PinnedMessagesWidget] Pin update event received: $data');
            
            // Pin durumu değişikliği kontrolü
            if (data is Map<String, dynamic>) {
              final isPinned = data['is_pinned'] ?? false;
              final messageId = data['message_id']?.toString();
              
              print('📌 [PinnedMessagesWidget] Pin status change detected: Message ID=$messageId, isPinned=$isPinned');
              
              if (!isPinned) {
                print('📌 [PinnedMessagesWidget] UNPIN detected - Forcing widget refresh');
                // Unpin durumunda widget'ı zorla yenile
                _forceWidgetRefresh();
              } else {
                print('📌 [PinnedMessagesWidget] PIN detected - Updating widget');
                setState(() {
                  // Widget'ı yeniden oluştur
                });
              }
            } else {
              setState(() {
                // Widget'ı yeniden oluştur
              });
            }
          }
        });
        
        // Group message events'ini de dinle
        final groupMessageSubscription = socketService.onGroupMessage.listen((data) {
          if (mounted) {
            print('📌 [PinnedMessagesWidget] Group message event received: $data');
            
            // Pin durumu kontrolü
            if (data is Map<String, dynamic> && data.containsKey('message')) {
              final messageData = data['message'] as Map<String, dynamic>?;
              if (messageData != null && messageData.containsKey('is_pinned')) {
                final isPinned = messageData['is_pinned'] ?? false;
                final messageId = messageData['id']?.toString();
                
                print('📌 [PinnedMessagesWidget] Group message pin status: Message ID=$messageId, isPinned=$isPinned');
                
                // Widget'ı yenile
                setState(() {
                  // Widget'ı yeniden oluştur
                });
              }
            }
          }
        });
        
        _isListening = true;
        print('📌 [PinnedMessagesWidget] Pin update listener setup completed');
      } catch (e) {
        print('❌ [PinnedMessagesWidget] Pin update listener setup error: $e');
      }
    }
  }

  /// Widget'ı zorla yenile (unpin işlemleri için)
  void _forceWidgetRefresh() {
    print('📌 [PinnedMessagesWidget] Force refresh called');
    
    // Önce setState ile yenile
    setState(() {
      // Widget'ı yeniden oluştur
    });
    
    // Sonra kısa bir gecikme ile tekrar yenile (unpin işlemi için)
    Future.delayed(Duration(milliseconds: 50), () {
      if (mounted) {
        print('📌 [PinnedMessagesWidget] Force refresh delayed call');
        setState(() {
          // Widget'ı tekrar yeniden oluştur
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGroupChat) {
      return _buildGroupPinnedMessages();
    } else {
      return _buildPrivatePinnedMessages();
    }
  }

  Widget _buildPrivatePinnedMessages() {
    return Obx(() {
      final controller = Get.find<ChatDetailController>();
      final pinnedMessages = controller.messages
          .where((msg) => msg.isPinned)
          .toList();

      if (pinnedMessages.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.push_pin,
                  size: 16,
                  color: const Color(0xff414751),
                ),
                const SizedBox(width: 8),
                Text(
                  'Sabitlenen Mesajlar',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff414751),
                  ),
                ),
                const Spacer(),
                Text(
                  '${pinnedMessages.length}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xff9ca3ae),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...pinnedMessages.take(3).map((message) => _buildPinnedMessageItem(message)),
            if (pinnedMessages.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  've ${pinnedMessages.length - 3} mesaj daha...',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xff9ca3ae),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildGroupPinnedMessages() {
    return Obx(() {
      final controller = Get.find<GroupChatDetailController>();
      final allMessages = controller.messages;
      final pinnedMessages = allMessages.where((msg) => msg.isPinned).toList();

      // Debug log'ları ekle
      print('🔍 [PinnedMessagesWidget] Total messages: ${allMessages.length}');
      print('🔍 [PinnedMessagesWidget] Pinned messages: ${pinnedMessages.length}');
      print('🔍 [PinnedMessagesWidget] Widget rebuild triggered at: ${DateTime.now()}');
      
      // Pinlenmiş mesajların detaylarını logla
      for (int i = 0; i < allMessages.length; i++) {
        final msg = allMessages[i];
        if (msg.isPinned) {
          print('🔍 [PinnedMessagesWidget] Pinned message $i: ID=${msg.id}, Content="${msg.content}", Username=${msg.username}');
        }
      }
      
      // Pinlenmiş mesajlar varsa widget'ı göster
      if (pinnedMessages.isNotEmpty) {
        print('🔍 [PinnedMessagesWidget] Widget gösteriliyor - ${pinnedMessages.length} pinlenmiş mesaj');
        print('🔍 [PinnedMessagesWidget] İlk 3 pinlenmiş mesaj: ${pinnedMessages.take(3).map((m) => 'ID=${m.id}').join(', ')}');
      } else {
        print('🔍 [PinnedMessagesWidget] Widget gizleniyor - pinlenmiş mesaj yok');
      }

      if (pinnedMessages.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.push_pin,
                  size: 16,
                  color: const Color(0xff414751),
                ),
                const SizedBox(width: 8),
                Text(
                  'Sabitlenen Mesajlar',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff414751),
                  ),
                ),
                const Spacer(),
                Text(
                  '${pinnedMessages.length}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xff9ca3ae),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...pinnedMessages.take(3).map((message) => _buildGroupPinnedMessageItem(message)),
            if (pinnedMessages.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  've ${pinnedMessages.length - 3} mesaj daha...',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xff9ca3ae),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPinnedMessageItem(MessageModel message) {
    final username = message.sender.name;
    final content = message.message;
    final timestamp = DateTime.tryParse(message.createdAt) ?? DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xfff9fafb),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey[300],
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@$username',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff414751),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content.length > 50 ? '${content.substring(0, 50)}...' : content,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xff6b7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xff9ca3ae),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupPinnedMessageItem(GroupMessageModel message) {
    final username = message.username;
    final content = message.content;
    final timestamp = message.timestamp;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xfff9fafb),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey[300],
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@$username',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff414751),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content.length > 50 ? '${content.substring(0, 50)}...' : content,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xff6b7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xff9ca3ae),
            ),
          ),
        ],
      ),
    );
  }
}
