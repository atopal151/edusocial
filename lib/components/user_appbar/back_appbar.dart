import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/appbar_controller.dart';

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarController controller = Get.put(AppBarController());

  BackAppBar({super.key});

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
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Color(0xffFAFAFA)),
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: SvgPicture.asset(
                'images/icons/back_icon.svg',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
