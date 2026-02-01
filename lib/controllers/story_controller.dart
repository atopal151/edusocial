import 'dart:io';
import 'package:edusocial/components/print_full_text.dart';
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


  Future<void> fetchStories() async {
    debugPrint("🔄 StoryController.fetchStories() çağrıldı");
    try {
      isLoading.value = true;

      final allStories = await StoryService.fetchStories();
      debugPrint("📦 API'den ${allStories.length} story alındı");
      printFullText('📦 API\'den ${allStories} story alındı');
      
      final currentUserIdStr = profileController.userId.value.trim();

      if (currentUserIdStr.isEmpty) {
        debugPrint("⚠️ Kullanıcı ID boş, story filtrelenemiyor");
        isLoading.value = false;
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
      
      debugPrint("✅ Story'ler başarıyla yüklendi - Benim: ${my != null ? 'Var' : 'Yok'}, Diğerleri: ${others.length}");
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
  /// 📤 Yeni hikaye oluştur (tek dosya)
  Future<void> createStory(File imageFile) async {
    await createMultipleStories([imageFile]);
  }

  /// 📤 Birden fazla hikaye oluştur
  Future<void> createMultipleStories(List<File> imageFiles) async {
    if (imageFiles.isEmpty) return;

    isLoading.value = true;

    final success = await StoryService.createMultipleStories(imageFiles);
    if (success) {
      debugPrint("✅ ${imageFiles.length} story başarıyla oluşturuldu");

      // Yeniden yükle
      await fetchStories();
    } else {
      debugPrint("❌ Story'ler yüklenemedi");
    }

    isLoading.value = false;
  }

  /// 🔍 Diğer kullanıcıların story'lerini döner
  List<StoryModel> getOtherStories() => otherStories.toList();

  /// 👤 Kullanıcının story'sini döner
  StoryModel? getMyStory() => myStory.value;
}
