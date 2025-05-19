import 'package:edusocial/controllers/appbar_controller.dart';
import 'package:edusocial/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final AppBarController appBarController = Get.find<AppBarController>();

  // Mock Kullanıcı Verileri
  var isPrLoading = false.obs; // Yüklenme durumu

  var profileImage = "".obs;
  var fullName = "".obs;
  var bio = "".obs;
  var coverImage = "".obs;
  var username = "".obs;
  var postCount = 352.obs;
  var followers = 2352.obs;
  var following = 532.obs;
  var birthDate = ''.obs;
  var schoolName = ''.obs;
  var schoolDepartment = ''.obs;
  var schoolGrade = ''.obs;
  var lessons = <String>[].obs;
  var profilePosts = <PostModel>[].obs;

  final ProfileService _profileService = ProfileService();

  Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  RxBool isLoading = true.obs;

  // 📦 Takipçi listesi (Mock)
  var followerList = [
    {
      "username": "alihanmatrak",
      "fullName": "ALİ HAN MATRAK",
      "avatarUrl": "https://randomuser.me/api/portraits/men/10.jpg",
    },
    {
      "username": "srt_umt",
      "fullName": "Ümit SERT",
      "avatarUrl": "https://randomuser.me/api/portraits/men/12.jpg",
    },
    {
      "username": "ismailysr20",
      "fullName": "İsmail Yaşar",
      "avatarUrl": "https://randomuser.me/api/portraits/men/14.jpg",
    },
  ].obs;

  // 📦 Takip edilenler listesi (Mock)
  var followingList = [
    {
      "username": "srt_umt",
      "fullName": "Ümit SERT",
      "avatarUrl": "https://randomuser.me/api/portraits/men/12.jpg",
    },
    {
      "username": "earaz__",
      "fullName": "Erdal Araz",
      "avatarUrl": "https://randomuser.me/api/portraits/men/3.jpg",
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  String formatBirthday(String isoString) {
    try {
      DateTime parsed = DateTime.parse(isoString);
      return DateFormat('dd.MM.yyyy').format(parsed);
    } catch (e) {
      return '';
    }
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final data = await _profileService.fetchProfileData();
      profile.value = data;

      // Verileri UI'daki observable alanlara at
      fullName.value = "${data.name} ${data.surname}";
      username.value = "@${data.username}";
      profileImage.value = data.avatarUrl;
      debugPrint("👤 Avatar URL: ${data.avatar}");

      coverImage.value = data.banner;
      bio.value = data.description ?? '';
      followers.value = data.followers.length;
      following.value = data.followings.length;
      postCount.value = data.posts.length;
      birthDate.value = formatBirthday(data.birthDate);
      schoolName.value = data.school;
      schoolDepartment.value = data.schoolDepartment;
      //schoolGrade.value = data.schoolGrade;
      lessons.value = data.lessons;
      profilePosts.assignAll(data.posts);
      appBarController.updateProfileImage(profileImage.value);
    } catch (e) {
      debugPrint("Profil verisi yüklenemedi: $e", wrapWidth: 1024);
    } finally {
      isLoading.value = false;
    }
  }

  void getToSettingScreen() async {
    Get.toNamed("/settings");
  }

  void getToUserSettingScreen() async {
    Get.toNamed("/userSettings");
  }

  void getToPeopleProfileScreen() async {
    Get.toNamed("/peopleProfile");
  }

  void updateProfile(String name, String newBio) {
    fullName.value = name;
    bio.value = newBio;
  }
}
