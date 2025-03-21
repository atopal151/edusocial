import 'package:flutter/material.dart';
import '../../controllers/search_text_controller.dart';
import 'package:get/get.dart';

class GroupListItem extends StatelessWidget {
  final GroupModel group;

  const GroupListItem({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.snackbar("Grup Seçildi", "${group.name} grubuna yönlendiriliyor.");
      },
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 6),
        height: 106, // Yüksekliği artırdım
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none, // Taşmaları kontrol etmek için
              alignment: Alignment.bottomCenter,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(group.image),
                  radius: 30,
                ),
                Positioned(
                  bottom: -20, // Daha görünür olması için yukarı kaydırdım
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, color: Color(0xffEF5050), size: 14),
                      SizedBox(width: 4),
                      Text(
                        "${group.memberCount}",
                        style: TextStyle(color: Color(0xff414751), fontSize: 13.28,fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start, // Ortaya hizaladım
                children: [
                  Text(
                    group.name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color:Color(0xff414751)),
                  ),
                  SizedBox(height: 4), // Boşluk ekledim
                  Text(
                    group.description,
                    
                    style: TextStyle(fontSize: 12,color: Color(0xff9CA3AE)),
                    maxLines: 2, // Çok uzun açıklamalarda taşmayı önlemek için
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
