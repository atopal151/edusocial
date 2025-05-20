import 'package:edusocial/services/people_profile_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/profile_model.dart';

class PeopleProfileController extends GetxController {
  var isLoading = true.obs; // Profil genel yüklenme durumu
  var isFollowLoading = false.obs; // Takip/çıkar butonu loading
  var isFollowing = false.obs; // Kullanıcı takip ediliyor mu
  var profile = Rxn<ProfileModel>(); // Kullanıcı profili

  /// 👤 Kullanıcı profilini getir
  Future<void> loadUserProfile(int userId) async {
    try {
      isLoading.value = true;
      //debugPrint("🔄 Profil yükleniyor: userId = $userId");

      final data = await PeopleProfileService.fetchUserById(userId);
      if (data != null) {
        profile.value = data;
        isFollowing.value = data.isFollowing;
       // debugPrint("✅ Profil yüklendi: ${data.name} ${data.surname}");
        //debugPrint("👥 isFollowing: ${isFollowing.value}");
      } else {
        debugPrint("⚠️ Profil verisi boş döndü");
      }
    } catch (e) {
      debugPrint("❌ Profil yüklenirken hata oluştu: $e", wrapWidth: 1024);
    } finally {
      isLoading.value = false;
    }
  }

  /// ➕ Kullanıcıyı takip et
  Future<void> followUser(int userId) async {
    try {
      isFollowLoading.value = true;
      debugPrint("📩 Takip isteği gönderiliyor: userId = $userId");

      final result = await PeopleProfileService.followUser(userId);
      if (result) {
        isFollowing.value = true;
        debugPrint("✅ Takip edildi");

      } else {
        debugPrint("⚠️ Takip işlemi başarısız");
      }
    } catch (e) {
      debugPrint("❌ Takip sırasında hata: $e", wrapWidth: 1024);
    } finally {
      isFollowLoading.value = false;
    }
  }

  /// ➖ Kullanıcıyı takipten çıkar
  Future<void> unfollowUser(int userId) async {
    try {
      isFollowLoading.value = true;
      debugPrint("📤 Takip bırakma isteği gönderiliyor: userId = $userId");

      final result = await PeopleProfileService.unfollowUser(userId);
      if (result) {
        isFollowing.value = false;
        debugPrint("✅ Takip bırakıldı");

  await loadUserProfile(userId); // ⬅️ Profil yeniden çekilsin

      } else {
        debugPrint("⚠️ Takip bırakma işlemi başarısız");
      }
    } catch (e) {
      debugPrint("❌ Takip bırakma sırasında hata: $e", wrapWidth: 1024);
    } finally {
      isFollowLoading.value = false;
    }
  }
}
