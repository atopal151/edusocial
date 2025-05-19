import 'dart:io';
import 'package:edusocial/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/post_model.dart';

class PostController extends GetxController {
  var isLoading = true.obs;
  var isHomeLoading = true.obs;
  var postList = <PostModel>[].obs;
  var postHomeList = <PostModel>[].obs;

  @override
  void onInit() {
    fetchHomePosts(); // Gerçek verileri çek
    super.onInit();
  }

  void fetchHomePosts() async {
    isHomeLoading.value = true;
    try {
      final posts = await PostServices.fetchHomePosts();
      postHomeList.assignAll(posts);
    } catch (e) {
      debugPrint("❗ Post çekme hatası: $e", wrapWidth: 1024);
    } finally {
      isHomeLoading.value = false;
    }
  }

  Future<void> createPost(String content, List<File> mediaFiles) async {
    try {
      isLoading.value = true;
      final success = await PostServices.createPost(content, mediaFiles);
      if (success) {
        Get.back();
        Get.snackbar("Başarılı", "Gönderi paylaşıldı");
        fetchHomePosts(); // Yeni postu listeye eklemek için
      } else {
        Get.snackbar("Hata", "Gönderi paylaşılamadı");
      }
    } catch (e) {
      Get.snackbar("Hata", "Bir hata oluştu: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
