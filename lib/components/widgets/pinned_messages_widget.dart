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
  StreamSubscription? _pinUpdateSubscription;
  StreamSubscription? _groupMessageSubscription;
  bool _isListening = false;
  Timer? _refreshTimer;
  bool _isExpanded = false; // Show more/less state
  double? _screenHeight; // Store screen height safely

  @override
  void initState() {
    super.initState();
    _setupPinUpdateListener();
    _startRefreshTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely get screen height when dependencies change
    _screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  void dispose() {
    _pinUpdateSubscription?.cancel();
    _groupMessageSubscription?.cancel();
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
              final source = data['source'];
              final action = data['action'];

              print(
                  '📌 [PinnedMessagesWidget] Pin status change detected: Message ID=$messageId, isPinned=$isPinned, Source=$source, Action=$action');

              if (!isPinned ||
                  source == 'group:unpin_message' ||
                  action == 'unpin') {
                print(
                    '📌 [PinnedMessagesWidget] UNPIN detected - Forcing widget refresh');
                // Unpin durumunda widget'ı zorla yenile
                _forceWidgetRefresh();
              } else {
                print(
                    '📌 [PinnedMessagesWidget] PIN detected - Updating widget');
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
        _groupMessageSubscription = socketService.onGroupMessage.listen((data) {
          if (mounted) {
            print(
                '📌 [PinnedMessagesWidget] Group message event received: $data');

            // Pin durumu kontrolü
            if (data is Map<String, dynamic> && data.containsKey('message')) {
              final messageData = data['message'] as Map<String, dynamic>?;
              if (messageData != null && messageData.containsKey('is_pinned')) {
                final isPinned = messageData['is_pinned'] ?? false;
                final messageId = messageData['id']?.toString();

                print(
                    '📌 [PinnedMessagesWidget] Group message pin status: Message ID=$messageId, isPinned=$isPinned');

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
      final pinnedMessages =
          controller.messages.where((msg) => msg.isPinned).toList();

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
            // Show first message or all messages based on expanded state
            if (_isExpanded && pinnedMessages.length > 5)
              // Scrollable container for more than 5 messages
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 350, // Maximum height for scrollable area
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...pinnedMessages.map((message) => _buildPinnedMessageItem(message)),
                    ],
                  ),
                ),
              )
            else if (_isExpanded)
              // Show all messages without scroll for 5 or fewer messages
              ...pinnedMessages.map((message) => _buildPinnedMessageItem(message))
            else
              // Show only first message when collapsed
              ...pinnedMessages.take(1).map((message) => _buildPinnedMessageItem(message)),
            
            // Show more/less button if there are more than 1 message
            if (pinnedMessages.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                   
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 16,
                          color: const Color(0xff6b7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isExpanded 
                              ? 'Daha az göster' 
                              : '${pinnedMessages.length - 1} mesaj daha göster',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff6b7280),
                          ),
                        ),
                      ],
                    ),
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

      
      // Pinlenmiş mesajların detaylarını logla
      for (int i = 0; i < allMessages.length; i++) {
        final msg = allMessages[i];
        if (msg.isPinned) {
         
        }
      }

      // Pinlenmiş mesajlar varsa widget'ı göster
     

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
            // Show first message or all messages based on expanded state
            if (_isExpanded && pinnedMessages.length > 5)
              // Scrollable container for more than 5 messages
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 350, // Maximum height for scrollable area
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...pinnedMessages.map((message) => _buildGroupPinnedMessageItem(message)),
                    ],
                  ),
                ),
              )
            else if (_isExpanded)
              // Show all messages without scroll for 5 or fewer messages
              ...pinnedMessages.map((message) => _buildGroupPinnedMessageItem(message))
            else
              // Show only first message when collapsed
              ...pinnedMessages.take(1).map((message) => _buildGroupPinnedMessageItem(message)),
            
            // Show more/less button if there are more than 1 message
            if (pinnedMessages.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 16,
                          color: const Color(0xff6b7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isExpanded 
                              ? 'Daha az göster' 
                              : '${pinnedMessages.length - 1} mesaj daha göster',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff6b7280),
                          ),
                        ),
                      ],
                    ),
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

    return GestureDetector(
      onTap: () => _navigateToMessage(message.id),
      child: Container(
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
                    content.length > 50
                        ? '${content.substring(0, 50)}...'
                        : content,
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
      ),
    );
  }

  Widget _buildGroupPinnedMessageItem(GroupMessageModel message) {
    final username = message.username;
    final content = message.content;
    final timestamp = message.timestamp;
    final controller = Get.find<GroupChatDetailController>();

    return GestureDetector(
      onTap: () => _navigateToGroupMessage(message.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xfff9fafb),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Pin icon - admin olmayan kullanıcılar için kırmızı pin
            if (!controller.isCurrentUserAdmin)
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Icon(
                  Icons.push_pin,
                  size: 12,
                  color: const Color(0xFFff7c7c),
                ),
              ),
            
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
                    content.length > 50
                        ? '${content.substring(0, 50)}...'
                        : content,
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
      ),
    );
  }

  /// Private chat mesajına git
  void _navigateToMessage(int messageId) {
    try {
      print('📌 [PinnedMessagesWidget] Navigating to private message: $messageId');
      
      final controller = Get.find<ChatDetailController>();
      
      // Mesajın index'ini bul
      final messageIndex = controller.messages.indexWhere((msg) => msg.id == messageId);
      
      if (messageIndex != -1) {
        print('📌 [PinnedMessagesWidget] Message found at index: $messageIndex');
        
        // ScrollController varsa o mesaja git
        if (controller.scrollController != null) {
          // Güvenli şekilde ekran yüksekliğini al
          final screenHeight = _screenHeight ?? 800.0; // Default fallback
          
          // Mesajın pozisyonunu hesapla (her mesaj için yaklaşık 100px)
          final messagePosition = messageIndex * 100.0;
          
          // Mesajın ekranın ortasına gelmesi için hedef pozisyonu hesapla
          final targetPosition = messagePosition - (screenHeight / 2) + 50; // 50px offset for better centering
          
          // Negatif pozisyon olmaması için kontrol et
          final finalPosition = targetPosition < 0 ? 0.0 : targetPosition;
          
          controller.scrollController!.animateTo(
            finalPosition,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          
          print('📌 [PinnedMessagesWidget] Scrolled to center position: $finalPosition');
        } else {
          print('❌ [PinnedMessagesWidget] ScrollController not found');
        }
      } else {
        print('❌ [PinnedMessagesWidget] Message not found with ID: $messageId');
      }
    } catch (e) {
      print('❌ [PinnedMessagesWidget] Navigation error: $e');
    }
  }

  /// Group chat mesajına git
  void _navigateToGroupMessage(String messageId) {
    try {
      print('📌 [PinnedMessagesWidget] Navigating to group message: $messageId');
      
      final controller = Get.find<GroupChatDetailController>();
      
      // Mesajın index'ini bul
      final messageIndex = controller.messages.indexWhere((msg) => msg.id == messageId);
      
      if (messageIndex != -1) {
        print('📌 [PinnedMessagesWidget] Group message found at index: $messageIndex');
        
        // ScrollController varsa o mesaja git
        if (controller.scrollController != null) {
          // Güvenli şekilde ekran yüksekliğini al
          final screenHeight = _screenHeight ?? 800.0; // Default fallback
          
          // Mesajın pozisyonunu hesapla (her mesaj için yaklaşık 120px)
          final messagePosition = messageIndex * 120.0;
          
          // Mesajın ekranın ortasına gelmesi için hedef pozisyonu hesapla
          final targetPosition = messagePosition - (screenHeight / 2) + 60; // 60px offset for better centering
          
          // Negatif pozisyon olmaması için kontrol et
          final finalPosition = targetPosition < 0 ? 0.0 : targetPosition;
          
          controller.scrollController!.animateTo(
            finalPosition,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          
          print('📌 [PinnedMessagesWidget] Scrolled to group message center position: $finalPosition');
        } else {
          print('❌ [PinnedMessagesWidget] Group ScrollController not found');
        }
      } else {
        print('❌ [PinnedMessagesWidget] Group message not found with ID: $messageId');
      }
    } catch (e) {
      print('❌ [PinnedMessagesWidget] Group navigation error: $e');
    }
  }
}
