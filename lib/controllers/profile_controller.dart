import 'package:edusocial/controllers/appbar_controller.dart';
import 'package:edusocial/models/post_model.dart';
import 'package:edusocial/screens/profile/people_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final AppBarController appBarController = Get.find<AppBarController>();

  // Mock Kullanıcı Verileri
  var isPrLoading = false.obs; // Yüklenme durumu
  var userId = ''.obs;
  var profileImage = "".obs;
  var fullName = "".obs;
  var bio = "".obs;
  var coverImage = "".obs;
  var username = "".obs;
  var postCount = 0.obs;
  var followers = 0.obs;
  var following = 0.obs;
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
  var followerList = [].obs;

  // 📦 Takip edilenler listesi (Mock)
  var followingList = [].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

String formatSimpleDate(String dateStr) {
  if (dateStr.isEmpty) return '';
  try {
    DateTime parsedDate = DateTime.parse(dateStr);
    return DateFormat('dd.MM.yyyy').format(parsedDate);
  } catch (e) {
    return ''; // veya istersen 'Geçersiz Tarih'
  }
}



  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final data = await _profileService.fetchProfileData();
      profile.value = data;

      // 📌 Temel veriler
      userId.value = data.id.toString();
      fullName.value = "${data.name} ${data.surname}";
      username.value = "@${data.username}";
      profileImage.value = data.avatarUrl;
      coverImage.value = data.bannerUrl;
      bio.value = data.description ?? '';
   birthDate.value = data.birthDate;

      lessons.value = data.lessons;

      // 📌 Okul ve Bölüm Bilgileri
      schoolName.value = data.school?.name ?? 'Okul bilgisi yok';
      schoolDepartment.value =
          data.schoolDepartment?.title ?? 'Bölüm bilgisi yok';

      // 📌 Takipçi ve takip edilen sayıları
      followers.value = data.followers.length;
      following.value = data.followings.length;

      // 📌 Takipçi ve Takip Edilen Listesi
      followerList.assignAll(data.followers);
      followingList.assignAll(data.followings);

      // 📌 Postlar
      postCount.value = data.posts.length;

      // 📌 AppBar resmi güncelle
      appBarController.updateProfileImage(profileImage.value);
    } catch (e) {
      debugPrint("❌ Profil verisi yüklenemedi: $e", wrapWidth: 1024);
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

  void getToPeopleProfileScreen(String username) async {
    Get.to(() =>
            PeopleProfileScreen(username: username)); // ✅ burada userId eklenmeli
  }

  void updateProfile(String name, String newBio) {
    fullName.value = name;
    bio.value = newBio;
  }
}
