import 'package:edusocial/services/match_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/match_model.dart';

class MatchController extends GetxController {
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
          Get.snackbar("Hata", "'$topic' dersi zaten eklenmiş veya eklenemedi.",
              snackPosition: SnackPosition.BOTTOM);
        }
      }
      Get.snackbar("Başarılı", "Dersler profilinize kaydedildi!",
          snackPosition: SnackPosition.BOTTOM);
      
      Get.back();
      findMatches();
    } catch (e) {
      debugPrint("❗ Ders kaydedilirken hata: $e");
      Get.snackbar("Hata", "Bir hata oluştu.",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void followUser() async {
    final userId = currentMatch.userId;

    final success = await MatchServices.followUser(userId);
    if (success) {
      Get.snackbar("Takip", "${currentMatch.name} takip edildi!",
          snackPosition: SnackPosition.BOTTOM);

      // Match modelini güncelle
      matches[currentIndex.value] =
          matches[currentIndex.value].copyWith(isFollowing: true);
    } else {
      Get.snackbar("Hata", "Takip işlemi başarısız.",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void findMatch() {
    Get.toNamed("/match");
  }

  void findMatches() async {
    isLoading.value = true;
    try {
      debugPrint("🔄 Eşleşmeler yükleniyor...");
      final fetchedMatches = await MatchServices.findMatches();
      debugPrint("✅ ${fetchedMatches.length} eşleşme bulundu");
      
    
      matches.value = fetchedMatches;
      currentIndex.value = 0;
    } catch (e) {
      debugPrint("❌ Eşleşmeler yüklenirken hata: $e");
     
    } finally {
      isLoading.value = false;
    }
  }

  void startChat() {
    Get.toNamed("/chat_detail");
  }

  void nextMatch() {
    if (currentIndex.value < matches.length - 1) {
      currentIndex.value++;
    } else {
      currentIndex.value = 0; // Baştan başla
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
