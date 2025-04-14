import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';

final ProfileController controller = Get.find();

/// Profil Bilgileri Bölümü
Widget buildProfileHeader() {
  return Column(
    children: [
      Obx(() => CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(controller.profileImage.value),
          )),
      const SizedBox(height: 10),
      Obx(() => Text(
            controller.fullName.value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff272727)),
          )),
      const SizedBox(height: 5),
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
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProfileInfo("Gönderi", controller.postCount),
          _buildDivider(),
          InkWell(
              onTap: () {
                Get.toNamed("/followers");
              },
              child: _buildProfileInfo("Takipçi", controller.followers)),
          _buildDivider(),
          InkWell(
              onTap: () {
                Get.toNamed("/following");
              },
              child: _buildProfileInfo("Takip Edilen", controller.following)),
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
