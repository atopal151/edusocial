import 'dart:convert';
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

    /*debugPrint('🟡 Post ID: $postId');*/

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final commentsData = body['data']?['post']?['comments'];

      /*debugPrint("📦 Yorum verisi:\n${const JsonEncoder.withIndent('  ').convert(commentsData)}");*/

      if (commentsData is List) {
        return commentsData.map((e) => CommentModel.fromJson(e)).toList();
      } else {
        /*debugPrint('⚠️ comments listesi boş ya da format hatalı');*/
        return [];
      }
    } else {
      /*debugPrint('🔴 Hata: ${response.statusCode}');*/
      return [];
    }
  } catch (e) {
    /*debugPrint("❌ fetchComments hatası: $e");*/
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
      ).timeout(const Duration(seconds: 10)); // 10 saniye timeout

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
