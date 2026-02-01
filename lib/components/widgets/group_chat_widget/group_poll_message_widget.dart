import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../models/chat_models/group_message_model.dart';
import '../../../controllers/chat_controllers/group_chat_detail_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../verification_badge.dart';

class GroupPollMessageWidget extends StatelessWidget {
  final GroupMessageModel message;
  final GroupChatDetailController controller;

  const GroupPollMessageWidget({
    super.key, 
    required this.message,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: message.isSentByMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // 🔹 Kullanıcı Bilgileri (Saat kaldırıldı)
        Row(
          mainAxisAlignment: message.isSentByMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!message.isSentByMe)
              InkWell(
                onTap: () {
                  final ProfileController profileController = Get.find<ProfileController>();
                  profileController.getToPeopleProfileScreen(message.username);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 6.0),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: (message.profileImage.isNotEmpty &&
                            !message.profileImage.endsWith('/0'))
                        ? NetworkImage(message.profileImage)
                        : null,
                    child: (message.profileImage.isEmpty ||
                            message.profileImage.endsWith('/0'))
                        ? const Icon(Icons.person, color: Colors.white, size: 14)
                        : null,
                  ),
                ),
              ),
      
            InkWell(
              onTap: () {
                final ProfileController profileController = Get.find<ProfileController>();
                profileController.getToPeopleProfileScreen(message.username);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '@${message.username}',
                    style: const TextStyle(fontSize: 10, color: Color(0xff414751)),
                  ),
                  const SizedBox(width: 4),
                  VerificationBadge(
                    isVerified: message.isVerified,
                    size: 12,
                  ),
                ],
              ),
            ),
            

            if (message.isSentByMe)
              InkWell(
                onTap: () {
                  final ProfileController profileController = Get.find<ProfileController>();
                  profileController.getToPeopleProfileScreen(message.username);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 6.0, right: 8.0),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: (message.profileImage.isNotEmpty &&
                            !message.profileImage.endsWith('/0'))
                        ? NetworkImage(message.profileImage)
                        : null,
                    child: (message.profileImage.isEmpty ||
                            message.profileImage.endsWith('/0'))
                        ? const Icon(Icons.person, color: Colors.white, size: 14)
                        : null,
                  ),
                ),
              ),
          ],
        ),
        // 🔹 Mesaj Balonu (Private Chat Tasarımı)
        Padding(
          padding: EdgeInsets.only(
            left: message.isSentByMe ? 48.0 : 30.0,
            right: message.isSentByMe ? 30.0 : 48.0,
            top: 2.0,
            bottom: 4.0,
          ),
          child: Align(
            alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isSentByMe 
                    ? const Color(0xFFff7c7c) // Kırmızı
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(18),
                  bottomRight: const Radius.circular(18),
                  topLeft: message.isSentByMe 
                      ? const Radius.circular(18) 
                      : const Radius.circular(4),
                  topRight: message.isSentByMe 
                      ? const Radius.circular(4) 
                      : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poll content placeholder
                  Text(
                    message.content,
                    style: GoogleFonts.inter(
                      color: message.isSentByMe ? Colors.white : const Color(0xff000000),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Saat bilgisi mesaj balonunun içinde sağ altta
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          color: message.isSentByMe 
                              ? Colors.white.withValues(alpha: 0.8)
                              : const Color(0xff8E8E93),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    try {
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '';
    }
  }
}
