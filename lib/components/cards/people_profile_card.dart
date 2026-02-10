import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edusocial/controllers/people_profile_controller.dart';
import 'package:edusocial/components/widgets/general_loading_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edusocial/services/language_service.dart';
import 'package:edusocial/components/dialogs/profile_image_preview_dialog.dart';
import 'package:edusocial/components/widgets/verification_badge.dart';
import 'package:edusocial/routes/app_routes.dart';

Widget buildPeopleProfileHeader(PeopleProfileController controller) {
  final LanguageService languageService = Get.find<LanguageService>();
  final GlobalKey bannerKey = GlobalKey();
  final GlobalKey avatarKey = GlobalKey();
  
  return Obx(() {
    if (controller.isLoading.value) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: GeneralLoadingIndicator(
          size: 32,
          color: Color(0xFF2196F3),
          icon: Icons.person,
          showText: true,
        ),
      );
    }

    final profile = controller.profile.value;
    if (profile == null) {
      return Center(child: Text(languageService.tr("profile.peopleProfile.loadError")));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// Banner Alanı
        Stack(
          clipBehavior: Clip.none,
          children: [
            if (profile.banner.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GestureDetector(
                  onTap: () {
                    final RenderBox? renderBox = bannerKey.currentContext?.findRenderObject() as RenderBox?;
                    if (renderBox != null) {
                      showProfileImagePreviewDialog(
                        imageUrl: profile.banner,
                        title: '${profile.name} ${profile.surname} - Kapak Fotoğrafı',
                        context: Get.context!,
                        renderBox: renderBox,
                      );
                    }
                  },
                  child: Container(
                    key: bannerKey,
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(profile.banner),
                      ),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xfff4f4f5),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: const Color(0xff9ca3ae),
                    ),
                  ),
                ),
              ),

            /// Profil Fotoğrafı
            Positioned(
              bottom: -35,
              left: Get.width / 2 - 45,
              child: GestureDetector(
                onTap: () {
                  if (profile.avatar.isNotEmpty) {
                    final RenderBox? renderBox = avatarKey.currentContext?.findRenderObject() as RenderBox?;
                    if (renderBox != null) {
                      showProfileImagePreviewDialog(
                        imageUrl: profile.avatar,
                        title: '${profile.name} ${profile.surname} - Profil Fotoğrafı',
                        context: Get.context!,
                        renderBox: renderBox,
                      );
                    }
                  }
                },
                child: CircleAvatar(
                  key: avatarKey,
                  radius: 42,
                  backgroundColor: const Color(0xfffafafa),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xffffffff),
                    backgroundImage: profile.avatar.isNotEmpty
                        ? NetworkImage(profile.avatar)
                        : const AssetImage('images/user1.png') as ImageProvider,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),

        /// İsim ve Kullanıcı Adı ile Doğrulama Rozeti
        VerifiedNameDisplay(
          name: "${profile.name} ${profile.surname}",
          username: "@${profile.username}",
          isVerified: profile.isVerified ?? false,
          nameStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          usernameStyle: GoogleFonts.inter(
            fontSize: 12.78,
            fontWeight: FontWeight.w400,
            color: const Color(0xff9ca3ae),
          ),
          badgeSize: 20.0,
        ),

        /// Açıklama
        if (profile.description != null && profile.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              profile.description!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xff9CA3AE)),
            ),
          ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 50),
            Expanded(
              child: _buildProfileInfo(languageService.tr("profile.header.posts"), profile.posts.length),
            ),
            const SizedBox(width: 12),
            Container(width: 1, height: 28, color: const Color(0xffe5e7eb)),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.toNamed(Routes.followList, arguments: {
                    'displayName': profile.username.isNotEmpty ? profile.username : '${profile.name} ${profile.surname}',
                    'isVerified': profile.isVerified,
                    'userId': profile.id,
                    'initialTabIndex': 0,
                    'followers': controller.followersList.toList(),
                    'followings': controller.followingsList.toList(),
                    'followerCount': profile.followerCount,
                    'followingCount': profile.followingCount,
                  });
                },
                child: _buildProfileInfo(languageService.tr("profile.header.followers"), profile.followerCount),
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 1, height: 28, color: const Color(0xffe5e7eb)),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.toNamed(Routes.followList, arguments: {
                    'displayName': profile.username.isNotEmpty ? profile.username : '${profile.name} ${profile.surname}',
                    'isVerified': profile.isVerified,
                    'userId': profile.id,
                    'initialTabIndex': 1,
                    'followers': controller.followersList.toList(),
                    'followings': controller.followingsList.toList(),
                    'followerCount': profile.followerCount,
                    'followingCount': profile.followingCount,
                  });
                },
                child: _buildProfileInfo(languageService.tr("profile.header.following"), profile.followingCount),
              ),
            ),
            const SizedBox(width: 50),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  });
}

Widget _buildProfileInfo(String title, int value) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        value.toString(),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xff414751),
        ),
        textAlign: TextAlign.center,
      ),
      Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xff9ca3ae),
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}


