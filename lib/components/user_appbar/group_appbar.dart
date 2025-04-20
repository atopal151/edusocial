import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/appbar_controller.dart';

class GroupAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarController controller = Get.put(AppBarController());

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
              child: Obx(() => CircleAvatar(
                    backgroundImage:
                        AssetImage(controller.profileImagePath.value),
                    radius: 20,
                  )),
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
