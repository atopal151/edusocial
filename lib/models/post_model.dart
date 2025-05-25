import 'package:edusocial/utils/constants.dart';

class PostModel {
  final String profileImage;
  final String userName;
  final String postDate;
  final String postDescription;
  final List<String> mediaUrls;
  final int likeCount;
  final int commentCount;
  final bool isOwner;

  PostModel({
    required this.profileImage,
    required this.userName,
    required this.postDate,
    required this.postDescription,
    required this.mediaUrls,
    required this.likeCount,
    required this.isOwner,
    required this.commentCount,
  });

  // Ana sayfa ve genel kullanım
  factory PostModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final mediaList = json['media'];

    List<String> mediaUrls = [];
    if (mediaList != null && mediaList is List) {
      for (var media in mediaList) {
        final fullPath = media['full_path'];
        if (fullPath != null && fullPath is String) {
          mediaUrls.add(
            fullPath.startsWith('http')
                ? fullPath
                : "${AppConstants.baseUrl}/$fullPath",
          );
        }
      }
    }

    return PostModel(
      profileImage: user['avatar'] != null
          ? (user['avatar'].toString().startsWith('http')
              ? user['avatar']
              : "${AppConstants.baseUrl}/${user['avatar']}")
          : "${AppConstants.baseUrl}/images/static/avatar.png",
      userName: user['full_name'] ?? '',
      postDate: json['created_at'] ?? '',
      postDescription: json['content'] ?? '',
      mediaUrls: mediaUrls,
      isOwner: json['is_owner'] ?? false,
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
    );
  }
// Profil ekranına özel
  factory PostModel.fromJsonForProfile(
      Map<String, dynamic> json, String avatarUrl, String fullName) {
    final mediaList = json['media'];

    List<String> mediaUrls = [];
    if (mediaList != null && mediaList is List) {
      for (var media in mediaList) {
        final fullPath = media['full_path'];
        if (fullPath != null && fullPath is String) {
          mediaUrls.add(
            fullPath.startsWith('http')
                ? fullPath
                : "${AppConstants.baseUrl}/$fullPath",
          );
        }
      }
    }


    return PostModel(
      profileImage: avatarUrl,
      userName: fullName,
      postDate: json['human_created_at'] ?? '',
      postDescription: json['content'] ?? '',
      mediaUrls: mediaUrls,
      isOwner: json['is_owner'] == true || json['is_owner'] == 'true',
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
    );
  }
}
