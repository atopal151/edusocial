import 'dart:convert';
import 'package:flutter/widgets.dart';
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
        Uri.parse('${AppConstants.baseUrl}/timeline/posts/$postId/comments'),//değişecek
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
debugPrint('id: $postId');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'];

     
debugPrint('comment: $data');

        return data.map((e) => CommentModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
static Future<bool> postComment(String postId, String content) async {
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
    );

    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    return false;
  }
}

}
