import 'package:edusocial/services/match_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/match_model.dart';
import '../nav_bar_controller.dart';

class MatchController extends GetxController {
  final TextEditingController textFieldController = TextEditingController();
  var savedTopics = <String>[].obs;
  var isLoading = false.obs;
  var matches = <MatchModel>[].obs;
  var currentIndex = 0.obs;

  final NavigationController navigationController = Get.find();

  MatchModel get currentMatch => matches[currentIndex.value];

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void findMatch() {
    Get.toNamed("/match");
  }

  void _loadMockData() {}

  void followUser() {
    Get.snackbar("Takip", "${currentMatch.name} takip edildi!",
        snackPosition: SnackPosition.BOTTOM);
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

  void findMatches() async {
    isLoading.value = true;

    final fetchedMatches = await MatchServices.fetchMatches();

    if (fetchedMatches.isNotEmpty) {
      matches.assignAll(fetchedMatches);
      currentIndex.value = 0;

      Get.back(); // önce eşleşme ekranından çık
      navigationController.changeIndex(2); // navbar indexini eşleşmeye ayarla
    } else {
      Get.snackbar(
        "Hata",
        "Eşleşecek kullanıcı bulunamadı.",
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back(); // başarısızsa sadece geri dön
    }

    isLoading.value = false;
  }
}
