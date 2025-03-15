import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        "profileImage": "https://s3-alpha-sig.figma.com/img/e4bc/32cd/9b509d74c916eb0c3da9cb418e3d03ad?Expires=1742774400&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=t83o2RSsZzHXwcmdcGEyBCgJRrlLv1Lf4mNGCXVBvwsooIktag5NS9TcjkJ1MqCIl7oZxsyUCr1NG~BguKzkUaqvhJe-c6hTrvPSV79DodR1bXBmatFyvsc-jCCjlQolEXfW4AjzZ6~35Swb5H563OqsdRVtWoy6GhfTy0gVC3h6FxZ~jhXN4AuaOdlL4PHT4MykIO2dwZOdgh-ZofLjvauwwxZRoftJyqHJq29YxzJ1nBKb7JCD6l-2t6h3fpp99mshq8PQHAHXBhKSRHWweW2iv2elJpTEOaIb8STqtIKh83ANjskepPbg54tomZXV8fu6Abcg0JVAH6UEnzl45A__",
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
    print("Profil fotoğrafı değiştirildi");
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

class UserProfile {
  String profileImage;
  String username;
  String instagram;
  String youtube;
  bool demoNotification;

  UserProfile({
    required this.profileImage,
    required this.username,
    required this.instagram,
    required this.youtube,
    required this.demoNotification,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      profileImage: json['profileImage'] ?? '',
      username: json['username'] ?? '',
      instagram: json['instagram'] ?? '',
      youtube: json['youtube'] ?? '',
      demoNotification: json['demoNotification'] ?? false,
    );
  }

  static UserProfile empty() {
    return UserProfile(
      profileImage: "https://s3-alpha-sig.figma.com/img/e4bc/32cd/9b509d74c916eb0c3da9cb418e3d03ad?Expires=1742774400&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=t83o2RSsZzHXwcmdcGEyBCgJRrlLv1Lf4mNGCXVBvwsooIktag5NS9TcjkJ1MqCIl7oZxsyUCr1NG~BguKzkUaqvhJe-c6hTrvPSV79DodR1bXBmatFyvsc-jCCjlQolEXfW4AjzZ6~35Swb5H563OqsdRVtWoy6GhfTy0gVC3h6FxZ~jhXN4AuaOdlL4PHT4MykIO2dwZOdgh-ZofLjvauwwxZRoftJyqHJq29YxzJ1nBKb7JCD6l-2t6h3fpp99mshq8PQHAHXBhKSRHWweW2iv2elJpTEOaIb8STqtIKh83ANjskepPbg54tomZXV8fu6Abcg0JVAH6UEnzl45A__",
      username: "",
      instagram: "",
      youtube: "",
      demoNotification: false,
    );
  }
}