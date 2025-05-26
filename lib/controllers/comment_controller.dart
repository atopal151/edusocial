import 'package:edusocial/services/comment_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/comment_model.dart';

class CommentController extends GetxController {
  var commentList = <CommentModel>[].obs;
  var isLoading = false.obs;

  Future<void> fetchComments(String postId) async {
    isLoading.value = true;
    final comments = await CommentService.fetchComments(postId);
    commentList.assignAll(comments);

        debugPrint('Comment: $comments');
    isLoading.value = false;
  }

  Future<void> addComment(String postId, String content) async {
    final success = await CommentService.postComment(postId, content);
    if (success) {
      fetchComments(postId);
    }
  }
}
