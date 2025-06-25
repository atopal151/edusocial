import 'dart:io';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:edusocial/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/post_model.dart';
import '../components/snackbars/custom_snackbar.dart';

class PostController extends GetxController {
  final ProfileController profileController = Get.find<ProfileController>();

  var isLoading = true.obs;
  var isHomeLoading = true.obs;
  var postList = <PostModel>[].obs;
  var postHomeList = <PostModel>[].obs;

  var selectedPost = Rxn<PostModel>();
  var isPostDetailLoading = false.obs;
  

//POST GET
  Future<void> fetchHomePosts() async {
    //debugPrint("🔄 PostController.fetchHomePosts() çağrıldı");
    isHomeLoading.value = true;
    try {
      final posts = await PostServices.fetchHomePosts();
    // debugPrint("📦 API'den ${posts.length} post alındı");
      postHomeList.assignAll(posts);
      
      // 🔍 Sadece bana ait gönderileri filtrele
      final myPosts = posts.where((post) => post.isOwner == true).toList();
      //debugPrint("👤 Kullanıcıya ait ${myPosts.length} post bulundu");
      profileController.profilePosts.assignAll(myPosts);
      
      //debugPrint("✅ Postlar başarıyla yüklendi");
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
  Future<void> createPost(String content, List<File> mediaFiles, {List<String>? links}) async {
    try {
      final success = await PostServices.createPost(content, mediaFiles, links: links);
      if (success) {
        CustomSnackbar.show(
          title: "Başarılı",
          message: "Gönderi paylaşıldı",
          type: SnackbarType.success,
        );
        
        fetchHomePosts(); // Yeni postu listeye eklemek için
      } else {
        CustomSnackbar.show(
          title: "Hata",
          message: "Gönderi paylaşılamadı",
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: "Hata",
        message: "Bir hata oluştu: $e",
        type: SnackbarType.error,
      );
    }
  }

  //postlike

  Future<void> toggleLike(String postId) async {
    final success = await PostServices.toggleLike(postId);
    if (!success) {
      CustomSnackbar.show(
        title: "Hata",
        message: "Beğeni işlemi başarısız oldu.",
        type: SnackbarType.error,
      );
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final success = await PostServices.deletePost(postId);
      if (success) {
        CustomSnackbar.show(
          title: "Başarılı",
          message: "Gönderi başarıyla silindi",
          type: SnackbarType.success,
        );
        fetchHomePosts(); // Listeyi güncelle
      } else {
        CustomSnackbar.show(
          title: "Hata",
          message: "Gönderi silinemedi",
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: "Hata",
        message: "Bir hata oluştu: $e",
        type: SnackbarType.error,
      );
    }
  }
}
