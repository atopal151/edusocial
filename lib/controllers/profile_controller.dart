import 'package:edusocial/controllers/appbar_controller.dart';
import 'package:edusocial/controllers/story_controller.dart';
import 'package:edusocial/models/post_model.dart';
import 'package:edusocial/screens/profile/people_profile_screen.dart';
import 'package:edusocial/services/post_service.dart';
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
    // loadProfile(); // Login sırasında manuel olarak çağrılacak
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

  /// Profil postlarını ayrı bir endpoint'ten çek
  Future<void> fetchProfilePosts() async {
    debugPrint("🔄 ProfileController.fetchProfilePosts() çağrıldı");
    
    try {
      final posts = await PostServices.fetchHomePosts();
      debugPrint("✅ Profile postları başarıyla yüklendi: ${posts.length} post");
      
      // Sadece kullanıcının kendi postlarını filtrele
      final userPosts = posts.where((post) => post.isOwner).toList();
      debugPrint("✅ Kullanıcının kendi postları: ${userPosts.length} post");
      
      profilePosts.assignAll(userPosts);
      postCount.value = userPosts.length;
      
      // Her postun link verilerini debug et
      for (int i = 0; i < userPosts.length; i++) {
        final post = userPosts[i];
        debugPrint("📝 Profile Post $i:");
        debugPrint("  - ID: ${post.id}");
        debugPrint("  - Content: ${post.postDescription}");
        debugPrint("  - Links: ${post.links}");
        debugPrint("  - Media: ${post.mediaUrls}");
      }
      
    } catch (e) {
      debugPrint("❌ Profile postları yükleme hatası: $e");
    }
  }

  Future<void> loadProfile() async {
    debugPrint("🔄 ProfileController.loadProfile() çağrıldı");
    isLoading.value = true;
    
    try {
      final profileData = await _profileService.fetchProfileData();
      debugPrint("✅ Profil verisi başarıyla yüklendi: ${profileData.name} ${profileData.surname}");
      
      // Ana profil verisi
      profile.value = profileData;
      userId.value = profileData.id.toString();
      
      // 📌 Temel veriler
      fullName.value = "${profileData.name} ${profileData.surname}";
      username.value = "@${profileData.username}";
      profileImage.value = profileData.avatarUrl;
      coverImage.value = profileData.bannerUrl;
      bio.value = profileData.description ?? '';
      birthDate.value = profileData.birthDate;
      
      lessons.value = profileData.lessons;
      
      // 📌 Okul ve Bölüm Bilgileri
      schoolName.value = profileData.school?.name ?? 'Okul bilgisi yok';
      schoolDepartment.value = profileData.schoolDepartment?.title ?? 'Bölüm bilgisi yok';
      
      // 📌 Takipçi ve takip edilen sayıları
      followers.value = profileData.followers.length;
      following.value = profileData.followings.length;
      
      // 📌 Takipçi ve Takip Edilen Listesi
      followerList.assignAll(profileData.followers);
      followingList.assignAll(profileData.followings);
      
      // 📌 Postlar - Artık ayrı bir endpoint'ten çekiyoruz
      await fetchProfilePosts();
      
      // Profil yüklendikten sonra diğer verileri de güncelle
      _updateRelatedData();
        } catch (e) {
      debugPrint("❌ Profil yükleme hatası: $e");
    } finally {
      isLoading.value = false;
    }
  } 

  /// Profil yüklendikten sonra ilgili verileri güncelle
  void _updateRelatedData() {
    debugPrint("🔄 İlgili veriler güncelleniyor...");
    
    // AppBar'daki profil resmini güncelle
    try {
      appBarController.fetchAndSetProfileImage();
    } catch (e) {
      debugPrint("❌ AppBar güncelleme hatası: $e");
    }
    
    // Story'leri güncelle
    try {
      final storyController = Get.find<StoryController>();
      storyController.fetchStories();
    } catch (e) {
      debugPrint("❌ Story güncelleme hatası: $e");
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
