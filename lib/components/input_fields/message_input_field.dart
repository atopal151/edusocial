import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/social/chat_detail_controller.dart';

final ChatDetailController controller = Get.put(ChatDetailController());

Widget buildMessageInputField() {
  TextEditingController messageController = TextEditingController();

  return Container(
    decoration: BoxDecoration(
        color: Color(0xfffafafa),
        borderRadius: BorderRadius.all(Radius.circular(15))),
    child: Row(
      children: [
        IconButton(
            icon: Icon(Icons.attach_file),
            iconSize: 18,
            color: Color(0xff9ca3ae),
            onPressed: () {}),
        Expanded(
          child: TextField(
            controller: messageController,
            decoration: InputDecoration(
              hintText: "Bir mesaj yazınız...",
              hintStyle: TextStyle(color: Color(0xff9ca3ae), fontSize: 13.28),
              border: InputBorder.none,
            ),
          ),
        ),
        IconButton(
            icon: Icon(Icons.document_scanner,
                size: 18, color: Color(0xff9ca3ae)),
            onPressed: () {}),
        IconButton(
            icon: Icon(Icons.camera_alt, color: Color(0xff9ca3ae), size: 18),
            onPressed: () {}),
        IconButton(
          icon: Container(
            width: 40,
            height:40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF7743),
                  Color(0xFFEF5050)
                ], // Linear gradient renkleri
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(15)),
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
            if (messageController.text.isNotEmpty) {
              controller.sendMessage(messageController.text);
              controller.scrollToBottom();
              messageController.clear();
            }
          },
        ),
      ],
    ),
  );
}
