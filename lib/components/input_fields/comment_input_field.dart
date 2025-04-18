import 'package:edusocial/controllers/comment_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget buildCommentInputField(CommentController commentController) {
  TextEditingController messageController = TextEditingController();

  return Container(
    decoration: BoxDecoration(
        color: const Color(0xfffafafa),
        borderRadius: BorderRadius.circular(15)),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: messageController,
            decoration: const InputDecoration(
              hintText: "Yorum yaz...",
              hintStyle: TextStyle(color: Color(0xff9ca3ae), fontSize: 13.28),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
            minLines: 1,
            maxLines: 4,
          ),
        ),
        IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7743), Color(0xFFEF5050)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: SvgPicture.asset(
                'images/icons/send_icon.svg',
                width: 18,
                height: 18,
              ),
            ),
          ),
          onPressed: () {
            if (messageController.text.trim().isNotEmpty) {
              commentController.addComment(messageController.text.trim());
              messageController.clear();
            }
          },
        ),
      ],
    ),
  );
}
