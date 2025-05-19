import 'package:edusocial/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/comment_bottom_sheet.dart';
import '../widgets/share_bottom_sheet.dart';
import '../widgets/tree_point_bottom_sheet.dart';

class PostCard extends StatelessWidget {
  final String profileImage;
  final String userName;
  final String postDate;
  final String postDescription;
  final String? postImage;
  final int likeCount;
  final int commentCount;

  const PostCard({
    super.key,
    required this.profileImage,
    required this.userName,
    required this.postDate,
    required this.postDescription,
    this.postImage,
    required this.likeCount,
    required this.commentCount,
  });

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Üst Kısım (Profil Bilgileri ve Menü İkonu)
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Profil Fotoğrafı
                    InkWell(
                      onTap: () {
                        profileController.getToPeopleProfileScreen();
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(profileImage),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Kullanıcı Adı ve Tarih
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xff414751)),
                            overflow:
                                TextOverflow.ellipsis, // Uzun isimler taşmaz
                          ),
                          Text(
                            postDate,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Color(0xff9CA3AE),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Menü (Üç Nokta) İkonu
                    InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            backgroundColor: Colors.white,
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25)),
                            ),
                            builder: (context) => const TreePointBottomSheet(),
                          );
                        },
                        child: SvgPicture.asset(
                          "images/icons/tree_dot.svg",
                          colorFilter: ColorFilter.mode(
                            Color(0xff414751),
                            BlendMode.srcIn,
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 8),

                // 🔹 Gönderi Açıklaması
                Text(
                  postDescription,
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff414751)),
                  maxLines: 10, // Uzun açıklamaları sınırlandır
                  overflow:
                      TextOverflow.ellipsis, // Fazlasını "..." olarak göster
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // 🔹 Gönderi Fotoğrafı (Eğer varsa göster)
         if (postImage != null && postImage!.trim().isNotEmpty)

            Image.network(
              postImage!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                );
              },
            ),

          Container(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    // Beğeni Butonu
                    InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(
                        "images/icons/post_like.svg",
                        colorFilter: ColorFilter.mode(
                          Color(0xff9ca3ae),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      likeCount.toString(),
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff414751)),
                    ),

                    const SizedBox(width: 16),

                    // Yorum Butonu
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, // 🔥 Bu çok önemli
                          backgroundColor: Colors.transparent,
                          builder: (context) => DraggableScrollableSheet(
                            initialChildSize: 0.95,
                            maxChildSize: 0.95,
                            minChildSize: 0.95,
                            expand: false,
                            builder: (_, controller) => CommentBottomSheet(),
                          ),
                        );
                      },
                      child: SvgPicture.asset(
                        "images/icons/post_chat.svg",
                        colorFilter: ColorFilter.mode(
                          Color(0xff9ca3ae),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      commentCount.toString(),
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff414751)),
                    ),

                    const Spacer(),

                    // Paylaşım Butonu
                    InkWell(
                      onTap: () {
                        final String shareText =
                            "$userName bir gönderi paylaştı: \n\n$postDescription";
                        showModalBottomSheet(
                          backgroundColor: Colors.white,
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(25)),
                          ),
                          builder: (_) =>
                              ShareOptionsBottomSheet(postText: shareText),
                        );
                      },
                      child: SvgPicture.asset(
                        "images/icons/share.svg",
                        colorFilter: ColorFilter.mode(
                          Color(0xff9ca3ae),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Paylaş",
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff414751)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 🔹 Beğeni, Yorum, Paylaş
        ],
      ),
    );
  }
}
