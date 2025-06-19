import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/social/group_chat_detail_controller.dart';

final GroupChatDetailController controller = Get.find();

Widget buildGroupMessageInputField() {
  TextEditingController messageController = TextEditingController();

  return Container(
    decoration: BoxDecoration(
        color: Color(0xffffffff),
        borderRadius: BorderRadius.all(Radius.circular(15))),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Seçilen dosyaların önizlemesi
        Obx(() {
          if (controller.selectedFiles.isNotEmpty) {
            return Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  // Seçilen dosyalar
                  ...controller.selectedFiles.map((file) => Container(
                    margin: EdgeInsets.only(bottom: 4),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xfff5f5f5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_file, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            file.path.split('/').last,
                            style: TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 16),
                          onPressed: () {
                            controller.selectedFiles.remove(file);
                          },
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        }),
        // Ana input alanı
        Container(
          decoration: BoxDecoration(
              color: Color(0xfffafafa),
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: controller.isSendingMessage.value
                      ? null
                      : () {
                          controller.pickDocument();
                        },
                  child: SvgPicture.asset(
                    "images/icons/selected_document.svg",
                    colorFilter: ColorFilter.mode(
                      controller.isSendingMessage.value 
                          ? Color(0xffe5e5e5) 
                          : Color(0xffc9c9c9),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() => TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: controller.selectedFiles.isNotEmpty 
                        ? "Dosya seçildi. Mesaj yazabilir veya direkt gönderebilirsiniz..."
                        : "Bir mesaj yazınız... (Linkler otomatik algılanır)",
                    hintStyle: TextStyle(color: Color(0xff9ca3ae), fontSize: 13.28),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) async {
                    if (value.isNotEmpty || controller.selectedFiles.isNotEmpty) {
                      await controller.sendMessage(value);
                      messageController.clear();
                    }
                  },
                )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: controller.isSendingMessage.value
                      ? null
                      : () {
                          controller.openPollBottomSheet();
                        },
                  child: SvgPicture.asset(
                    "images/icons/poll_icon.svg",
                    colorFilter: ColorFilter.mode(
                      controller.isSendingMessage.value 
                          ? Color(0xffe5e5e5) 
                          : Color(0xffc9c9c9),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: controller.isSendingMessage.value
                      ? null
                      : () {
                          controller.pickImageFromGallery();
                        },
                  child: SvgPicture.asset(
                    "images/icons/camera.svg",
                    colorFilter: ColorFilter.mode(
                      controller.isSendingMessage.value 
                          ? Color(0xffe5e5e5) 
                          : Color(0xffc9c9c9),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              Obx(() => IconButton(
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFF7743),
                        Color(0xFFEF5050)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Center(
                    child: controller.isSendingMessage.value
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : SvgPicture.asset(
                            'images/icons/send_icon.svg',
                            width: 18,
                            height: 18,
                          ),
                  ),
                ),
                onPressed: controller.isSendingMessage.value
                    ? null
                    : () async {
                        if (messageController.text.isNotEmpty || 
                            controller.selectedFiles.isNotEmpty) {
                          await controller.sendMessage(messageController.text);
                          messageController.clear();
                        }
                      },
              )),
            ],
          ),
        ),
      ],
    ),
  );
}
