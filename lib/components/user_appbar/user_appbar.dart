import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/appbar_controller.dart';

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarController controller = Get.put(AppBarController());

  UserAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xffFAFAFA),
      surfaceTintColor: Color(0xffFAFAFA),
      elevation: 0,
      leading: GestureDetector(
        onTap: controller.navigateToProfile,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: Obx(() => CircleAvatar(
                backgroundImage: AssetImage(controller.profileImagePath.value),
                radius: 20,
              )),
        ),
      ),
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
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: /*SvgPicture.asset(
                          'images/icons/group_icon.svg',
                          width: 20,
                          height: 17,
                        ),*/
                        Icon(
                      Icons.group_outlined,
                      size: 22,
                      color: Color(0xff414751),
                    )),
              ),
              Positioned(
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
              ),
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
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: /*SvgPicture.asset(
              'images/icons/search_icon.svg',
              width: 16,
              height: 16,
            ),*/
                  Icon(Icons.search, size: 22, color: Color(0xff414751))),
        ),
        SizedBox(width: 10),
        GestureDetector(
          onTap: controller.navigateToCalendar,
          child: Container(
              height: 44,
              width: 44,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: /*SvgPicture.asset(
              'images/icons/notification_icon.svg',
              width: 16,
              height: 22.76,
            ),*/
                  Icon(Icons.calendar_month_outlined,
                      size: 22, color: Color(0xff414751))),
        ),
        SizedBox(width: 10),
        GestureDetector(
          onTap: controller.navigateToEvent,
          child: Container(
              height: 44,
              width: 44,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: /*SvgPicture.asset(
              'images/icons/notification_icon.svg',
              width: 16,
              height: 22.76,
            ),*/
                  Icon(Icons.notifications_outlined,
                      size: 22, color: Color(0xff414751))),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
