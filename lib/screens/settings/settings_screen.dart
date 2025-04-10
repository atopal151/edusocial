import 'package:edusocial/components/buttons/primary_button.dart';
import 'package:edusocial/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/user_appbar/back_appbar.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final SettingsController controller = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(iconBackgroundColor: Color(0xffffffff),),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PrimaryButton(
              text: "Profili Düzenle",
              onPressed: () {},
              backgroundColor: Color(0xffffffff),
              textColor: Color(0xff414751),
              icon: Icons.person,
              iconColor: Color(0xffc8cdd5),
            ),
            SizedBox(height:6,),
             PrimaryButton(
              text: "Gizlilik Politikası",
              onPressed: () {},
              backgroundColor: Color(0xffffffff),
              textColor: Color(0xff414751),
              icon: Icons.security,
              iconColor: Color(0xffc8cdd5),
            ),

            SizedBox(height:6,),
             PrimaryButton(
              
              text: "Bildirim Ayarları",
              onPressed: () {},
              backgroundColor: Color(0xffffffff),
              textColor: Color(0xff414751),
              icon: Icons.notifications,
              iconColor: Color(0xffc8cdd5),
            ),
             SizedBox(height:6,),
             PrimaryButton(
              text: "Çıkış Yap",
              onPressed: () {},
              backgroundColor: Color(0xffffffff),
              textColor: Color(0xff414751),
              icon: Icons.logout,
              iconColor: Color(0xffef5050),
            )
          ],
        ),
      ),
    );
  }
}
