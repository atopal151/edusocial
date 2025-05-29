import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/story_model.dart';
import '../services/story_service.dart';
import 'profile_controller.dart';

class StoryController extends GetxController {
  final isLoading = false.obs;

  /// 🔄 Diğer kullanıcıların hikayeleri
  final RxList<StoryModel> otherStories = <StoryModel>[].obs;

  /// 👤 Kullanıcının kendi hikayesi (tek model)
  final Rxn<StoryModel> myStory = Rxn<StoryModel>();

  final profileController = Get.find<ProfileController>();

  @override
  void onInit() {
    super.onInit();

    // Profil yüklendiğinde kendi story'yi de çek
    ever(profileController.userId, (id) {
      if (id.toString().isNotEmpty) {
        fetchStories();
      }
    });
  }
Future<void> fetchStories() async {
  try {
    isLoading.value = true;

    final allStories = await StoryService.fetchStories();
    final currentUserIdStr = profileController.userId.value.trim();

    if (currentUserIdStr.isEmpty) {
      debugPrint("⚠️ Kullanıcı ID boş, story filtrelenemiyor");
      return;
    }

    final currentUserId = int.tryParse(currentUserIdStr);
    if (currentUserId == null) {
      debugPrint("⚠️ Kullanıcı ID sayıya çevrilemedi: $currentUserIdStr");
      return;
    }

    final List<StoryModel> others = [];
    StoryModel? my;

    for (var story in allStories) {
      if (story.userId == currentUserId) {
        my = story;
      } else {
        others.add(story);
      }
    }

    myStory.value = my;
    otherStories.assignAll(others);

    // Debug çıktısı
    debugPrint('📋 My Story:');
    if (my != null) {
      debugPrint('👤 Ben: ${my.username}, ID: ${my.userId}, URL sayısı: ${my.storyUrls.length}');
      for (var url in my.storyUrls) {
        debugPrint('   - $url');
      }
    } else {
      debugPrint('❌ Kullanıcıya ait story bulunamadı');
    }

    debugPrint('📋 Other Stories:');
    for (var s in others) {
      debugPrint('➡️ Kullanıcı: ${s.username}, ID: ${s.userId}, URL sayısı: ${s.storyUrls.length}');
      for (var url in s.storyUrls) {
        debugPrint('   - $url');
      }
    }
  } catch (e) {
    debugPrint("❗ fetchStories error: $e");
  } finally {
    isLoading.value = false;
  }
}


/*
  /// 👤 Şu anki kullanıcıya ait story'yi serverdan yükle
  Future<void> loadMyStoryFromServer(String userId) async {
    final mediaList = await StoryService.fetchStoriesByUserId(userId);

    final updated = StoryModel(
      id: userId,
      userId: userId,
      username: profileController.username.value,
      profileImage: profileController.profileImage.value,
      isMyStory: true,
      isViewed: false,
      storyUrls: mediaList,
      createdAt: DateTime.now(),
      hasStory: mediaList.isNotEmpty,
    );

    myStory.value = updated;
  }
*/
  /// 📤 Yeni hikaye oluştur
  Future<void> createStory(File imageFile) async {
    isLoading.value = true;

    //final userId = profileController.userId.value;

    final success = await StoryService.createStory(imageFile);
    if (success) {
      debugPrint("✅ Story başarıyla oluşturuldu");

      // Yeniden yükle
      await fetchStories();
      // await loadMyStoryFromServer(userId);
    } else {
      debugPrint("❌ Story yüklenemedi");
    }

    isLoading.value = false;
  }

  /// 🔍 Diğer kullanıcıların story'lerini döner
  List<StoryModel> getOtherStories() => otherStories.toList();

  /// 👤 Kullanıcının story'sini döner
  StoryModel? getMyStory() => myStory.value;
}
