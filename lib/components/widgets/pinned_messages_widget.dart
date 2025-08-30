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
  StreamSubscription? _privateMessageSubscription;
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
    _privateMessageSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    // Her 2 saniyede bir widget'ı yenile
    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          // Widget'ı yeniden oluştur
        });
      }
    });
  }

  void _setupPinUpdateListener() {
    try {
      final socketService = Get.find<SocketService>();
      
      // Pin/Unpin event'lerini dinle (hem group hem private chat için)
      _pinUpdateSubscription = socketService.onPinMessage.listen((data) {
        if (mounted) {
          debugPrint('📌 [PinnedMessagesWidget] Pin update event received: $data');

          // Pin durumu değişikliği kontrolü
          if (data is Map<String, dynamic>) {
            final isPinned = data['is_pinned'] ?? false;
            final source = data['source'];
            final action = data['action'];
            final conversationId = data['conversation_id']?.toString();
            final groupId = data['group_id']?.toString();

            debugPrint('📌 [PinnedMessagesWidget] Parsed data: isPinned=$isPinned, source=$source, action=$action, conversationId=$conversationId, groupId=$groupId');

            // Private chat için conversation ID kontrolü
            if (!widget.isGroupChat && conversationId != null) {
              try {
                final chatController = Get.find<ChatDetailController>();
                if (conversationId == chatController.currentConversationId.value) {
                  debugPrint('📌 [PinnedMessagesWidget] Private chat pin update detected');
                  debugPrint('📌 [PinnedMessagesWidget] Pin status: $isPinned, Source: $source, Action: $action');
                  
                  // Her durumda widget'ı zorla yenile
                  _forceWidgetRefresh();
                  
                  // Ek olarak controller'ı da güncelle
                  chatController.update();
                  
                  debugPrint('📌 [PinnedMessagesWidget] Private chat widget and controller updated');
                }
              } catch (e) {
                debugPrint('❌ [PinnedMessagesWidget] ChatDetailController not found: $e');
              }
            }
            
            // Group chat için group ID kontrolü
            if (widget.isGroupChat && groupId != null) {
              try {
                final groupController = Get.find<GroupChatDetailController>();
                if (groupId == groupController.currentGroupId.value.toString()) {
                  debugPrint('📌 [PinnedMessagesWidget] Group chat pin update detected');
                  
                  if (!isPinned ||
                      source == 'group:unpin_message' ||
                      action == 'unpin') {
                    // Unpin durumunda widget'ı zorla yenile
                    _forceWidgetRefresh();
                  } else {
                    setState(() {
                      // Widget'ı yeniden oluştur
                    });
                  }
                }
              } catch (e) {
                debugPrint('❌ [PinnedMessagesWidget] GroupChatDetailController not found: $e');
              }
            }
          } else {
            setState(() {
              // Widget'ı yeniden oluştur
            });
          }
        }
      });

      // Group message events'ini de dinle (sadece group chat için)
      if (widget.isGroupChat) {
        _groupMessageSubscription = socketService.onGroupMessage.listen((data) {
          if (mounted) {
            // Pin durumu kontrolü
            if (data is Map<String, dynamic> && data.containsKey('message')) {
              final messageData = data['message'] as Map<String, dynamic>?;
              if (messageData != null && messageData.containsKey('is_pinned')) {
                // Widget'ı yenile
                setState(() {
                  // Widget'ı yeniden oluştur
                });
              }
            }
          }
        });
      }

      // Private message events'ini de dinle (sadece private chat için)
      if (!widget.isGroupChat) {
        _privateMessageSubscription = socketService.onPrivateMessage.listen((data) {
          if (mounted) {
            debugPrint('📌 [PinnedMessagesWidget] Private message event received: $data');
            
            // Pin durumu kontrolü
            if (data is Map<String, dynamic> && data.containsKey('is_pinned')) {
              final isPinned = data['is_pinned'] ?? false;
              final conversationId = data['conversation_id']?.toString();
              
              debugPrint('📌 [PinnedMessagesWidget] Private message pin status detected: isPinned=$isPinned, conversationId=$conversationId');
              
              try {
                final chatController = Get.find<ChatDetailController>();
                if (conversationId == chatController.currentConversationId.value) {
                  debugPrint('📌 [PinnedMessagesWidget] Private chat pin update - forcing widget refresh');
                  _forceWidgetRefresh();
                }
              } catch (e) {
                debugPrint('❌ [PinnedMessagesWidget] ChatDetailController not found: $e');
              }
            }
          }
        });
      }

    } catch (e) {
      debugPrint('❌ [PinnedMessagesWidget] Pin update listener setup error: $e');
    }
  }

  /// Widget'ı zorla yenile (unpin işlemleri için)
  void _forceWidgetRefresh() {
    debugPrint('📌 [PinnedMessagesWidget] Force widget refresh triggered');

    // Önce setState ile yenile
    setState(() {
      // Widget'ı yeniden oluştur
    });

    // Sonra kısa bir gecikme ile tekrar yenile (unpin işlemi için)
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          // Widget'ı tekrar yeniden oluştur
        });
      }
    });

    // Daha uzun bir gecikme ile tekrar yenile (socket event'leri için)
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          // Widget'ı tekrar yeniden oluştur
        });
      }
    });

    // En son bir kez daha yenile (tüm güncellemeler için)
    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          // Widget'ı tekrar yeniden oluştur
        });
        debugPrint('📌 [PinnedMessagesWidget] Final widget refresh completed');
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
      try {
        final controller = Get.find<ChatDetailController>();
        
        // Messages listesini force refresh et
        controller.messages.refresh();
        
        final pinnedMessages =
            controller.messages.where((msg) => msg.isPinned).toList();

        debugPrint('📌 [PinnedMessagesWidget] Building private pinned messages. Count: ${pinnedMessages.length}');
        debugPrint('📌 [PinnedMessagesWidget] Pinned message IDs: ${pinnedMessages.map((m) => m.id).toList()}');

        if (pinnedMessages.isEmpty) {
          debugPrint('📌 [PinnedMessagesWidget] No pinned messages found');
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
      } catch (e) {
        debugPrint('❌ [PinnedMessagesWidget] Error building private pinned messages: $e');
        return const SizedBox.shrink();
      }
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
    final profileImage = message.senderAvatarUrl;
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
              backgroundImage: (profileImage != null && profileImage.isNotEmpty && !profileImage.endsWith('/0'))
                  ? NetworkImage(profileImage)
                  : null,
              child: (profileImage == null || profileImage.isEmpty || profileImage.endsWith('/0'))
                  ? Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    )
                  : null,
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
            // Pin kaldırma butonu (admin için)
            GestureDetector(
              onTap: () => _unpinMessage(message.id),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.push_pin,
                  size: 14,
                  color: Colors.red.shade600,
                ),
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
              backgroundImage: (message.profileImage.isNotEmpty && !message.profileImage.endsWith('/0'))
                  ? NetworkImage(message.profileImage)
                  : null,
              child: (message.profileImage.isEmpty || message.profileImage.endsWith('/0'))
                  ? Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    )
                  : null,
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
            // Pin kaldırma butonu (sadece admin için)
            if (controller.isCurrentUserAdmin)
              GestureDetector(
                onTap: () => _unpinGroupMessage(message.id),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.push_pin,
                    size: 14,
                    color: Colors.red.shade600,
                  ),
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
      debugPrint('📌 [PinnedMessagesWidget] Navigating to private message: $messageId');
      
      final controller = Get.find<ChatDetailController>();
      
      // Mesajın index'ini bul
      final messageIndex = controller.messages.indexWhere((msg) => msg.id == messageId);
      
      if (messageIndex != -1) {
        debugPrint('📌 [PinnedMessagesWidget] Message found at index: $messageIndex');
        
        // ScrollController'ın hazır olmasını bekle
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            // Güvenli şekilde ekran yüksekliğini al
            final screenHeight = _screenHeight ?? 800.0;
            
            // Mesajın pozisyonunu hesapla (her mesaj için yaklaşık 100px)
            final messagePosition = messageIndex * 100.0;
            
            // Mesajın ekranın orta alt kısmına gelmesi için hedef pozisyonu hesapla
            // Ekranın %70'ine kadar scroll et (alt kısımda kalsın)
            final targetPosition = messagePosition - (screenHeight * 0.3);
            
            // Negatif pozisyon olmaması için kontrol et
            final finalPosition = targetPosition < 0 ? 0.0 : targetPosition;
            
            debugPrint('📌 [PinnedMessagesWidget] Screen height: $screenHeight');
            debugPrint('📌 [PinnedMessagesWidget] Message position: $messagePosition');
            debugPrint('📌 [PinnedMessagesWidget] Target position: $targetPosition');
            debugPrint('📌 [PinnedMessagesWidget] Final position: $finalPosition');
            
            controller.scrollController.animateTo(
              finalPosition,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
            
            debugPrint('📌 [PinnedMessagesWidget] Scroll animation started');
            
            // Mesajı highlight et
            controller.highlightMessage(messageId);
            
            // Mesajı vurgulamak için kısa bir gecikme sonrası tekrar scroll
            Future.delayed(Duration(milliseconds: 850), () {
              if (controller.scrollController.hasClients) {
                controller.scrollController.animateTo(
                  finalPosition,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
            
          } catch (e) {
            debugPrint('❌ [PinnedMessagesWidget] Scroll animation error: $e');
          }
        });
        
      } else {
        debugPrint('❌ [PinnedMessagesWidget] Message not found with ID: $messageId');
      }
    } catch (e) {
      debugPrint('❌ [PinnedMessagesWidget] Navigation error: $e');
    }
  }

  /// Group chat mesajına git
  void _navigateToGroupMessage(String messageId) {
    try {
      debugPrint('📌 [PinnedMessagesWidget] Navigating to group message: $messageId');
      
      final controller = Get.find<GroupChatDetailController>();
      
      // Mesajın index'ini bul
      final messageIndex = controller.messages.indexWhere((msg) => msg.id == messageId);
      
      if (messageIndex != -1) {
        debugPrint('📌 [PinnedMessagesWidget] Group message found at index: $messageIndex');
        
        // ScrollController'ın hazır olmasını bekle
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            // Güvenli şekilde ekran yüksekliğini al
            final screenHeight = _screenHeight ?? 800.0;
            
            // Mesajın pozisyonunu hesapla (her mesaj için yaklaşık 120px)
            final messagePosition = messageIndex * 120.0;
            
            // Mesajın ekranın orta alt kısmına gelmesi için hedef pozisyonu hesapla
            // Ekranın %70'ine kadar scroll et (alt kısımda kalsın)
            final targetPosition = messagePosition - (screenHeight * 0.3);
            
            // Negatif pozisyon olmaması için kontrol et
            final finalPosition = targetPosition < 0 ? 0.0 : targetPosition;
            
            
            controller.scrollController.animateTo(
              finalPosition,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
            
            debugPrint('📌 [PinnedMessagesWidget] Group scroll animation started');
            
            // Mesajı highlight et
            controller.highlightMessage(messageId);
            
            // Mesajı vurgulamak için kısa bir gecikme sonrası tekrar scroll
            Future.delayed(Duration(milliseconds: 850), () {
              if (controller.scrollController.hasClients) {
                controller.scrollController.animateTo(
                  finalPosition,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
            
          } catch (e) {
            debugPrint('❌ [PinnedMessagesWidget] Group scroll animation error: $e');
          }
        });
        
      } else {
        debugPrint('❌ [PinnedMessagesWidget] Group message not found with ID: $messageId');
      }
    } catch (e) {
      debugPrint('❌ [PinnedMessagesWidget] Group navigation error: $e');
    }
  }

  /// Private chat mesajının pinini kaldır
  void _unpinMessage(int messageId) async {
    try {
      
      final pinMessageService = Get.find<PinMessageService>();
      await pinMessageService.pinMessage(messageId);
      
      debugPrint('✅ [PinnedMessagesWidget] Private message unpinned successfully');
    } catch (e) {
      debugPrint('❌ [PinnedMessagesWidget] Unpin private message error: $e');
    }
  }

  /// Group chat mesajının pinini kaldır
  void _unpinGroupMessage(String messageId) async {
    try {
      
      final controller = Get.find<GroupChatDetailController>();
      final pinMessageService = Get.find<PinMessageService>();
      
      // Message ID'yi integer'a çevir
      final messageIdInt = int.tryParse(messageId);
      if (messageIdInt == null) {
        debugPrint('❌ [PinnedMessagesWidget] Invalid message ID: $messageId');
        return;
      }
      
      await pinMessageService.pinGroupMessage(messageIdInt, controller.currentGroupId.value);
      
      debugPrint('✅ [PinnedMessagesWidget] Group message unpinned successfully');
      } catch (e) {
      debugPrint('❌ [PinnedMessagesWidget] Unpin group message error: $e');
    }
  }
}
