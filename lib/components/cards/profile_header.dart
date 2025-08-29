import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/dialogs/profile_image_preview_dialog.dart';
import '../../controllers/profile_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/language_service.dart';
import '../../components/widgets/verification_badge.dart';

final ProfileController controller = Get.find();

/// Profil Bilgileri Bölümü
Widget buildProfileHeader() {
  final LanguageService languageService = Get.find<LanguageService>();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Stack(
        clipBehavior: Clip.none,
        children: [
          // 📸 Kapak fotoğrafı
          Obx(() => Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      controller.coverImage.value.trim().isNotEmpty
                          ? controller.coverImage.value
                          : "https://i.pravatar.cc/150?img=20",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint("⚠️ Kapak görseli yüklenemedi: $error",
                            wrapWidth: 1024);
                        return Image.asset(
                          'images/user1.jpg',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
              )),

          Positioned(
            bottom: -35,
            left: Get.width / 2 - 45,
            child: Obx(
              () {
                final imageUrl = controller.profileImage.value.trim();
                final GlobalKey avatarKey = GlobalKey();
                return GestureDetector(
                  onTap: () {
                    if (imageUrl.isNotEmpty) {
                      final RenderBox? renderBox = avatarKey.currentContext?.findRenderObject() as RenderBox?;
                      if (renderBox != null) {
                        showProfileImagePreviewDialog(
                          imageUrl: imageUrl,
                          title: '${controller.fullName.value} - Profil Fotoğrafı',
                          context: Get.context!,
                          renderBox: renderBox,
                        );
                      }
                    }
                  },
                  child: CircleAvatar(
                    key: avatarKey,
                    radius: 42,
                    backgroundColor: Color(0xffffffff),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xfffafafa),
                      backgroundImage:
                          imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      child: imageUrl.isEmpty
                          ? Image.asset(
                              'images/user1.png',
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 50),

      /// Kullanıcı Adı ve Doğrulama Rozeti
      Obx(() => VerifiedNameDisplay(
        name: controller.fullName.value,
        username: controller.username.value,
        isVerified: controller.profile.value?.isVerified ?? false,
        nameStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xff272727),
        ),
        usernameStyle: GoogleFonts.inter(
          fontSize: 13.28,
          fontWeight: FontWeight.w500,
          color: Color(0xff9ca3ae),
        ),
        badgeSize: 18.0,
      )),

      const SizedBox(height: 10),

      if (controller.bio.value.isNotEmpty)
        /// Kullanıcı Bio
        Obx(() => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                controller.bio.value,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff9CA3AE)),
              ),
            )),
      const SizedBox(height: 20),

      // Gönderi / Takipçi / Takip Edilen
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

      const SizedBox(width: 50),
          Expanded(
            child: _buildProfileInfo(languageService.tr("profile.header.posts"), controller.postCount),
          ),
         
          Expanded(
            child: InkWell(
              onTap: () {
                Get.toNamed(Routes.followers, arguments: {
                  'followers': controller.followerList.map((item) => item as Map<String, dynamic>).toList(),
                  'screenTitle': languageService.tr("profile.header.followers"),
                });
              },
              child: _buildProfileInfo(languageService.tr("profile.header.followers"), controller.filteredFollowers),
            ),
          ),
         
          Expanded(
            child: InkWell(
              onTap: () {
                Get.toNamed(Routes.following, arguments: {
                  'followings': controller.followingList.map((item) => item as Map<String, dynamic>).toList(),
                  'screenTitle': languageService.tr("profile.header.following"),
                });
              },
              child: _buildProfileInfo(languageService.tr("profile.header.following"), controller.filteredFollowing),
            ),
          ),

      const SizedBox(width: 50),
        ],
      ),
      const SizedBox(height: 20),
    ],
  );
}

Widget _buildProfileInfo(String title, RxInt value) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Obx(() => Text(
            value.value.toString(),
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xff414751)),
            textAlign: TextAlign.center,
          )),
      Text(
        title,
        style: GoogleFonts.inter(
            fontSize: 12,
            color: Color(0xff9ca3ae),
            fontWeight: FontWeight.w400),
        textAlign: TextAlign.center,
      ),
    ],
  );
}


