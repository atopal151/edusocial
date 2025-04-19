import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_profile_model.dart';

class SettingsController extends GetxController {
  var userProfile = UserProfile.empty().obs;
  var usernameController = TextEditingController();
  var instagramController = TextEditingController();
  var youtubeController = TextEditingController();
  var demoNotification = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      await Future.delayed(Duration(milliseconds: 500)); // API çağrısını simüle etme
      var mockData = {
        "profileImage": "https://i.pravatar.cc/150?img=20",
        "username": "mockuser",
        "instagram": "mock_insta",
        "youtube": "mock_yt",
        "demoNotification": true,
      };
      userProfile.value = UserProfile.fromJson(mockData);
      loadUserData();
    } catch (e) {
      Get.snackbar("Hata", "Bağlantı hatası: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void loadUserData() {
    usernameController.text = userProfile.value.username;
    instagramController.text = userProfile.value.instagram;
    youtubeController.text = userProfile.value.youtube;
    demoNotification.value = userProfile.value.demoNotification;
  }

  void goBack() {
    Get.back();
  }

  void changeProfilePicture() {
    //print("Profil fotoğrafı değiştirildi");
  }

  void toggleNotification(bool value) {
    demoNotification.value = value;
    userProfile.update((val) {
      if (val != null) {
        val.demoNotification = value;
      }
    });
  }

  Future<void> saveProfile() async {
    isLoading.value = true;
    try {
      await Future.delayed(Duration(milliseconds: 500)); // API güncellemesini simüle etme
      userProfile.update((val) {
        if (val != null) {
          val.username = usernameController.text;
          val.instagram = instagramController.text;
          val.youtube = youtubeController.text;
          val.demoNotification = demoNotification.value;
        }
      });
      Get.snackbar("Başarılı", "Profil bilgileri kaydedildi");
    } catch (e) {
      Get.snackbar("Hata", "Bağlantı hatası: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
