import 'package:edusocial/controllers/social/chat_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatDetailAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatDetailController>();
    final userChatDetail = chatController.userChatDetail.value;

    return AppBar(
      backgroundColor: const Color(0xfffafafa),
      surfaceTintColor: const Color(0xfffafafa),
      leading: Center(
        child: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xffffffff),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.arrow_back_ios,
                size: 18,
                color: Color(0xff414751),
              ),
            ),
          ),
        ),
      ),
      title: userChatDetail != null
          ? Text(
              userChatDetail.name,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xff414751),
              ),
            )
          : null,
      actions: [
        InkWell(
          onTap: () {
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xffffffff),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.more_vert,
                color: Color(0xff414751),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 