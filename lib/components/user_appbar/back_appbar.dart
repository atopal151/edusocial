import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/appbar_controller.dart';

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarController controller = Get.put(AppBarController());
  
  final String title;
  final Color backgroundColor;
  final Color iconBackgroundColor;

  BackAppBar({
    super.key,
    this.backgroundColor = const Color(0xffFAFAFA),
    this.iconBackgroundColor = const Color(0xffFAFAFA),  this.title= "",
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      elevation: 0,
      title: Align(alignment: Alignment.bottomLeft, child: Text(title,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Color(0xff272727)),)),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBackgroundColor,
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
    );
  }
}
