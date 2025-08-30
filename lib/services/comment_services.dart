import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../models/comment_model.dart';
import '../../utils/constants.dart';

class CommentService {
  static final _box = GetStorage();

static Future<List<CommentModel>> fetchComments(String postId) async {
  final token = _box.read('token');
  try {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/timeline/posts/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10)); // 10 saniye timeout


    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final commentsData = body['data']?['post']?['comments'];


      if (commentsData is List) {
        return commentsData.map((e) => CommentModel.fromJson(e)).toList();
      } else {
        debugPrint('⚠️ comments listesi boş ya da format hatalı');
        return [];
      }
    } else {
      debugPrint('🔴 Hata: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    debugPrint("❌ fetchComments hatası: $e");
    return [];
  }
}

  static Future<CommentModel?> postComment(String postId, String content) async {
    final token = _box.read('token');
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/post-comment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'post_id': postId,
          'content': content,
        }),
      ).timeout(const Duration(seconds: 10)); // 10 saniye timeout

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        // Eğer API yeni yorumu döndürüyorsa
        if (body['data'] != null) {
          return CommentModel.fromJson(body['data']);
        }
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Yorum düzenleme servisi
  static Future<bool> editComment(String commentId, String postId, String content) async {
    final token = _box.read('token');
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/post-comment/$commentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'post_id': postId,
          'content': content,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Yorum silme servisi
  static Future<bool> deleteComment(String commentId, String postId) async {
    final token = _box.read('token');
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/post-comment/$commentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'post_id': postId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Yorum yanıtlama servisi
  static Future<CommentModel?> postCommentReply(String postId, String commentId, String content) async {
    final token = _box.read('token');
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/post-comment-reply'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'post_id': postId,
          'post_comment_id': commentId,
          'content': content,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        // Eğer API yeni yanıtı döndürüyorsa
        if (body['data'] != null) {
          return CommentModel.fromJson(body['data']);
        }
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
