import 'package:edusocial/utils/constants.dart';

class PostModel {
  final String profileImage;
  final String userName;
  final String postDate;
  final String postDescription;
  final String? postImage; // Gönderi fotoğrafı opsiyonel
  final int likeCount;
  final int commentCount;

  PostModel({
    required this.profileImage,
    required this.userName,
    required this.postDate,
    required this.postDescription,
    this.postImage,
    required this.likeCount,
    required this.commentCount,
  });

  // JSON'dan Model'e dönüştürme fonksiyonu
  factory PostModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return PostModel(
      profileImage: "${AppConstants.baseUrl}/${user['avatar'] ?? ''}",
      userName: "${user['name'] ?? ''} ${user['surname'] ?? ''}",
      postDate: json['created_at'] ?? '',
      postDescription: json['content'] ?? '',
      postImage: json['image'], // varsa image
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
    );
  }
}
