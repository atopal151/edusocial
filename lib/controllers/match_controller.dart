import 'package:edusocial/services/match_service.dart';
import 'package:edusocial/services/language_service.dart';
import 'package:edusocial/components/snackbars/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/match_model.dart';

class MatchController extends GetxController {
  final LanguageService languageService = Get.find<LanguageService>();
  final TextEditingController textFieldController = TextEditingController();
  var savedTopics = <String>[].obs;
  var isLoading = false.obs;
  var matches = <MatchModel>[].obs;
  var currentIndex = 0.obs;

  MatchModel get currentMatch => matches[currentIndex.value];

  @override
  void onInit() {
    super.onInit();
    findMatches();
  }

  void addCoursesToProfile() async {
    isLoading.value = true;
    try {
      for (var topic in savedTopics) {
        bool success = await MatchServices.addLesson(topic);
        if (!success) {
          CustomSnackbar.show(
            title: languageService.tr("common.error"),
            message: "'$topic' ${languageService.tr("common.messages.courseAlreadyAdded")}",
            type: SnackbarType.error,
            duration: const Duration(seconds: 3),
          );
        }
      }
      CustomSnackbar.show(
        title: languageService.tr("common.success"),
        message: languageService.tr("common.messages.courseSavedToProfile"),
        type: SnackbarType.success,
        duration: const Duration(seconds: 3),
      );
      
      // Kurslar kaydedildikten sonra ana sayfaya dön
      Get.offAllNamed('/main');
    } catch (e) {
      debugPrint("❗ Ders kaydedilirken hata: $e");
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: languageService.tr("common.messages.generalError"),
        type: SnackbarType.error,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void followUser() async {
    final userId = currentMatch.userId;
    final isPrivate = currentMatch.isPrivate;

    final success = await MatchServices.followUser(userId);
    if (success) {
      // Profil gizlilik durumuna göre farklı mesajlar göster
      String message;
      if (isPrivate) {
        message = "${currentMatch.name} ${languageService.tr("common.messages.followRequestSent")}";
        // Gizli profil için pending durumunu güncelle
        matches[currentIndex.value] = matches[currentIndex.value].copyWith(isPending: true);
      } else {
        message = "${currentMatch.name} ${languageService.tr("common.messages.userFollowed")}";
        // Açık profil için following durumunu güncelle
        matches[currentIndex.value] = matches[currentIndex.value].copyWith(isFollowing: true);
      }

      CustomSnackbar.show(
        title: languageService.tr("common.success"),
        message: message,
        type: SnackbarType.success,
        duration: const Duration(seconds: 3),
      );
    } else {
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: languageService.tr("common.messages.followOperationFailed"),
        type: SnackbarType.error,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void findMatch() {
    Get.toNamed("/match");
  }

  void findMatches() async {
    isLoading.value = true;
    try {
      //debugPrint("🔄 Eşleşmeler yükleniyor...");
      final fetchedMatches = await MatchServices.findMatches();
     // debugPrint("✅ ${fetchedMatches.length} eşleşme bulundu");
      
    
      matches.value = fetchedMatches;
      currentIndex.value = 0;
    } catch (e) {
      debugPrint("❌ Eşleşmeler yüklenirken hata: $e");
     
    } finally {
      isLoading.value = false;
    }
  }

  void startChat() {
    // Mevcut eşleşmenin bilgilerini mesajlaşma sayfasına gönder
    Get.toNamed("/chat_detail", arguments: {
      'userId': currentMatch.userId,
      'userName': currentMatch.name,
      'userAvatar': currentMatch.profileImage,
      'username': currentMatch.username,
      'isOnline': currentMatch.isOnline,
    });
  }

  void nextMatch() {
    if (currentIndex.value < matches.length - 1) {
      currentIndex.value++;
    } else {
      // Eşleşmeler bittiyse yeni eşleşmeler getir
      findMatches();
    }
  }

  void addTopic() {
    if (textFieldController.text.isNotEmpty) {
      savedTopics.add(textFieldController.text);
      textFieldController.clear();
    }
  }

  void removeTopic(String topic) {
    savedTopics.remove(topic);
  }
}
