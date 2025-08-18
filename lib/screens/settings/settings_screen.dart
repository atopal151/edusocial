import 'package:edusocial/components/buttons/primary_button.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../components/dialogs/logout_dialog.dart';
import '../../components/user_appbar/back_appbar.dart';
import '../../services/language_service.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final ProfileController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(
        iconBackgroundColor: Color(0xffffffff),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PrimaryButton(
              text: languageService.tr("settings.buttons.editProfile"),
              onPressed: () {
                controller.getToSettingScreen();
              },
              backgroundColor: Color(0xffffffff),
              textColor: Color(0xff414751),
              icon: SvgPicture.asset(
                "images/icons/profile_edit_icon.svg",
                colorFilter: ColorFilter.mode(
                  Color(0xff9ca3ae),
                  BlendMode.srcIn,
                ),
              ),
              iconColor: Color(0xffc8cdd5),
            ),
            SizedBox(
              height: 6,
            ),
            PrimaryButton(
              text: languageService.tr("settings.buttons.privacyPolicy"),
              onPressed: () {},
              backgroundColor: Color(0xffffffff),
              textColor: Color(0xff414751),
              icon: SvgPicture.asset(
                "images/icons/lock.svg",
                colorFilter: ColorFilter.mode(
                  Color(0xff9ca3ae),
                  BlendMode.srcIn,
                ),
              ),
              iconColor: Color(0xffc8cdd5),
            ),
            SizedBox(
              height: 6,
            ),
            PrimaryButton(
              text: languageService.tr("settings.buttons.notificationSettings"),
              onPressed: () {
                Get.toNamed('/notification_settings');
              },
              backgroundColor: Color(0xffffffff),
              textColor: Color(0xff414751),
              icon: SvgPicture.asset(
                "images/icons/notification_group.svg",
                colorFilter: ColorFilter.mode(
                  Color(0xff9ca3ae),
                  BlendMode.srcIn,
                ),
              ),
              iconColor: Color(0xffc8cdd5),
            ),
            SizedBox(
              height: 6,
            ),
           
            PrimaryButton(
              text: languageService.tr("verification.title"),
              onPressed: () {
                Get.toNamed('/verification');
              },
              backgroundColor: Color(0xffffffff),
              textColor: Color(0xff414751),
              icon: Icon(
                Icons.verified_user,
                color:Color(0xff9ca3ae),
                size: 18,
              ),
              iconColor: Color(0xffc8cdd5),
            ),
            SizedBox(
              height: 6,
            ),
            PrimaryButton(
              text: languageService.tr("settings.buttons.logout"),
              onPressed: () {
                LogoutDialogs.showLogoutDialog();
              },
              backgroundColor: Color(0xffffffff),
              textColor: Color(0xff414751),
              icon: SvgPicture.asset(
                "images/icons/logout.svg",
                colorFilter: ColorFilter.mode(
                  Color(0xffef5050),
                  BlendMode.srcIn,
                ),
              ),
              iconColor: Color(0xffef5050),
            ),
          ],
        ),
      ),
    );
  }
}
