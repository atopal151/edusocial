import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../models/chat_models/chat_detail_model.dart';
import '../../models/chat_models/group_message_model.dart';
import '../../controllers/chat_controllers/chat_detail_controller.dart';
import '../../controllers/chat_controllers/group_chat_detail_controller.dart';

class PinnedMessagesWidget extends StatelessWidget {
  final bool isGroupChat;

  const PinnedMessagesWidget({
    super.key,
    required this.isGroupChat,
  });

  @override
  Widget build(BuildContext context) {
    if (isGroupChat) {
      return _buildGroupPinnedMessages();
    } else {
      return _buildPrivatePinnedMessages();
    }
  }

  Widget _buildPrivatePinnedMessages() {
    return GetBuilder<ChatDetailController>(
      builder: (controller) {
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
      },
    );
  }

  Widget _buildGroupPinnedMessages() {
    return GetBuilder<GroupChatDetailController>(
      builder: (controller) {
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
      },
    );
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
