import 'package:edusocial/components/buttons/primary_button.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../components/dialogs/logout_dialog.dart';
import '../../components/user_appbar/back_appbar.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final ProfileController controller = Get.find();
  @override
  Widget build(BuildContext context) {
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
              text: "Profili Düzenle",
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
              text: "Gizlilik Politikası",
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
              text: "Bildirim Ayarları",
              onPressed: () {},
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
              text: "Çıkış Yap",
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
            )
          ],
        ),
      ),
    );
  }
}
