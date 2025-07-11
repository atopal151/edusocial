import 'package:edusocial/services/comment_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/comment_model.dart';

class CommentController extends GetxController {
  var commentList = <CommentModel>[].obs;
  var isLoading = false.obs;

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
    try {
      debugPrint('🔄 Yorum ekleniyor... Post ID: $postId');
      final success = await CommentService.postComment(postId, content);
      
      if (success) {
        debugPrint('✅ Yorum başarıyla eklendi');
        // Yorumları yeniden yükle
        await fetchComments(postId);
      } else {
        debugPrint('❌ Yorum eklenemedi');
      }
    } catch (e) {
      debugPrint('❌ Yorum eklenirken hata: $e');
    }
  }
}
