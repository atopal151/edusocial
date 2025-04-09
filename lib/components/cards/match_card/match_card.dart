import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../controllers/social/match_controller.dart';

class MatchCard extends StatefulWidget {
  const MatchCard({super.key});

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  final MatchController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final match = controller.currentMatch;
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 40, bottom: 40),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                    height: 30), // Profil fotoğrafı için boşluk bırak
                Center(
                  child: Text(
                    "${match.name}, ${match.age}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),
                // Eğitim Bilgisi
                Text(
                  "Eğitim",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        width: 39,
                        height: 39,
                        decoration: BoxDecoration(
                            color: Color(0xffF6F6F6),
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Image.network(match.schoolLogo,
                                width: 21, height: 21),
                          ),
                        )),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(match.schoolName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.28,
                                color: Color(0xff414751))),
                        Text("${match.department} • Grade ${match.grade}",
                            style: const TextStyle(
                                color: Color(0xff9CA3AE),
                                fontSize: 10,
                                fontWeight: FontWeight.w400)),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 20),
                Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       Text(
                  "Hakkında",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                        Text("${match.department} • Grade ${match.about}",
                            style: const TextStyle(
                                color: Color(0xff9CA3AE),
                                fontSize: 10,
                                fontWeight: FontWeight.w400)),
                      ],
                    ),

                const SizedBox(height: 20),
                // Eşleşen Konular
                 Text(
                  "Seninle Eşleşen Konular",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                 Wrap(
                  spacing: 8,
                  children: match.matchedTopics.map((topic) => Chip(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),label: Text(topic,style: TextStyle(fontSize: 10,fontWeight: FontWeight.w600),), backgroundColor: Colors.white)).toList(),
                ),
                const SizedBox(height: 50), // Butonlar için boşluk bırak
              ],
            ),
          ),
          // Profil Fotoğrafı
          Positioned(
            top: 0,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(match.profileImage),
              child: match.isOnline
                  ? Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        backgroundColor: Color(0xff4DD64B),
                        radius: 8,
                      ),
                    )
                  : null,
            ),
          ),
          // Butonlar
          Positioned(
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xff65D384),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'images/icons/match_user_add_icon.svg',
                      width: 24,
                      height: 24,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    onPressed: controller.followUser,
                  ),
                ),
                const SizedBox(width: 30),
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xffFF7743),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'images/icons/match_message_icon.svg',
                      width: 24,
                      height: 23,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    onPressed: controller.startChat,
                  ),
                ),
                const SizedBox(width: 30),
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xffEF5050),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'images/icons/match_next_icon.svg',
                      width: 20,
                      height: 21,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    onPressed: controller.nextMatch,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
