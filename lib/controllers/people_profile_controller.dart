import 'package:edusocial/models/people_profile_model.dart';
import 'package:edusocial/models/entry_model.dart';
import 'package:edusocial/models/user_model.dart';
import 'package:edusocial/services/people_profile_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PeopleProfileController extends GetxController {
  var isLoading = true.obs; // Profil genel yüklenme durumu
  var isEntriesLoading = false.obs; // Entries yüklenme durumu
  var isFollowLoading = false.obs; // Takip/çıkar butonu loading
  var isFollowing = false.obs; // Kullanıcı takip ediliyor mu
  var isFollowingPending = false.obs; // Takip isteği bekliyor mu
  var profile = Rxn<PeopleProfileModel>(); // Kullanıcı profili
  var peopleEntries = <EntryModel>[].obs; // Kullanıcının entries'ları

  /// Görüntülenen kullanıcının takipçi listesi (API'den)
  var followersList = <Map<String, dynamic>>[].obs;
  /// Görüntülenen kullanıcının takip edilen listesi (API'den)
  var followingsList = <Map<String, dynamic>>[].obs;
  var isFollowersLoading = false.obs;
  var isFollowingsLoading = false.obs;

  // Kullanıcı cache'i - performans için
  final Map<int, UserModel> _userCache = {};

  /// Username ile profil çekme
  Future<void> loadUserProfileByUsername(String username) async {
    try {
      isLoading.value = true;
      isEntriesLoading.value = true;
      _userCache.clear(); // Cache'i temizle
      //debugPrint("🔄 Profil yükleniyor: $username");

      final data = await PeopleProfileService.fetchUserByUsername(username);
      //debugPrint("📥 Service'den dönen data: ${data != null ? 'VAR' : 'YOK'}");
      
      if (data != null) {
        profile.value = data;
        isFollowing.value = data.isFollowing;
        isFollowingPending.value = data.isFollowingPending;
        followersList.clear();
        followingsList.clear();

        // Profil bilgileri yüklendi, ana loading'i kapat
        isLoading.value = false;

        // Tek API çağrısı ile takipçi ve takip edilen listelerini yükle
        loadFollowLists(data.id);

        // Entries'ları ayrı olarak yükle (progressive loading)
        if (data.entries.isNotEmpty) {
          //debugPrint("📝 Entries sayısı: ${data.entries.length}");
          await _processEntriesWithUserDataOptimized(data.entries);
          //debugPrint("✅ Kullanıcının ${data.entries.length} entries'ı yüklendi");
        } else {
          peopleEntries.assignAll([]);
        }
      } else {
        //debugPrint("⚠️ Profil verisi boş döndü (username: $username)");
        isLoading.value = false;
      }
    } catch (e) {
      debugPrint("❌ Profil yüklenirken hata oluştu: $e");
      isLoading.value = false;
    } finally {
      isEntriesLoading.value = false;
    }
  }

  /// Optimize edilmiş entries işleme - tek seferde tüm kullanıcıları çeker
  Future<void> _processEntriesWithUserDataOptimized(List<EntryModel> entries) async {
    try {
      if (entries.isEmpty) {
        peopleEntries.assignAll([]);
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

      //debugPrint("🔍 ${uniqueUserIds.length} benzersiz kullanıcı ID'si bulundu");

      // 2. Tüm kullanıcıları batch olarak çek
      if (uniqueUserIds.isNotEmpty) {
        final userDataMap = await PeopleProfileService.fetchUsersByIds(uniqueUserIds.toList());
        
        // Cache'e ekle
        for (final entry in userDataMap.entries) {
          _userCache[entry.key] = _createUserModelFromProfile(entry.value);
        }
        
        //debugPrint("✅ ${_userCache.length} kullanıcı verisi batch olarak cache'lendi");
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

      peopleEntries.assignAll(processedEntries);
      //debugPrint("✅ Tüm entries optimize edilmiş şekilde işlendi");
      
    } catch (e) {
      debugPrint("❌ Entries işleme hatası: $e");
      // Hata durumunda orijinal entries'ları kullan
      peopleEntries.assignAll(entries);
    }
  }
/*
  /// Eski yöntem - geriye uyumluluk için tutuldu
  Future<void> _processEntriesWithUserData(List<EntryModel> entries) async {
    try {
      final processedEntries = <EntryModel>[];
      
      for (final entry in entries) {
        // Topic'in user_id'sini al
        final topicUserId = entry.topic?.userId;
        
        if (topicUserId != null) {
          //debugPrint("👤 Topic kullanıcısı için bilgi çekiliyor: user_id = $topicUserId");
          
          // Kullanıcı bilgilerini API'den çek
          final userData = await PeopleProfileService.fetchUserById(topicUserId);
          
          if (userData != null) {
            // Kullanıcı bilgilerini debug et
            //debugPrint("📸 Kullanıcı avatar bilgileri:");
            //debugPrint("  - Avatar URL: ${userData.avatarUrl}");
            //debugPrint("  - Avatar: ${userData.avatar}");
            //debugPrint("  - Name: ${userData.name} ${userData.surname}");
            //debugPrint("  - Username: ${userData.username}");
            
            // API'den gelen ham veriyi de kontrol et
            //debugPrint("🔍 API'den gelen ham veri kontrolü:");
            //debugPrint("  - avatarUrl alanı: '${userData.avatarUrl}'");
            //debugPrint("  - avatar alanı: '${userData.avatar}'");
            //debugPrint("  - avatarUrl boş mu: ${userData.avatarUrl.isEmpty}");
            //debugPrint("  - avatar boş mu: ${userData.avatar.isEmpty}");
            
            // Kullanıcı bilgilerini UserModel'e dönüştür
            final user = _createUserModelFromProfile(userData);
            
            // UserModel'deki avatar bilgilerini de debug et
            //debugPrint("🖼️ UserModel avatar bilgileri:");
            //debugPrint("  - Avatar URL: ${user.avatarUrl}");
            //debugPrint("  - Avatar: ${user.avatar}");
            //debugPrint("  - Kullanılan avatar alanı: ${user.avatarUrl.isNotEmpty ? 'avatarUrl' : 'avatar'}");
            
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
            //debugPrint("✅ Entry ${entry.id} için kullanıcı bilgileri yüklendi: ${user.name} ${user.surname}");
          } else {
            //debugPrint("⚠️ Kullanıcı bilgileri alınamadı: user_id = $topicUserId");
            processedEntries.add(entry); // Orijinal entry'yi ekle
          }
        } else {
          debugPrint("⚠️ Topic user_id bulunamadı, orijinal entry kullanılıyor");
          processedEntries.add(entry); // Orijinal entry'yi ekle
        }
      }
      
      peopleEntries.assignAll(processedEntries);
      //debugPrint("✅ Tüm entries kullanıcı bilgileriyle işlendi");
      
    } catch (e) {
      debugPrint("❌ Entries işleme hatası: $e");
      // Hata durumunda orijinal entries'ları kullan
      peopleEntries.assignAll(entries);
    }
  }
*/
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

  /// userId ile profil çekme
  Future<void> loadUserProfile(int userId) async {
    try {
      isLoading.value = true;
      _userCache.clear(); // Cache'i temizle

      final data = await PeopleProfileService.fetchUserById(userId);
      if (data != null) {
        profile.value = data;
        isFollowing.value = data.isFollowing;
        isFollowingPending.value = data.isFollowingPending;
        followersList.clear();
        followingsList.clear();
        loadFollowLists(data.id);

        // API'den gelen entries verilerini kullanıcı bilgileriyle işle
        await _processEntriesWithUserDataOptimized(data.entries);
        //debugPrint("✅ Kullanıcının ${data.entries.length} entries'ı yüklendi");
      } else {
        debugPrint("⚠️ Profil verisi boş döndü");
      }
    } catch (e) {
      debugPrint("❌ Profil yüklenirken hata oluştu: $e", wrapWidth: 1024);
    } finally {
      isLoading.value = false;
    }
  }

  static const int _followListPerPage = 20;

  /// Tek API çağrısı ile takipçi ve takip edilen listelerini yükler (type alanına göre ayrılır)
  Future<void> loadFollowLists(int userId) async {
    try {
      isFollowersLoading.value = true;
      isFollowingsLoading.value = true;
      final result = await PeopleProfileService.fetchUserFollowList(userId,
          page: 1, perPage: _followListPerPage);
      followersList.assignAll(result['followers'] ?? []);
      followingsList.assignAll(result['followings'] ?? []);
    } catch (e) {
      debugPrint("❌ loadFollowLists error: $e");
      followersList.clear();
      followingsList.clear();
    } finally {
      isFollowersLoading.value = false;
      isFollowingsLoading.value = false;
    }
  }

  /// ➕ Kullanıcıyı takip et
  Future<void> followUser(int userId) async {
    try {
      isFollowLoading.value = true;
      //debugPrint("📩 Takip isteği gönderiliyor: userId = $userId");

      final result = await PeopleProfileService.followUser(userId);
      if (result) {
        // İsteğe göre backend pending mi true dönüyor yoksa isFollowing mi bilemiyoruz.
        // En garantili yöntem profili tekrar çekmek:
        await loadUserProfile(userId);
        debugPrint("✅ Takip edildi veya takip isteği gönderildi");
      } else {
        debugPrint("⚠️ Takip işlemi başarısız");
      }
    } catch (e) {
      debugPrint("❌ Takip sırasında hata: $e", wrapWidth: 1024);
    } finally {
      isFollowLoading.value = false;
    }
  }

  /// 🔄 Match kartından gelen takip durumunu güncelle
  void updateFollowStatusFromMatch(bool isFollowing, bool isPending) {
    debugPrint("🔄 Match kartından takip durumu güncelleniyor: isFollowing=$isFollowing, isPending=$isPending");
    this.isFollowing.value = isFollowing;
    isFollowingPending.value = isPending;
    debugPrint("✅ Takip durumu güncellendi");
  }

  /// ➖ Kullanıcıyı takipten çıkar
  Future<void> unfollowUser(int userId) async {
    try {
      isFollowLoading.value = true;
      debugPrint("📤 Takip bırakma isteği gönderiliyor: userId = $userId");

      final result = await PeopleProfileService.unfollowUser(userId);
      if (result) {
        await loadUserProfile(userId); // 🔥 Profil yeniden çekilsin
        debugPrint("✅ Takip bırakıldı");
      } else {
        debugPrint("⚠️ Takip bırakma işlemi başarısız");
      }
    } catch (e) {
      debugPrint("❌ Takip bırakma sırasında hata: $e", wrapWidth: 1024);
    } finally {
      isFollowLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Controller dispose edildiğinde cache'i temizle
    _userCache.clear();
    super.onClose();
  }
}
