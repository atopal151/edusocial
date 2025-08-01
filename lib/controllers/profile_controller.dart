import 'package:edusocial/controllers/appbar_controller.dart';
import 'package:edusocial/controllers/story_controller.dart';
import 'package:edusocial/models/post_model.dart';
import 'package:edusocial/screens/profile/people_profile_screen.dart';
import 'package:edusocial/services/post_service.dart';
import 'package:edusocial/services/entry_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/profile_model.dart';
import '../models/entry_model.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
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
    try {
      final posts = await PostServices.fetchHomePosts();
      final userPosts = posts.where((post) => post.isOwner).toList();
      
      profilePosts.assignAll(userPosts);
      postCount.value = userPosts.length;
      
      debugPrint("✅ Profile postları yüklendi: ${userPosts.length} post");
      
    } catch (e) {
      debugPrint("❌ Profile postları yükleme hatası: $e");
    }
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    
    try {
      // Token kontrolü
      final box = GetStorage();
      final token = box.read('token');
      if (token == null || token.isEmpty) {
        throw Exception("Token bulunamadı");
      }
      
      // Ana profil verisi
      final profileData = await _profileService.fetchProfileData();
      profile.value = profileData;
      userId.value = profileData.id.toString();
      
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
      
      // 🚀 Ana profil verisi yüklendi, UI'ı hemen göster
      isLoading.value = false;
      
      // 🔄 Diğer veriler paralel olarak arka planda yüklenir
      Future.wait([
        fetchProfilePosts(),
        _fetchEntriesFromUsername(profileData.username),
      ]).then((_) {
        _updateRelatedData();
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

  /// Profil yüklendikten sonra ilgili verileri güncelle
  void _updateRelatedData() {
    // AppBar ve Story'leri paralel güncelle
    Future.wait([
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

  /// Username'den entries'ları çek
  Future<void> _fetchEntriesFromUsername(String username) async {
    try {
      final userData = await ProfileService.fetchUserByUsername(username);
      
      if (userData != null && userData.entries.isNotEmpty) {
        final processedEntries = <EntryModel>[];
        
        for (final entry in userData.entries) {
          final user = UserModel(
            id: int.tryParse(userData.id.toString()) ?? 0,
            accountType: userData.accountType,
            languageId: int.tryParse(userData.languageId?.toString() ?? '1') ?? 1,
            avatar: userData.avatar,
            banner: userData.banner,
            schoolId: int.tryParse(userData.schoolId?.toString() ?? '1') ?? 1,
            schoolDepartmentId: int.tryParse(userData.schoolDepartmentId?.toString() ?? '1') ?? 1,
            name: userData.name,
            surname: userData.surname,
            username: userData.username,
            email: userData.email,
            phone: userData.phone,
            birthday: userData.birthDate.isNotEmpty ? DateTime.tryParse(userData.birthDate) : null,
            instagram: userData.instagram,
            tiktok: userData.tiktok,
            twitter: userData.twitter,
            facebook: userData.facebook,
            linkedin: userData.linkedin,
            notificationEmail: userData.notificationEmail,
            notificationMobile: userData.notificationMobile,
            isActive: userData.isActive,
            isOnline: userData.isOnline,
            avatarUrl: userData.avatarUrl.isNotEmpty ? userData.avatarUrl : userData.avatar,
            bannerUrl: userData.bannerUrl,
            isFollowing: userData.isFollowing,
            isFollowingPending: userData.isFollowingPending,
            isSelf: userData.isSelf,
          );
          
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
        }
        
        personEntries.assignAll(processedEntries);
        debugPrint("✅ Profile entries yüklendi: ${processedEntries.length}");
        
      } else {
        personEntries.clear();
      }
      
    } catch (e) {
      debugPrint("❌ Profile entries yükleme hatası: $e");
      personEntries.clear();
    }
  }
/*
  /// Entries'ları topic user_id'lerine göre kullanıcı bilgileriyle işle
  Future<void> _processEntriesWithUserData(List<EntryModel> entries) async {
    try {
      final processedEntries = <EntryModel>[];
      
      for (final entry in entries) {
        final topicUserId = entry.topic?.userId;
        
        if (topicUserId != null) {
          final userData = await PeopleProfileService.fetchUserById(topicUserId);
          
          if (userData != null) {
            final user = _createUserModelFromProfile(userData);
            
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
          } else {
            processedEntries.add(entry);
          }
        } else {
          processedEntries.add(entry);
        }
      }
      
      personEntries.assignAll(processedEntries);
      debugPrint("✅ Entries kullanıcı bilgileriyle işlendi: ${processedEntries.length}");
      
    } catch (e) {
      debugPrint("❌ Entries işleme hatası: $e");
      personEntries.assignAll(entries);
    }
  }
*/
/*
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
  */
  }
