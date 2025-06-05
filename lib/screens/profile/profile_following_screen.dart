import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/screens/profile/people_profile_screen.dart';
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
        title: 'Takip edilen',
        backgroundColor: Color(0xfffafafa),
        iconBackgroundColor: Color(0xffffffff),
      ),
      body: Obx(() => ListView.builder(
            itemCount: controller.followingList.length,
            itemBuilder: (context, index) {
              final user = controller.followingList[index];
              return ListTile(
                onTap: () {
                  Get.to(() => PeopleProfileScreen(
                      username: user['username'])); // ✅ burada userId eklenmeli
                },
                leading: CircleAvatar(
                  backgroundColor: Color(0xffffffff),
                  backgroundImage: NetworkImage(user["avatar_url"] ?? ''),
                ),
                title: Text(
                  '${user["name"]} ${user["surname"]} ',
                  style: TextStyle(
                      fontSize: 13.28,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff414751)),
                ),
                subtitle: Text(
                  '@${user["username"]}',
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
