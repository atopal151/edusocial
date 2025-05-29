import 'package:edusocial/utils/constants.dart';

class EntryModel {
  final String profileImage;
  final String userName;
  final String entryDate;
  final String entryTitle;
  final String entryDescription;
  final bool isOwner;
  int upvoteCount;
  int downvoteCount;
  final int topicCategoryId;
  final int topicId;

  EntryModel({
    required this.profileImage,
    required this.userName,
    required this.entryDate,
    required this.entryTitle,
    required this.entryDescription,
    required this.upvoteCount,
    required this.downvoteCount,
    required this.isOwner,
    required this.topicCategoryId,
    required this.topicId,
  });

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};

    return EntryModel(
      profileImage: user['avatar'] != null
          ? "${AppConstants.baseUrl}/${user['avatar']}"
          : "",
      userName: "${user['name'] ?? ''} ${user['surname'] ?? ''}".trim(),
      entryDate: json['human_created_at'] ?? json['created_at'] ?? '',
      entryTitle: json['content'] ?? '',
      entryDescription: json['content'] ?? '',
      upvoteCount: json['upvote_count'] ?? json['like_count'] ?? 0,
      downvoteCount: json['downvote_count'] ?? json['dislike_count'] ?? 0,
      isOwner: json['is_owner'] ?? false,
      topicCategoryId: json['topic_category_id'] ?? 0,
      topicId: json['topic_id'] ?? 0,
    );
  }
}
