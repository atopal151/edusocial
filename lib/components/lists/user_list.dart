import 'package:flutter/material.dart';
import '../../controllers/search_text_controller.dart';
import 'package:get/get.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;

  const UserListItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.snackbar("Kullanıcı Seçildi", "${user.name} profiline yönlendiriliyor.");
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
                      backgroundImage: AssetImage(user.profileImage),
                      radius: 24,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: user.isOnline ? Color(0xff4DD64B) : Color(0xffd9d9d9),
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
                    Text(user.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color:Color(0xff414751))),
                    Text("${user.university} - ${user.degree}", style: TextStyle(fontSize: 12,color:Color(0xff9CA3AE))),
                    Text(user.department, style: TextStyle(fontSize: 12,color:Color(0xff9CA3AE))),
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