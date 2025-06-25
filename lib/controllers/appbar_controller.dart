import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/profile_service.dart';
import 'nav_bar_controller.dart';

class AppBarController extends GetxController {
  var isSearching = false.obs;
  var profileImagePath = "".obs; // varsayılan görsel
  TextEditingController searchController = TextEditingController();

  final NavigationController navController = Get.find<NavigationController>();
  final ProfileService _profileService = ProfileService(); // 🔹 servisi ekledik


  /// 🔄 Avatar'ı backend'den al ve UI'ya yansıt
  Future<void> fetchAndSetProfileImage() async {
    try {
      final profile = await _profileService.fetchProfileData();
      if (profile.avatarUrl.isNotEmpty) {
        profileImagePath.value = profile.avatarUrl; // 🔥 burada set edilir
      }
    } catch (e) {
      debugPrint("⚠️ Profil resmi yüklenemedi: $e");
    }
  }

  void navigateToSearch() {
    Get.toNamed("/search_text");
  }

  void navigateToProfile() {
    navController.changeIndex(4);
  }

  void navigateToGroups() {
    Get.toNamed("/group_list");
  }

  void navigateToNotifications() {
    Get.toNamed("/notifications");
  }

  void navigateToEvent() {
    Get.toNamed("/event");
  }

  void navigateToCalendar() {
    Get.toNamed("/calendar");
  }

  void updateProfileImage(String newPath) {
    profileImagePath.value = newPath;
  }

  void backToPage() {
    Get.back();
  }
}
