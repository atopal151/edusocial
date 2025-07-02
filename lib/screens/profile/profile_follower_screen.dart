import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/screens/profile/people_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/language_service.dart';

class ProfileFollowerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> followers;
  final String screenTitle;
  
  const ProfileFollowerScreen({
    super.key, 
    required this.followers,
    this.screenTitle = '',
  });

  @override
  State<ProfileFollowerScreen> createState() => _ProfileFollowerScreenState();
}

class _ProfileFollowerScreenState extends State<ProfileFollowerScreen> {
  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(
        title: widget.screenTitle.isEmpty 
            ? languageService.tr("profile.followers.title")
            : widget.screenTitle,
        backgroundColor: Color(0xfffafafa),
        iconBackgroundColor: Color(0xffffffff),
      ),
      body: ListView.builder(
        itemCount: widget.followers.length,
        itemBuilder: (context, index) {
          final user = widget.followers[index];
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
              '${user["name"]} ${user["surname"]}',
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
                languageService.tr("profile.followers.sendMessage"),
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
