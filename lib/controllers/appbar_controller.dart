import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'nav_bar_controller.dart';

class AppBarController extends GetxController {
  var isSearching = false.obs;
  var profileImagePath = "images/profile_user.png".obs;
  TextEditingController searchController = TextEditingController();

  final NavigationController navController = Get.find<NavigationController>();

  void navigateToSearch() {
    Get.toNamed("/search_text");
  }

  void navigateToProfile() {
    navController.changeIndex(4); // 4. indexe yönlendir
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
