import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';

class ProfileFollowingScreen extends StatefulWidget {
  const ProfileFollowingScreen({super.key});

  @override
  State<ProfileFollowingScreen> createState() => _ProfileFollowingScreenState();
}

class _ProfileFollowingScreenState extends State<ProfileFollowingScreen> {
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(
        backgroundColor: Color(0xfffafafa),
        iconBackgroundColor: Color(0xffffffff),
      ),
      body: Obx(() => ListView.builder(
            itemCount: controller.followingList.length,
            itemBuilder: (context, index) {
              final user = controller.followingList[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user["avatarUrl"] ?? ''),
                ),
                title: Text(
                  user["fullName"] ?? '',
                  style: TextStyle(
                      fontSize: 13.28,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff414751)),
                ),
                subtitle: Text(
                  user["username"] ?? '',
                  style: TextStyle(
                      fontSize: 13.28,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff9ca3ae)),
                ),
                trailing: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xfff0f1f3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Mesaj Gönder",
                     style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff414751)),
                  ),
                ),
              );
            },
          )),
    );
  }
}
