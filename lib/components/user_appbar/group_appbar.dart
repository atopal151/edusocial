import 'package:flutter/material.dart';
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /*GestureDetector(
            onTap: controller.navigateToProfile,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Obx(() => CircleAvatar(
                    backgroundImage:
                        AssetImage(controller.profileImagePath.value),
                    radius: 20,
                  )),
            ),
          ),
          */
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
            Icon(Icons.search,size: 22,color: Color(0xff414751))
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
