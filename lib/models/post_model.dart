import 'package:edusocial/utils/constants.dart';

class PostModel {
  final int id;
  final String slug;
  final String status;
  final String profileImage;
  final String name;
  final String surname;
  final String username; // @kullaniciadi gibi göstermek için
  final String postDate;
  final String postDescription;
  final List<String> mediaUrls;
  final int likeCount;
  final int commentCount;
  final bool isOwner;
  final bool isLiked;
  final List<String> links;
  final bool? isVerified; // Hesap doğrulama durumu

  PostModel({
    required this.id,
    required this.slug,
    required this.status,
    required this.profileImage,
    required this.name,
    required this.surname,
    required this.username,
    required this.postDate,
    required this.postDescription,
    required this.mediaUrls,
    required this.likeCount,
    required this.commentCount,
    required this.isOwner,
    required this.isLiked,
    required this.links,
    this.isVerified,
  });

  static String _getProfileImageUrl(Map<String, dynamic> user) {
    // Önce avatar_url'i kontrol et
    if (user['avatar_url'] != null && user['avatar_url'].toString().isNotEmpty) {
      final avatarUrl = user['avatar_url'].toString();
      if (avatarUrl.startsWith('http')) {
        return avatarUrl;
      }
      // Relative path ise storage ile birleştir
      if (avatarUrl.startsWith('/storage/') || avatarUrl.startsWith('storage/')) {
        return "https://stageapi.edusocial.pl/${avatarUrl.replaceFirst('/', '')}";
      }
      if (avatarUrl.startsWith('/')) {
        return "https://stageapi.edusocial.pl$avatarUrl";
      }
      return "https://stageapi.edusocial.pl/storage/$avatarUrl";
    }
    
    // avatar_url yoksa avatar'ı kontrol et
    if (user['avatar'] != null && user['avatar'].toString().isNotEmpty) {
      final avatar = user['avatar'].toString();
      if (avatar.startsWith('http')) {
        return avatar;
      }
      // Relative path ise storage ile birleştir
      if (avatar.startsWith('/storage/') || avatar.startsWith('storage/')) {
        return "https://stageapi.edusocial.pl/${avatar.replaceFirst('/', '')}";
      }
      if (avatar.startsWith('/')) {
        return "https://stageapi.edusocial.pl$avatar";
      }
      return "https://stageapi.edusocial.pl/storage/$avatar";
    }
    
    // Default avatar
    return "https://stageapi.edusocial.pl/images/static/avatar.png";
  }

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

    final postModel = PostModel(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      status: json['status'] ?? '',
      profileImage: _getProfileImageUrl(user),
      name: user['name'] ?? user['full_name'] ?? '',
      surname: user['surname'] ?? '', 
      username: user['username'] ?? '',
      postDate: json['created_at'] ?? '',
      postDescription: json['content'] ?? '',
      mediaUrls: mediaUrls,
      likeCount: json['like_count'] ?? json['likes_count'] ?? 0,
      commentCount: json['comment_count'] ?? json['comments_count'] ?? 0,
      isOwner: json['is_owner'] ?? false,
          isLiked: json['is_liked_by_user'] ?? false,  links: (json['links'] as List?)
              ?.map((e) => e['link']?.toString() ?? '')
              .toList() ??
          [],
    isVerified: user['is_verified'],
    );
    
    return postModel;
  }

factory PostModel.fromJsonForProfile(
    Map<String, dynamic> json, String avatarUrl, String fullName, String username) {
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

  // Username için fallback değeri oluştur
  String finalUsername = username.isNotEmpty ? username : (json['username'] ?? '');
  if (finalUsername.isEmpty && fullName.isNotEmpty) {
    // Full name'den username türet
    final nameParts = fullName.split(' ');
    if (nameParts.isNotEmpty) {
      finalUsername = nameParts.last.toLowerCase();
    }
  }

  return PostModel(
    id: json['id'] ?? 0,
    slug: json['slug'] ?? '',
    status: json['status'] ?? '',
    profileImage: avatarUrl,  // dışarıdan parametre ile geliyor
    name: fullName,       // dışarıdan parametre ile geliyor
    surname: json['surname'] ?? '',
    username: finalUsername, // Düzeltilmiş username
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
