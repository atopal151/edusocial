import 'package:edusocial/services/comment_services.dart';
import 'package:edusocial/services/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/comment_model.dart';
import '../components/snackbars/custom_snackbar.dart';

class CommentController extends GetxController {
  var commentList = <CommentModel>[].obs;
  var isLoading = false.obs;
  
  // Socket servisi
  late SocketService _socketService;

  @override
  void onInit() {
    super.onInit();
    _socketService = Get.find<SocketService>();
  }

  Future<void> fetchComments(String postId) async {
    try {
      isLoading.value = true;
      debugPrint('🔄 Yorumlar yükleniyor... Post ID: $postId');
      
      final comments = await CommentService.fetchComments(postId);
      commentList.assignAll(comments);
      
      debugPrint('✅ ${comments.length} yorum yüklendi');
    } catch (e) {
      debugPrint('❌ Yorumlar yüklenirken hata: $e');
      commentList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addComment(String postId, String content) async {
    isLoading.value = true;
    
    try {
      debugPrint('🔄 Yorum ekleniyor... Post ID: $postId');
      final newComment = await CommentService.postComment(postId, content);
      
      if (newComment != null) {
        debugPrint('✅ Yorum başarıyla eklendi');
        
        // Socket'e yorum bildirimi gönder
        _sendCommentNotification(postId, content);
        
        // Yorumları yeniden yükle
        await fetchComments(postId);
      } else {
        debugPrint('❌ Yorum eklenemedi');
        CustomSnackbar.show(
          title: "Hata",
          message: "Yorum eklenemedi",
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      debugPrint('❌ Yorum eklenirken hata: $e');
      CustomSnackbar.show(
        title: "Hata",
        message: "Yorum eklenirken bir hata oluştu",
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Socket'e yorum bildirimi gönder
  void _sendCommentNotification(String postId, String content) {
    try {
      debugPrint('📤 Socket\'e yorum bildirimi gönderiliyor...');
      
      final notificationData = {
        'type': 'post_comment',
        'post_id': postId,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'Post\'unuza yeni yorum geldi',
      };
      
      // Farklı event isimlerini dene
      _socketService.sendMessage('post:comment', notificationData);
      _socketService.sendMessage('comment:new', notificationData);
      _socketService.sendMessage('post:activity', notificationData);
      
      debugPrint('✅ Yorum bildirimi socket\'e gönderildi');
    } catch (e) {
      debugPrint('❌ Socket bildirimi gönderilemedi: $e');
    }
  }

  /// Yorum düzenleme fonksiyonu
  Future<bool> editComment(String commentId, String postId, String content) async {
    isLoading.value = true;
    
    try {
      debugPrint('🔄 Yorum düzenleniyor... Comment ID: $commentId, Post ID: $postId');
      final success = await CommentService.editComment(commentId, postId, content);
      
      if (success) {
        debugPrint('✅ Yorum başarıyla düzenlendi');
        
        // Yorumları yeniden yükle
        await fetchComments(postId);
        
        CustomSnackbar.show(
          title: "Başarılı",
          message: "Yorum başarıyla düzenlendi",
          type: SnackbarType.success,
        );
        
        return true;
      } else {
        debugPrint('❌ Yorum düzenlenemedi');
        CustomSnackbar.show(
          title: "Hata",
          message: "Yorum düzenlenemedi",
          type: SnackbarType.error,
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Yorum düzenlenirken hata: $e');
      CustomSnackbar.show(
        title: "Hata",
        message: "Yorum düzenlenirken bir hata oluştu",
        type: SnackbarType.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Yorum silme fonksiyonu
  Future<bool> deleteComment(String commentId, String postId) async {
    isLoading.value = true;
    
    try {
      debugPrint('🔄 Yorum siliniyor... Comment ID: $commentId, Post ID: $postId');
      final success = await CommentService.deleteComment(commentId, postId);
      
      if (success) {
        debugPrint('✅ Yorum başarıyla silindi');
        
        // Yorumları yeniden yükle
        await fetchComments(postId);
        
        CustomSnackbar.show(
          title: "Başarılı",
          message: "Yorum başarıyla silindi",
          type: SnackbarType.success,
        );
        
        return true;
      } else {
        debugPrint('❌ Yorum silinemedi');
        CustomSnackbar.show(
          title: "Hata",
          message: "Yorum silinemedi",
          type: SnackbarType.error,
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Yorum silinirken hata: $e');
      CustomSnackbar.show(
        title: "Hata",
        message: "Yorum silinirken bir hata oluştu",
        type: SnackbarType.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
