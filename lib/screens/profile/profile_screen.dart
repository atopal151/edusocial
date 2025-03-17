import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/appbar_controller.dart';
//import 'package:flutter_svg/flutter_svg.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppBarController controller = Get.put(AppBarController());

  @override
  Widget build(BuildContext context) {
    bool isNavigatedFromRoute = Get.previousRoute.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Color(0xffffffff), 
        backgroundColor: Color(0xffffffff),
        leading: isNavigatedFromRoute
            ? BackAppBar()
            : null,
        actions: [
          InkWell(
            onTap: controller.navigateToProfile,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xffFAFAFA),
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SvgPicture.asset(
                    'images/icons/settings_icon.svg',
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      backgroundColor: const Color(0xffffffff),
      body: const Center(
        child: Text("Profile"),
      ),
    );
  }
}
