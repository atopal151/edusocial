import 'package:edusocial/utils/image_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/user_search_model.dart';

class UserListItem extends StatelessWidget {
  final UserSearchModel user;

  const UserListItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
            "Kullanıcı Seçildi", "${user.name} profiline yönlendiriliyor.");
      },
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: user.profileImage.isNotEmpty
                          ? NetworkImage(getFullAvatarUrl(user.profileImage))
                          : AssetImage('images/user1.png') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: user.isActive
                              ? Color(0xff4DD64B)
                              : Color(0xffd9d9d9),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${user.name} ${user.surname}',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff414751))),
                    Text('@${user.username}',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xff9CA3AE))),
                    /*Text("${user.university} - ${user.degree}",
                        style:
                            TextStyle(fontSize: 12, color: Color(0xff9CA3AE))),
                    Text(user.department,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Color(0xff9CA3AE))),*/
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
