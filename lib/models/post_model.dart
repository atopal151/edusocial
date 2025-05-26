import 'package:edusocial/utils/constants.dart';

class PostModel {
  final int id;
  final String slug;
  final String status;
  final String profileImage;
  final String userName;
  final String username; // @kullaniciadi gibi göstermek için
  final String postDate;
  final String postDescription;
  final List<String> mediaUrls;
  final int likeCount;
  final int commentCount;
  final bool isOwner;
  final bool isLiked;

  PostModel({
    required this.id,
    required this.slug,
    required this.status,
    required this.profileImage,
    required this.userName,
    required this.username,
    required this.postDate,
    required this.postDescription,
    required this.mediaUrls,
    required this.likeCount,
    required this.commentCount,
    required this.isOwner,
    required this.isLiked,
  });

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
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      status: json['status'] ?? '',
      profileImage: user['avatar'] != null
          ? (user['avatar'].toString().startsWith('http')
              ? user['avatar']
              : "${AppConstants.baseUrl}/${user['avatar']}")
          : "${AppConstants.baseUrl}/images/static/avatar.png",
      userName: user['full_name'] ?? '',
      username: user['username'] ?? '',
      postDate: json['created_at'] ?? '',
      postDescription: json['content'] ?? '',
      mediaUrls: mediaUrls,
      likeCount: json['likes_count'] ?? 0,
      commentCount: json['comments_count'] ?? 0,
      isOwner: json['is_owner'] ?? false,
      isLiked: json['is_liked_by_user'] ?? false,
    );
  }

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
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      status: json['status'] ?? '',
      profileImage: avatarUrl,
      userName: fullName,
      username: json['user']?['username'] ?? '',
      postDate: json['human_created_at'] ?? '',
      postDescription: json['content'] ?? '',
      mediaUrls: mediaUrls,
      likeCount: json['likes_count'] ?? 0,
      commentCount: json['comments_count'] ?? 0,
      isOwner: json['is_owner'] == true || json['is_owner'] == 'true',
      isLiked: json['is_liked_by_user'] ?? false,
    );
  }
}
