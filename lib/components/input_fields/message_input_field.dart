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
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Görsel önizleme alanı
        Obx(() {
          if (controller.selectedImage.value != null) {
            return Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          controller.selectedImage.value!,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            controller.selectedImage.value = null;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        }),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  controller.pickDocument();
                },
                child: SvgPicture.asset(
                  "images/icons/selected_document.svg",
                  colorFilter: const ColorFilter.mode(
                    Color(0xffc9c9c9),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: "Bir mesaj yazınız...",
                  hintStyle:
                      TextStyle(color: Color(0xff9ca3ae), fontSize: 13.28),
                  border: InputBorder.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  controller.openPollBottomSheet();
                },
                child: SvgPicture.asset(
                  "images/icons/poll_icon.svg",
                  colorFilter: const ColorFilter.mode(
                    Color(0xffc9c9c9),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  controller.pickImageFromGallery();
                },
                child: SvgPicture.asset(
                  "images/icons/camera.svg",
                  colorFilter: const ColorFilter.mode(
                    Color(0xffc9c9c9),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF7743), Color(0xFFEF5050)],
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
                  messageController.clear();
                }
              },
            ),
          ],
        ),
      ],
    ),
  );
}
