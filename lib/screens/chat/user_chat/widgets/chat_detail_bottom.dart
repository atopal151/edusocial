import 'package:edusocial/controllers/chat_controllers/chat_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/language_service.dart';

class ChatDetailBottom extends StatelessWidget {
  const ChatDetailBottom({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatDetailController>();
    final textController = TextEditingController();
    final LanguageService languageService = Get.find<LanguageService>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xffffffff),
        border: Border(
          top: BorderSide(
            color: Color(0xfff5f6f7),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: languageService.tr("chat.messageInput.placeholder"),
                hintStyle: const TextStyle(
                  color: Color(0xff9ca3ae),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    color: Color(0xfff5f6f7),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    color: Color(0xfff5f6f7),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    color: Color(0xfff5f6f7),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  chatController.sendMessage(text);
                  textController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xffef5050),
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  chatController.sendMessage(textController.text);
                  textController.clear();
                }
              },
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 