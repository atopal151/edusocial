import 'package:edusocial/controllers/appbar_controller.dart';
import 'package:edusocial/controllers/story_controller.dart';
import 'package:edusocial/models/post_model.dart';
import 'package:edusocial/screens/profile/people_profile_screen.dart';
import 'package:edusocial/services/entry_services.dart';
import 'package:edusocial/services/people_profile_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/profile_model.dart';
import '../models/entry_model.dart';
import '../models/user_model.dart';
import '../models/people_profile_model.dart';
import '../services/profile_service.dart';
import '../notification/onesignal_service.dart';
import 'package:get_storage/get_storage.dart';

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

  // 📊 Filtrelenmiş sayılar
  var filteredFollowers = 0.obs;
  var filteredFollowing = 0.obs;
  
  // 📬 API'dan gelen okunmamış mesaj sayısı
  var unreadMessagesTotalCount = 0.obs;

  // 📝 Kullanıcının entries'ları (PeopleProfileScreen'deki gibi)
  var personEntries = <EntryModel>[].obs;

  // Kullanıcı cache'i - performans için (PeopleProfileController'dan alındı)
  final Map<int, UserModel> _userCache = {};

  // 📊 Filtrelenmiş takipçi sayısını hesapla
  void calculateFilteredFollowers() {
    final approvedFollowers = followerList.where((follower) {
      final isPending = follower['is_following_pending'] == true;
      return !isPending; // Pending olmayanları say
    }).toList();
    
    filteredFollowers.value = approvedFollowers.length;
    debugPrint("📊 Filtered Followers: ${filteredFollowers.value} (Total: ${followerList.length})");
  }

  // 📊 Filtrelenmiş takip edilen sayısını hesapla
  void calculateFilteredFollowing() {
    final approvedFollowings = followingList.where((following) {
      final isFollowing = following['is_following'] == true;
      final isPending = following['is_following_pending'] == true;
      return isFollowing && !isPending; // Takip ediliyor ve pending değil
    }).toList();
    
    filteredFollowing.value = approvedFollowings.length;
    debugPrint("📊 Filtered Following: ${filteredFollowing.value} (Total: ${followingList.length})");
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

  /// Profil postlarını ayrı bir endpoint'ten çek (Eski yöntem - geriye uyumluluk için)
  Future<void> fetchProfilePosts() async {
    try {
      debugPrint("🔄 fetchProfilePosts() başlatıldı");
      
      // /me endpoint'inden gelen profil verisindeki postları kullan
      final profileData = profile.value;
      if (profileData != null) {
        debugPrint("📦 /me endpoint'inden ${profileData.posts.length} post alındı");
        
        // Her post için detaylı debug
        for (int i = 0; i < profileData.posts.length; i++) {
          final post = profileData.posts[i];
          debugPrint("📋 Post ${i + 1}: ID=${post.id}, Content=${post.postDescription}, isOwner=${post.isOwner}, MediaUrls=${post.mediaUrls.length}");
          if (post.mediaUrls.isNotEmpty) {
            debugPrint("🖼️ Post ${i + 1} Media URLs: ${post.mediaUrls}");
          }
        }
        
        // /me endpoint'inden gelen postlar zaten kullanıcının kendi postları
        final userPosts = profileData.posts;
        debugPrint("👤 /me endpoint'inden gelen post sayısı: ${userPosts.length}");
        
        // Hesap tipi kontrolü - kendi profilimizde olduğumuz için her zaman göster
        final currentAccountType = profile.value?.accountType ?? 'public';
        debugPrint("🔍 Mevcut hesap tipi: $currentAccountType");
        
        if (currentAccountType == 'private') {
          debugPrint("🔒 Private hesap tespit edildi, ancak kendi postlarımız her zaman görünür");
        }
        
        profilePosts.assignAll(userPosts);
        postCount.value = userPosts.length;
        
        debugPrint("✅ Profile postları yüklendi: ${userPosts.length} post");
        debugPrint("🔍 Hesap tipi: ${profile.value?.accountType ?? 'unknown'}");
        debugPrint("👤 Kullanıcının kendi postları her zaman görünür");
      } else {
        debugPrint("⚠️ /me endpoint'inden post verisi bulunamadı");
        profilePosts.clear();
        postCount.value = 0;
      }
      
    } catch (e) {
      debugPrint("❌ Profile postları yükleme hatası: $e");
    }
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    _userCache.clear(); // Cache'i temizle
    
    try {
      debugPrint("🔄 ProfileController.loadProfile() başlatıldı");
      
      // Token kontrolü
      final box = GetStorage();
      final token = box.read('token');
      if (token == null || token.isEmpty) {
        throw Exception("Token bulunamadı");
      }
      debugPrint("🔑 Token kontrolü başarılı");
      
      // Önce /me endpoint'inden temel profil verilerini al
      debugPrint("📥 Temel profil verisi çekiliyor (/me endpoint)...");
      final profileData = await _profileService.fetchProfileData();
      profile.value = profileData;
      userId.value = profileData.id.toString();
      
      // GetStorage'a user_id kaydet ve OneSignal'e login yap
      final userIdStr = profileData.id.toString();
      if (userIdStr.isNotEmpty) {
        box.write('user_id', userIdStr);
        try {
          final oneSignal = Get.find<OneSignalService>();
          await oneSignal.loginUser(userIdStr);
          debugPrint('✅ OneSignal login completed for user_id: $userIdStr');
        } catch (e) {
          debugPrint('⚠️ OneSignal login error: $e');
        }
      }
      
      // Temel veriler
      fullName.value = "${profileData.name} ${profileData.surname}";
      username.value = "@${profileData.username}";
      profileImage.value = profileData.avatarUrl;
      coverImage.value = profileData.bannerUrl;
      bio.value = profileData.description ?? '';
      birthDate.value = profileData.birthDate;
      lessons.value = profileData.lessons;
      
      // Okul ve Bölüm Bilgileri
      schoolName.value = profileData.school?.name ?? 'Okul bilgisi yok';
      schoolDepartment.value = profileData.schoolDepartment?.title ?? 'Bölüm bilgisi yok';
      
      // Takipçi ve takip edilen sayıları
      followers.value = profileData.followers.length;
      following.value = profileData.followings.length;
      followerList.assignAll(profileData.followers);
      followingList.assignAll(profileData.followings);
      
      // API'dan gelen okunmamış mesaj sayısını al
      unreadMessagesTotalCount.value = profileData.unreadMessagesTotalCount;
      debugPrint("📬 API'dan gelen okunmamış mesaj sayısı: ${unreadMessagesTotalCount.value}");
      
      
      // Filtrelenmiş sayıları hesapla
      calculateFilteredFollowers();
      calculateFilteredFollowing();
      
      debugPrint("📊 Takipçi ve takip edilen verileri:");
      debugPrint("  - Followers: ${followers.value} (Filtered: ${filteredFollowers.value})");
      debugPrint("  - Following: ${following.value} (Filtered: ${filteredFollowing.value})");
      
      // 🚀 Temel profil verisi yüklendi, UI'ı hemen göster
      isLoading.value = false;
      debugPrint("✅ Temel profil verisi UI'da gösteriliyor");
      
      // 🔄 Şimdi PeopleProfileService ile detaylı verileri yükle
      debugPrint("🔄 PeopleProfileService ile detaylı veriler yükleniyor...");
      await _loadDetailedProfileData(profileData.username);
      
      // 🔄 Diğer veriler paralel olarak arka planda yüklenir
      debugPrint("🔄 Arka plan verileri yükleniyor...");
      _updateRelatedData().then((_) {
        debugPrint("✅ Tüm profil verileri yüklendi");
      }).catchError((e) {
        debugPrint("❌ Arka plan veri yükleme hatası: $e");
      });
      
    } catch (e) {
      debugPrint("❌ Profil yükleme hatası: $e");
      isLoading.value = false;
      rethrow;
    }
  }


  /// PeopleProfileService ile detaylı profil verilerini yükle
  Future<void> _loadDetailedProfileData(String username) async {
    try {
      debugPrint("🔄 _loadDetailedProfileData() başlatıldı: $username");
      
      final data = await PeopleProfileService.fetchUserByUsername(username);
      debugPrint("📥 PeopleProfileService'den dönen data: ${data != null ? 'VAR' : 'YOK'}");
      
      if (data != null) {
        debugPrint("✅ PeopleProfileService'den veri alındı:");
        debugPrint("  - Posts: ${data.posts.length}");
        debugPrint("  - Entries: ${data.entries.length}");
        
        // Posts'ları işle
        await _processPostsFromPeopleProfile(data.posts);
        
        // Entries'ları işle
        await _processEntriesFromPeopleProfile(data.entries);
        
        debugPrint("✅ Detaylı profil verileri yüklendi");
      } else {
        debugPrint("⚠️ PeopleProfileService'den veri alınamadı");
      }
    } catch (e) {
      debugPrint("❌ Detaylı profil veri yükleme hatası: $e");
    }
  } 

  /// Profil yüklendikten sonra ilgili verileri güncelle
  Future<void> _updateRelatedData() async {
    // AppBar ve Story'leri paralel güncelle
    await Future.wait([
      Future(() async {
        try {
          appBarController.fetchAndSetProfileImage();
        } catch (e) {
          debugPrint("❌ AppBar güncelleme hatası: $e");
        }
      }),
      Future(() async {
        try {
          final storyController = Get.find<StoryController>();
          storyController.fetchStories();
        } catch (e) {
          debugPrint("❌ Story güncelleme hatası: $e");
        }
      }),
    ]);
  }

  void getToSettingScreen() async {
    Get.toNamed("/settings");
  }

  void getToUserSettingScreen() async {
    Get.toNamed("/userSettings");
  }

  @override
  void onClose() {
    // Controller dispose edildiğinde cache'i temizle
    _userCache.clear();
    super.onClose();
  }

  void getToPeopleProfileScreen(String username) async {
    Get.to(() =>
            PeopleProfileScreen(username: username)); // ✅ burada userId eklenmeli
  }

  void updateProfile(String name, String newBio) {
    fullName.value = name;
    bio.value = newBio;
  }

  /// Entry'ye oy verme işlemi
  Future<void> voteEntry(int entryId, String vote) async {
    try {
      final success = await EntryServices.voteEntry(
        vote: vote,
        entryId: entryId,
      );

      if (success) {
        final indexInProfile = personEntries.indexWhere((entry) => entry.id == entryId);
        if (indexInProfile != -1) {
          final currentEntry = personEntries[indexInProfile];
          int newUpvotes = currentEntry.upvotescount;
          int newDownvotes = currentEntry.downvotescount;
          bool? newIsLike = currentEntry.islike;
          bool? newIsDislike = currentEntry.isdislike;

          if (vote == "up") {
            if (newIsLike == true) {
              newUpvotes--;
              newIsLike = false;
            } else {
              newUpvotes++;
              newIsLike = true;
              if (newIsDislike == true) {
                newDownvotes--;
                newIsDislike = false;
              }
            }
          } else if (vote == "down") {
            if (newIsDislike == true) {
              newDownvotes--;
              newIsDislike = false;
            } else {
              newDownvotes++;
              newIsDislike = true;
              if (newIsLike == true) {
                newUpvotes--;
                newIsLike = false;
              }
            }
          }

          final updatedEntry = currentEntry.copyWith(
            upvotescount: newUpvotes,
            downvotescount: newDownvotes,
            islike: newIsLike,
            isdislike: newIsDislike,
          );

          personEntries[indexInProfile] = updatedEntry;
        }
      }
    } catch (e) {
      debugPrint("❌ Entry oy verme hatası: $e");
    }
  }

  /// PeopleProfileService'den gelen posts'ları işle
  Future<void> _processPostsFromPeopleProfile(List<PostModel> posts) async {
    try {
      debugPrint("🔄 _processPostsFromPeopleProfile() başlatıldı: ${posts.length} post");
      
      // PeopleProfileService'den gelen posts'lar zaten kullanıcının kendi posts'ları
      profilePosts.assignAll(posts);
      postCount.value = posts.length;
      
      debugPrint("✅ Profile posts yüklendi: ${posts.length} post");
      debugPrint("👤 Kullanıcının kendi posts'ları her zaman görünür");
      
    } catch (e) {
      debugPrint("❌ Profile posts işleme hatası: $e");
    }
  }

  /// PeopleProfileService'den gelen entries'ları işle
  Future<void> _processEntriesFromPeopleProfile(List<EntryModel> entries) async {
    try {
      debugPrint("🔄 _processEntriesFromPeopleProfile() başlatıldı: ${entries.length} entry");
      
      if (entries.isEmpty) {
        personEntries.assignAll([]);
        return;
      }

      // 1. Önce tüm benzersiz topic user_id'lerini topla
      final Set<int> uniqueUserIds = {};
      for (final entry in entries) {
        final topicUserId = entry.topic?.userId;
        if (topicUserId != null) {
          uniqueUserIds.add(topicUserId);
        }
      }

      debugPrint("🔍 ${uniqueUserIds.length} benzersiz kullanıcı ID'si bulundu");

      // 2. Tüm kullanıcıları batch olarak çek
      if (uniqueUserIds.isNotEmpty) {
        final userDataMap = await PeopleProfileService.fetchUsersByIds(uniqueUserIds.toList());
        
        // Cache'e ekle
        for (final entry in userDataMap.entries) {
          _userCache[entry.key] = _createUserModelFromProfile(entry.value);
        }
        
        debugPrint("✅ ${_userCache.length} kullanıcı verisi batch olarak cache'lendi");
      }

      // 3. Entry'leri işle ve cache'den kullanıcı bilgilerini al
      final processedEntries = entries.map((entry) {
        final topicUserId = entry.topic?.userId;
        
        if (topicUserId != null && _userCache.containsKey(topicUserId)) {
          final user = _userCache[topicUserId]!;
          
          return EntryModel(
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
        } else {
          // Cache'de yoksa orijinal entry'yi kullan
          return entry;
        }
      }).toList();

      personEntries.assignAll(processedEntries);
      debugPrint("✅ Tüm entries optimize edilmiş şekilde işlendi");
      
    } catch (e) {
      debugPrint("❌ Entries işleme hatası: $e");
      // Hata durumunda orijinal entries'ları kullan
      personEntries.assignAll(entries);
    }
  }

  /// PeopleProfileModel'den UserModel oluştur
  UserModel _createUserModelFromProfile(PeopleProfileModel profile) {
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
      avatarUrl: profile.avatarUrl.isNotEmpty ? profile.avatarUrl : profile.avatar,
      bannerUrl: profile.bannerUrl,
      isFollowing: profile.isFollowing,
      isFollowingPending: profile.isFollowingPending,
      isSelf: profile.isSelf,
    );
  }

  }
