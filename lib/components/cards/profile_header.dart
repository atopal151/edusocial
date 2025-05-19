import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/profile_controller.dart';

final ProfileController controller = Get.find();

/// Profil Bilgileri Bölümü
Widget buildProfileHeader() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
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
                return CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 38,
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
                );
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 50),

      /// Kullanıcı Adı
      Obx(() => Text(
            controller.fullName.value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff272727)),
          )),

      Obx(() => Text(
            controller.username.value,
            style: GoogleFonts.inter(
                fontSize: 12.78,
                fontWeight: FontWeight.w400,
                color: Color(0xff9ca3ae)),
          )),

      const SizedBox(height: 10),

      /// Kullanıcı Bio
      Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              controller.bio.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff9CA3AE)),
            ),
          )),
      const SizedBox(height: 20),

      // Gönderi / Takipçi / Takip Edilen
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProfileInfo("Gönderi", controller.postCount),
          _buildDivider(),
          InkWell(
            onTap: () {
              Get.toNamed("/followers");
            },
            child: _buildProfileInfo("Takipçi", controller.followers),
          ),
          _buildDivider(),
          InkWell(
            onTap: () {
              Get.toNamed("/following");
            },
            child: _buildProfileInfo("Takip Edilen", controller.following),
          ),
        ],
      ),
      const SizedBox(height: 20),
    ],
  );
}

Widget _buildProfileInfo(String title, RxInt value) {
  return Column(
    children: [
      Obx(() => Text(
            value.value.toString(),
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xff414751)),
          )),
      Text(
        title,
        style: const TextStyle(
            fontSize: 12,
            color: Color(0xff9ca3ae),
            fontWeight: FontWeight.w400),
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
