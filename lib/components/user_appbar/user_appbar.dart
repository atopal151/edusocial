import 'package:edusocial/controllers/group_controller/group_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/appbar_controller.dart';

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarController controller = Get.put(AppBarController());
final GroupController groupController = Get.find<GroupController>();

  UserAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xffFAFAFA),
      surfaceTintColor: Color(0xffFAFAFA),
      elevation: 0,
      /*leading: GestureDetector(
        onTap: controller.navigateToProfile,
        child: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Obx(() {
              final imagePath = controller.profileImagePath.value;
              final isNetworkImage = imagePath.startsWith('http');

              return CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xffffffff),
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
            })),
      ),*/
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: controller.navigateToGroups,
                child: Container(
                  height: 44,
                  width: 44,
                  padding: EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    "images/icons/group_icon.svg",
                    colorFilter: ColorFilter.mode(
                      Color(0xff414751),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
             /* Positioned(
                top: -5,
                right: -5,
                child: Container(
                  height: 20,
                  width: 20,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '12',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),*/
            ],
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: controller.navigateToSearch,
          child: Container(
            height: 44,
            width: 44,
            padding: EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              "images/icons/search_icon.svg",
              colorFilter: ColorFilter.mode(
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
        GestureDetector(
          onTap: controller.navigateToEvent,
          child: Container(
            height: 44,
            width: 44,
            padding: EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              "images/icons/event.svg",
              colorFilter: ColorFilter.mode(
                Color(0xff414751),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
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
        SizedBox(width: 10),
      ],
    );
  }
}
