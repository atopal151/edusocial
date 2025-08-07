import 'package:edusocial/utils/constants.dart';
import 'package:flutter/foundation.dart';

class PostModel {
  final int id;
  final String slug;
  final String status;
  final String profileImage;
  final String name;
  final String username; // @kullaniciadi gibi göstermek için
  final String postDate;
  final String postDescription;
  final List<String> mediaUrls;
  final int likeCount;
  final int commentCount;
  final bool isOwner;
  final bool isLiked;
  final List<String> links;

  PostModel({
    required this.id,
    required this.slug,
    required this.status,
    required this.profileImage,
    required this.name,
    required this.username,
    required this.postDate,
    required this.postDescription,
    required this.mediaUrls,
    required this.likeCount,
    required this.commentCount,
    required this.isOwner,
    required this.isLiked,
    required this.links,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    debugPrint("🔍 PostModel.fromJson çağrıldı");
    debugPrint("🔍 JSON: ${json.toString()}");
    
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

    final postModel = PostModel(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      status: json['status'] ?? '',
      profileImage: user['avatar'] != null
          ? (user['avatar'].toString().startsWith('http')
              ? user['avatar']
              : "${AppConstants.baseUrl}/${user['avatar']}")
          : "${AppConstants.baseUrl}/images/static/avatar.png",
      name: user['full_name'] ?? '',
      username: user['username'] ?? '',
      postDate: json['created_at'] ?? '',
      postDescription: json['content'] ?? '',
      mediaUrls: mediaUrls,
      likeCount: json['likes_count'] ?? 0,
      commentCount: json['comments_count'] ?? 0,
      isOwner: json['is_owner'] ?? false,
      isLiked: json['is_liked_by_user'] ?? false,  links: (json['links'] as List?)
              ?.map((e) => e['link']?.toString() ?? '')
              .toList() ??
          [],
    );
    
    debugPrint("✅ PostModel oluşturuldu: ID=${postModel.id}, Username=${postModel.username}, isOwner=${postModel.isOwner}, Content=${postModel.postDescription}");
    return postModel;
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
    profileImage: avatarUrl,  // dışarıdan parametre ile geliyor
    name: fullName,       // dışarıdan parametre ile geliyor
    username: json['username'] ?? '', // JSON’da yoksa boş kalsın
    postDate: json['created_at'] ?? '',
    postDescription: json['content'] ?? '',
    mediaUrls: mediaUrls,
    likeCount: json['like_count'] ?? 0,      // 🔥 Düzeltildi
    commentCount: json['comment_count'] ?? 0, // 🔥 Düzeltildi
    isOwner: json['is_owner'] == true || json['is_owner'] == 'true',
    isLiked: json['is_liked_by_user'] ?? false,  links: (json['links'] as List?)
              ?.map((e) => e['link']?.toString() ?? '')
              .toList() ??
          [],
  );
}

}
