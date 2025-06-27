import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/screens/profile/people_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class ProfileFollowingScreen extends StatefulWidget {
  final List<Map<String, dynamic>> followings;
  final String screenTitle;
  
  const ProfileFollowingScreen({
    super.key, 
    required this.followings,
    this.screenTitle = 'Takip edilen',
  });

  @override
  State<ProfileFollowingScreen> createState() => _ProfileFollowingScreenState();
}

class _ProfileFollowingScreenState extends State<ProfileFollowingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(
        title: widget.screenTitle,
        backgroundColor: Color(0xfffafafa),
        iconBackgroundColor: Color(0xffffffff),
      ),
      body: ListView.builder(
        itemCount: widget.followings.length,
        itemBuilder: (context, index) {
          final user = widget.followings[index];
          return ListTile(
            onTap: () {
              Get.to(() => PeopleProfileScreen(
                  username: user['username']));
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
              onPressed: () {
                // Mesaj gönderme ekranına yönlendirme
                Get.toNamed(Routes.chatDetail, arguments: {
                  'userId': user['id'],
                  'conversationId': null, // Yeni konuşma başlatılacak
                  'name': '${user["name"]} ${user["surname"]}',
                  'username': user["username"],
                  'avatarUrl': user["avatar_url"] ?? '',
                  'isOnline': false, // Varsayılan olarak çevrimdışı
                });
              },
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
      ),
    );
  }
}
