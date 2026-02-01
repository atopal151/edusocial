import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../models/chat_models/chat_detail_model.dart';
import '../../models/chat_models/group_message_model.dart';
import '../../controllers/chat_controllers/chat_detail_controller.dart';
import '../../controllers/chat_controllers/group_chat_detail_controller.dart';
import '../../services/pin_message_service.dart';
import '../../services/socket_services.dart';
import '../../services/language_service.dart';
import 'dart:async';
import 'dart:math' as math;

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
  final LanguageService _languageService = Get.find<LanguageService>();
  StreamSubscription? _pinUpdateSubscription;
  Timer? _refreshTimer;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _setupPinUpdateListener();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _pinUpdateSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _setupPinUpdateListener() {
    try {
      final socketService = Get.find<SocketService>();
      
      _pinUpdateSubscription = socketService.onPinMessage.listen((data) {
        if (mounted) {
          debugPrint('📌 [PinnedMessagesWidget] Pin update event received: $data');
          _forceWidgetRefresh();
        }
      });
    } catch (e) {
      debugPrint('❌ [PinnedMessagesWidget] Pin update listener setup error: $e');
    }
  }

  void _forceWidgetRefresh() {
    if (mounted) {
      setState(() {});
    }
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
        final pinnedMessages = controller.messages.where((msg) => msg.isPinned).toList();

        if (pinnedMessages.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                Icon(Icons.push_pin, size: 16, color: Color(0xff9ca3ae)),
                SizedBox(width: 8),
                Text(
                  _languageService.tr('groups.pinnedMessages.emptyState'),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff9ca3ae),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _languageService.tr('groups.pinnedMessages.title'),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff414751),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${pinnedMessages.length}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xff9ca3ae),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_isExpanded)
                ...pinnedMessages.map((message) => _buildPinnedMessageItem(message))
              else
                ...pinnedMessages.take(1).map((message) => _buildPinnedMessageItem(message)),
              
              if (pinnedMessages.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
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
                              ? _languageService.tr('groups.pinnedMessages.showLess')
                              : '${pinnedMessages.length - 1} ${_languageService.tr('groups.pinnedMessages.showMore')}',
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
      final pinnedMessages = controller.messages.where((msg) => msg.isPinned).toList();

      if (pinnedMessages.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white),
          child: Row(
            children: [
              Icon(Icons.push_pin, size: 16, color: Color(0xff9ca3ae)),
              SizedBox(width: 8),
              Text(
                _languageService.tr('groups.pinnedMessages.emptyState'),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff9ca3ae),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _languageService.tr('groups.pinnedMessages.title'),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff414751),
                  ),
                ),
                const Spacer(),
                Text(
                  '${pinnedMessages.length}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xff9ca3ae),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isExpanded)
              ...pinnedMessages.map((message) => _buildGroupPinnedMessageItem(message))
            else
              ...pinnedMessages.take(1).map((message) => _buildGroupPinnedMessageItem(message)),
            
            if (pinnedMessages.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
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
                            ? _languageService.tr('groups.pinnedMessages.showLess')
                            : '${pinnedMessages.length - 1} ${_languageService.tr('groups.pinnedMessages.showMore')}',
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
          ],
        ),
      );
    });
  }

  Widget _buildPinnedMessageItem(MessageModel message) {
    final profileImage = message.senderAvatarUrl;
    final name = message.sender.name;
    final surname = message.sender.surname;
    final displayName = '$name $surname'.trim();
    final content = message.message;
    final timestamp = DateTime.tryParse(message.createdAt) ?? DateTime.now();

    return Tooltip(
      message: _languageService.tr('groups.pinnedMessages.navigateToMessage'),
      child: GestureDetector(
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
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
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
                      displayName.isNotEmpty ? displayName : '@${message.sender.username}',
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
              Tooltip(
                message: _languageService.tr('groups.pinnedMessages.unpinMessage'),
                child: GestureDetector(
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
      ),
    );
  }

  Widget _buildGroupPinnedMessageItem(GroupMessageModel message) {
    final name = message.name;
    final surname = message.surname;
    final displayName = '$name $surname'.trim();
    final content = message.content;
    final timestamp = message.timestamp;
    final controller = Get.find<GroupChatDetailController>();

    return Tooltip(
      message: _languageService.tr('groups.pinnedMessages.navigateToMessage'),
      child: GestureDetector(
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
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
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
                      displayName.isNotEmpty ? displayName : '@${message.username}',
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
              if (controller.isCurrentUserAdmin)
                Tooltip(
                  message: _languageService.tr('groups.pinnedMessages.unpinMessage'),
                  child: GestureDetector(
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
      ),
    );
  }

  void _navigateToMessage(int messageId) {
    try {
      final controller = Get.find<ChatDetailController>();
      final messageIndex = controller.messages.indexWhere((msg) => msg.id == messageId);
      
      if (messageIndex != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            final messagePosition = messageIndex * 100.0;
            final screenHeight = MediaQuery.of(context).size.height;
            final targetPosition = messagePosition - (screenHeight * 0.3);
            final finalPosition = math.max(0, targetPosition).toDouble();
            
            controller.scrollController.animateTo(
              finalPosition,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
            
            controller.highlightMessage(messageId);
          } catch (e) {
            debugPrint('❌ [PinnedMessagesWidget] Scroll animation error: $e');
          }
        });
      }
    } catch (e) {
      debugPrint('❌ [PinnedMessagesWidget] Navigation error: $e');
    }
  }

  void _navigateToGroupMessage(String messageId) {
    try {
      final controller = Get.find<GroupChatDetailController>();
      final messageIndex = controller.messages.indexWhere((msg) => msg.id == messageId);
      
      if (messageIndex != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            final messagePosition = messageIndex * 100.0;
            final screenHeight = MediaQuery.of(context).size.height;
            final targetPosition = messagePosition - (screenHeight * 0.3);
            final finalPosition = math.max(0, targetPosition).toDouble();
            
            controller.scrollController.animateTo(
              finalPosition,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
            
            controller.highlightMessage(messageId);
          } catch (e) {
            debugPrint('❌ [PinnedMessagesWidget] Group scroll animation error: $e');
          }
        });
      }
    } catch (e) {
      debugPrint('❌ [PinnedMessagesWidget] Group navigation error: $e');
    }
  }

  void _unpinMessage(int messageId) async {
    try {
      final pinService = Get.find<PinMessageService>();
      final success = await pinService.pinMessage(messageId);
      
      if (success) {
        _forceWidgetRefresh();
      }
    } catch (e) {
      debugPrint('❌ [PinnedMessagesWidget] Unpin private message error: $e');
    }
  }

  void _unpinGroupMessage(String messageId) async {
    try {
      if (messageId.isEmpty) return;
      
      final pinService = Get.find<PinMessageService>();
      final controller = Get.find<GroupChatDetailController>();
      final groupId = controller.currentGroupId.value;
      
      final success = await pinService.pinGroupMessage(int.tryParse(messageId) ?? 0, groupId);
      
      if (success) {
        _forceWidgetRefresh();
      }
    } catch (e) {
      debugPrint('❌ [PinnedMessagesWidget] Unpin group message error: $e');
    }
  }
}
