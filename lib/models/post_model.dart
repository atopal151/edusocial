import 'package:edusocial/utils/constants.dart';

class PostModel {
  final String profileImage;        // Kullanıcının avatar URL'si
  final String userName;            // Kullanıcının adı
  final String postDate;            // Oluşturulma zamanı
  final String postDescription;     // Gönderi metni
  final String? postImage;          // İlk medya dosyası varsa
  final int likeCount;              // Beğeni sayısı
  final int commentCount;           // Yorum sayısı

  PostModel({
    required this.profileImage,
    required this.userName,
    required this.postDate,
    required this.postDescription,
    this.postImage,
    required this.likeCount,
    required this.commentCount,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final mediaList = json['media'];

    String? imageUrl;
    if (mediaList != null &&
        mediaList is List &&
        mediaList.isNotEmpty &&
        mediaList[0] is Map<String, dynamic> &&
        mediaList[0]['full_path'] is String) {
      imageUrl = mediaList[0]['full_path'];
    }

    return PostModel(
      profileImage: user['avatar'] != null
          ? (user['avatar'].toString().startsWith('http')
              ? user['avatar']
              : "${AppConstants.baseUrl}/${user['avatar']}")
          : "${AppConstants.baseUrl}/images/static/avatar.png",
      userName: user['name'] ?? '',
      postDate: json['created_at'] ?? '',
      postDescription: json['content'] ?? '',
      postImage: imageUrl,
      likeCount: json['likes_count'] ?? 0,
      commentCount: json['comments_count'] ?? 0,
    );
  }
}
