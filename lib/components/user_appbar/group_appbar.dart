import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/appbar_controller.dart';
import '../../controllers/notification_controller.dart';

class GroupAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarController controller = Get.put(AppBarController());
  final NotificationController notificationController = Get.find<NotificationController>();

  GroupAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xffFAFAFA),
      surfaceTintColor: Color(0xffFAFAFA),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: SvgPicture.asset(
                'images/icons/back_icon.svg',
              ),
            ),
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Obx(() {
              final imagePath = controller.profileImagePath.value;
              final isNetworkImage = imagePath.startsWith('http');

              return CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                child: (imagePath.isEmpty || imagePath == 'null')
                    ? null
                    : ClipOval(
                        child: isNetworkImage
                            ? Image.network(
                                imagePath,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint("⚠️ Görsel yüklenemedi: $error",
                                      wrapWidth: 1024);
                                  return const SizedBox.shrink();
                                  // Yüklenemediğinde de sadece gri daire kalır
                                },
                              )
                            : Image.asset(
                                imagePath,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                      ),
              );
            })
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: controller.navigateToSearch,
          child: Container(
            height: 44,
            width: 44,
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              "images/icons/search_icon.svg",
              colorFilter: const ColorFilter.mode(
                Color(0xff414751),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        GestureDetector(
          onTap: controller.navigateToCalendar,
          child: Container(
            height: 44,
            width: 44,
            padding: EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              "images/icons/calendar_icon.svg",
              colorFilter: ColorFilter.mode(
                Color(0xff414751),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: controller.navigateToNotifications,
              child: Container(
                height: 44,
                width: 44,
                padding: EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  "images/icons/notification_icon.svg",
                  colorFilter: ColorFilter.mode(
                    Color(0xff414751),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
                         // Bildirim badge'i - Sadece kırmızı nokta
             Obx(() {
               final unreadCount = notificationController.unreadCount.value;
               if (unreadCount > 0) {
                return Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 12,
                    height:12,
                    decoration: BoxDecoration(
                      color: Color(0xFFEF5050),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }),
          ],
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
