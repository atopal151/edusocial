import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edusocial/controllers/people_profile_controller.dart';
import 'package:edusocial/components/widgets/general_loading_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';

Widget buildPeopleProfileHeader(PeopleProfileController controller) {
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
      return const Center(child: Text("Profil bilgisi yüklenemedi."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// Banner Alanı
        if (profile.banner.isNotEmpty)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
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

              /// Profil Fotoğrafı
              Positioned(
                bottom: -35,
                left: Get.width / 2 - 45,
                child: CircleAvatar(
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
            ],
          ),
        const SizedBox(height: 50),

        /// İsim ve Kullanıcı Adı
        Text(
          "${profile.name} ${profile.surname}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          "@${profile.username}",
          style: GoogleFonts.inter(
              fontSize: 12.78,
              fontWeight: FontWeight.w400,
              color: const Color(0xff9ca3ae)),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProfileInfo("Gönderi", profile.posts.length),
            _buildDivider(),
            InkWell(
              onTap: () {
                /* Get.toNamed(Routes.followers, arguments: {
                  'followers': profile.followers.map((item) => item as Map<String, dynamic>).toList(),
                  'screenTitle': '${profile.name} ${profile.surname} - Takipçi',
                });*/
              },
              child: _buildProfileInfo("Takipçi", profile.followerCount),
            ),
            _buildDivider(),
            InkWell(
              onTap: () {
                /*Get.toNamed(Routes.following, arguments: {
                  'followings': profile.followings.map((item) => item as Map<String, dynamic>).toList(),
                  'screenTitle': '${profile.name} ${profile.surname} - Takip Edilen',
                });*/
              },
              child: _buildProfileInfo("Takip Edilen", profile.followingCount),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  });
}

Widget _buildProfileInfo(String title, int value) {
  return Column(
    children: [
      Text(
        value.toString(),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xff414751),
        ),
      ),
      Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xff9ca3ae),
          fontWeight: FontWeight.w400,
        ),
      ),
    ],
  );
}

Widget _buildDivider() {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: VerticalDivider(thickness: 1, color: Colors.grey),
  );
}
