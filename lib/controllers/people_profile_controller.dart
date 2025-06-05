import 'package:edusocial/models/people_profile_model.dart';
import 'package:edusocial/services/people_profile_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PeopleProfileController extends GetxController {
  var isLoading = true.obs; // Profil genel yüklenme durumu
  var isFollowLoading = false.obs; // Takip/çıkar butonu loading
  var isFollowing = false.obs; // Kullanıcı takip ediliyor mu
  var isFollowingPending = false.obs; // Takip isteği bekliyor mu
  var profile = Rxn<PeopleProfileModel>(); // Kullanıcı profili

  /// Username ile profil çekme
  Future<void> loadUserProfileByUsername(String username) async {
    try {
      isLoading.value = true;

      final data = await PeopleProfileService.fetchUserByUsername(username);
      if (data != null) {
        profile.value = data;
        isFollowing.value = data.isFollowing;
        isFollowingPending.value = data.isFollowingPending; // 🔥 Bunu ekledik
      } else {
        debugPrint("⚠️ Profil verisi boş döndü (username: $username)");
      }
    } catch (e) {
      debugPrint("❌ Profil yüklenirken hata oluştu: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// userId ile profil çekme
  Future<void> loadUserProfile(int userId) async {
    try {
      isLoading.value = true;

      final data = await PeopleProfileService.fetchUserById(userId);
      if (data != null) {
        profile.value = data;
        isFollowing.value = data.isFollowing;
        isFollowingPending.value = data.isFollowingPending; // 🔥 Bunu ekledik
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
}
