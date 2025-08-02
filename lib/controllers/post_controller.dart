import 'dart:io';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:edusocial/services/post_service.dart';
import 'package:edusocial/services/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/post_model.dart';
import '../components/snackbars/custom_snackbar.dart';
import '../services/language_service.dart';
import 'dart:async';

class PostController extends GetxController {
  final ProfileController profileController = Get.find<ProfileController>();
  final LanguageService languageService = Get.find<LanguageService>();

  var isLoading = true.obs;
  var isHomeLoading = true.obs;
  var postList = <PostModel>[].obs;
  var postHomeList = <PostModel>[].obs;

  var selectedPost = Rxn<PostModel>();
  var isPostDetailLoading = false.obs;
  
  // Socket servisi
  late SocketService _socketService;
  late StreamSubscription _commentNotificationSubscription;

  @override
  void onInit() {
    super.onInit();
    _socketService = Get.find<SocketService>();
    _setupSocketListener();
  }

  @override
  void onClose() {
    _commentNotificationSubscription.cancel();
    super.onClose();
  }

  /// Socket event dinleyicisini ayarla
  void _setupSocketListener() {
    _commentNotificationSubscription = _socketService.onCommentNotification.listen((data) {
      debugPrint('💬 Post yorum bildirimi geldi (PostController): $data');
      
      // Post listesini yenile (yorum sayısı güncellenmiş olabilir)
      fetchHomePosts();
    });
  }

//POST GET
  Future<void> fetchHomePosts() async {
    debugPrint("🔄 PostController.fetchHomePosts() çağrıldı");
    isHomeLoading.value = true;
    try {
      final posts = await PostServices.fetchHomePosts();
      debugPrint("📦 API'den ${posts.length} post alındı");
      postHomeList.assignAll(posts);
      
      // 🔍 Sadece bana ait gönderileri filtrele
      final myPosts = posts.where((post) => post.isOwner == true).toList();
      debugPrint("👤 Kullanıcıya ait ${myPosts.length} post bulundu");
      profileController.profilePosts.assignAll(myPosts);
      
      debugPrint("✅ Postlar başarıyla yüklendi");
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
    // Boş içerik kontrolü
    if (content.trim().isEmpty) {
      CustomSnackbar.show(
        title: languageService.tr("common.warning"),
        message: languageService.tr("home.createPost.contentRequired"),
        type: SnackbarType.warning,
      );
      return;
    }
    try {
      final success = await PostServices.createPost(content, mediaFiles, links: links);
      if (success) {
        final LanguageService languageService = Get.find<LanguageService>();
        CustomSnackbar.show(
          title: languageService.tr("common.success"),
          message: languageService.tr("home.success.postCreated"),
          type: SnackbarType.success,
        );
        
        fetchHomePosts(); // Yeni postu listeye eklemek için
      } else {
        final LanguageService languageService = Get.find<LanguageService>();
        CustomSnackbar.show(
          title: languageService.tr("common.error"),
          message: languageService.tr("home.errors.postCreateFailed"),
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      final LanguageService languageService = Get.find<LanguageService>();
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: languageService.tr("home.createPost.postError"),
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

  /// Post şikayet etme
  Future<void> reportPost(int postId) async {
    try {
      final success = await PostServices.reportPost(postId);
      if (success) {
        CustomSnackbar.show(
          title: languageService.tr("common.report.success.title"),
          message: languageService.tr("common.report.success.message"),
          type: SnackbarType.success,
        );
      } else {
        CustomSnackbar.show(
          title: languageService.tr("common.report.error.title"),
          message: languageService.tr("common.report.error.message"),
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: languageService.tr("common.report.error.networkTitle"),
        message: languageService.tr("common.report.error.networkMessage"),
        type: SnackbarType.error,
      );
    }
  }
}
