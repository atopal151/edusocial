import 'package:edusocial/controllers/appbar_controller.dart';
import 'package:edusocial/controllers/story_controller.dart';
import 'package:edusocial/models/post_model.dart';
import 'package:edusocial/screens/profile/people_profile_screen.dart';
import 'package:edusocial/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/profile_model.dart';
import '../models/entry_model.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
import '../services/people_profile_services.dart';

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

  // 📝 Kullanıcının entries'ları (PeopleProfileScreen'deki gibi)
  var personEntries = <EntryModel>[].obs;

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
      
      // 📝 Entries'ları kullanıcı bilgileriyle işle
      if (profileData.entries.isNotEmpty) {
        debugPrint("📝 Entries sayısı: ${profileData.entries.length}");
        await _processEntriesWithUserData(profileData.entries);
        debugPrint("✅ Kullanıcının ${profileData.entries.length} entries'ı yüklendi");
      } else {
        debugPrint("⚠️ Kullanıcının entries'ı bulunamadı");
      }
      
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

  /// Entries'ları topic user_id'lerine göre kullanıcı bilgileriyle işle
  Future<void> _processEntriesWithUserData(List<EntryModel> entries) async {
    try {
      final processedEntries = <EntryModel>[];
      
      for (final entry in entries) {
        // Topic'in user_id'sini al
        final topicUserId = entry.topic?.userId;
        
        if (topicUserId != null) {
          debugPrint("👤 Topic kullanıcısı için bilgi çekiliyor: user_id = $topicUserId");
          
          // Kullanıcı bilgilerini API'den çek
          final userData = await PeopleProfileService.fetchUserById(topicUserId);
          
          if (userData != null) {
            // Kullanıcı bilgilerini debug et
            debugPrint("📸 Kullanıcı avatar bilgileri:");
            debugPrint("  - Avatar URL: ${userData.avatarUrl}");
            debugPrint("  - Avatar: ${userData.avatar}");
            debugPrint("  - Name: ${userData.name} ${userData.surname}");
            debugPrint("  - Username: ${userData.username}");
            
            // Kullanıcı bilgilerini UserModel'e dönüştür
            final user = _createUserModelFromProfile(userData);
            
            // UserModel'deki avatar bilgilerini de debug et
            debugPrint("🖼️ UserModel avatar bilgileri:");
            debugPrint("  - Avatar URL: ${user.avatarUrl}");
            debugPrint("  - Avatar: ${user.avatar}");
            debugPrint("  - Kullanılan avatar alanı: ${user.avatarUrl.isNotEmpty ? 'avatarUrl' : 'avatar'}");
            
            // Entry'yi güncellenmiş kullanıcı bilgileriyle oluştur
            final processedEntry = EntryModel(
              id: entry.id,
              content: entry.content,
              upvotescount: entry.upvotescount,
              downvotescount: entry.downvotescount,
              humancreatedat: entry.humancreatedat,
              createdat: entry.createdat,
              user: user,
              topic: entry.topic,
              islike: entry.islike,
              isdislike: entry.isdislike,
            );
            
            processedEntries.add(processedEntry);
            debugPrint("✅ Entry ${entry.id} için kullanıcı bilgileri yüklendi: ${user.name} ${user.surname}");
          } else {
            debugPrint("⚠️ Kullanıcı bilgileri alınamadı: user_id = $topicUserId");
            processedEntries.add(entry); // Orijinal entry'yi ekle
          }
        } else {
          debugPrint("⚠️ Topic user_id bulunamadı, orijinal entry kullanılıyor");
          processedEntries.add(entry); // Orijinal entry'yi ekle
        }
      }
      
      personEntries.assignAll(processedEntries);
      debugPrint("✅ Tüm entries kullanıcı bilgileriyle işlendi");
      
    } catch (e) {
      debugPrint("❌ Entries işleme hatası: $e");
      // Hata durumunda orijinal entries'ları kullan
      personEntries.assignAll(entries);
    }
  }

  /// ProfileModel'den UserModel oluştur
  UserModel _createUserModelFromProfile(dynamic profile) {
    return UserModel(
      id: profile.id,
      accountType: profile.accountType,
      languageId: profile.languageId != null ? int.tryParse(profile.languageId!) ?? 1 : 1,
      avatar: profile.avatar,
      banner: profile.banner,
      schoolId: profile.schoolId != null ? int.tryParse(profile.schoolId!) ?? 1 : 1,
      schoolDepartmentId: profile.schoolDepartmentId != null ? int.tryParse(profile.schoolDepartmentId!) ?? 1 : 1,
      name: profile.name,
      surname: profile.surname,
      username: profile.username,
      email: profile.email,
      phone: profile.phone,
      birthday: profile.birthDate.isNotEmpty ? DateTime.tryParse(profile.birthDate) : null,
      instagram: profile.instagram,
      tiktok: profile.tiktok,
      twitter: profile.twitter,
      facebook: profile.facebook,
      linkedin: profile.linkedin,
      notificationEmail: profile.notificationEmail,
      notificationMobile: profile.notificationMobile,
      isActive: profile.isActive,
      isOnline: profile.isOnline,
      avatarUrl: profile.avatarUrl.isNotEmpty ? profile.avatarUrl : profile.avatar, // Avatar URL boşsa avatar alanını kullan
      bannerUrl: profile.bannerUrl,
      isFollowing: profile.isFollowing,
      isFollowingPending: profile.isFollowingPending,
      isSelf: profile.isSelf,
    );
  }
}
