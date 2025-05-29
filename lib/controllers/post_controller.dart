import 'dart:io';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:edusocial/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/post_model.dart';

class PostController extends GetxController {
  final ProfileController profileController = Get.find<ProfileController>();

  var isLoading = true.obs;
  var isHomeLoading = true.obs;
  var postList = <PostModel>[].obs;
  var postHomeList = <PostModel>[].obs;

  var selectedPost = Rxn<PostModel>();
  var isPostDetailLoading = false.obs;
  
  @override
  void onInit() {
    fetchHomePosts(); // Gerçek verileri çek
    super.onInit();
  }

//POST GET
  void fetchHomePosts() async {
    isHomeLoading.value = true;
    try {
      final posts = await PostServices.fetchHomePosts();
      postHomeList.assignAll(posts);
      // 🔍 Sadece bana ait gönderileri filtrele
      final myPosts = posts.where((post) => post.isOwner == true).toList();
      profileController.profilePosts.assignAll(myPosts);
    } catch (e) {
      debugPrint("❗ Post çekme hatası: $e", wrapWidth: 1024);
    } finally {
      isHomeLoading.value = false;
    }
  }

  /// Belirli bir gönderinin detayını getir
  Future<void> fetchPostDetail(String postId) async {
    isPostDetailLoading.value = true;
    try {
      final detail = await PostServices.fetchPostDetail(postId);
      if (detail != null) {
        selectedPost.value = detail;
      } else {
        Get.snackbar("Hata", "Gönderi detayları alınamadı.");
      }
    } catch (e) {
      debugPrint("❗ Post Detail Hatası: $e");
      Get.snackbar("Hata", "Detay alınırken sorun oluştu.");
    } finally {
      isPostDetailLoading.value = false;
    }
  }

//post create
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

  //postlike

  Future<void> toggleLike(String postId) async {
    final success = await PostServices.toggleLike(postId);
    if (!success) {
      Get.snackbar("Hata", "Beğeni işlemi başarısız oldu.");
    }
  }
}
