import 'package:edusocial/utils/constants.dart';

class EntryModel {
  final String profileImage;
  final String userName;
  final String entryDate;
  final String entryTitle;
  final String entryDescription;
  final bool isActive;
  final bool isOwner; // ✅ Yeni alan
  int upvoteCount;
  int downvoteCount;

  EntryModel({
    required this.profileImage,
    required this.userName,
    required this.entryDate,
    required this.entryTitle,
    required this.entryDescription,
    required this.upvoteCount,
    required this.downvoteCount,
    required this.isActive,
    required this.isOwner, // ✅ constructor'a da ekle
  });

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return EntryModel(
      profileImage: user['avatar'] != null
          ? "${AppConstants.baseUrl}/${user['avatar']}"
          : "",
      userName: "${user['name']} ${user['surname']}",
      entryDate: json['created_at'] ?? '',
      entryTitle: json['content'] ?? '',
      entryDescription: json['content'] ?? '',
      upvoteCount: json['like_count'] ?? 0,
      downvoteCount: json['dislike_count'] ?? 0,
      isActive: json['is_active'] ?? true,
      isOwner: json['is_owner'] ?? false, // ✅ burada parse ediliyor
    );
  }
}
