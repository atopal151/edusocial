import 'package:edusocial/controllers/comment_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../services/language_service.dart';

Widget buildCommentInputField(CommentController commentController,
    String postId, TextEditingController messageController, [VoidCallback? onCommentAdded]) {
  final LanguageService languageService = Get.find<LanguageService>();
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xfffafafa),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: messageController,
            textInputAction: TextInputAction.send,
            enableSuggestions: true,
            autocorrect: true,
            decoration: InputDecoration(
              hintText: languageService.tr("comments.input.placeholder"),
              hintStyle: TextStyle(color: Color(0xff9ca3ae), fontSize: 13.28),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            minLines: 1,
            maxLines: 4,
            onSubmitted: (value) async {
              if (value.trim().isNotEmpty && !commentController.isLoading.value) {
                await commentController.addComment(postId, value);
                messageController.clear();
                if (onCommentAdded != null) {
                  onCommentAdded();
                }
              }
            },
          ),
        ),
        Obx(() => IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF7743), Color(0xFFEF5050)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: commentController.isLoading.value
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : SvgPicture.asset(
                    'images/icons/send_icon.svg',
                    width: 16,
                    height: 16,
                  ),
          ),
          onPressed: commentController.isLoading.value
              ? null
              : () async {
                  final text = messageController.text.trim();
                  if (text.isNotEmpty) {
                    await commentController.addComment(postId, text);
                    messageController.clear();
                    if (onCommentAdded != null) {
                      onCommentAdded();
                    }
                  }
                },
        )),
      ],
    ),
  );
}
