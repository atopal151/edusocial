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
  final String topicTitle; // 🆕 Eklenen alan

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
    required this.topicTitle, // 🆕 Eklenen alan
  });

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final topic = json['topic'] ?? {};
    return EntryModel(
      profileImage: user['avatar_url'] ?? '',
      userName: "${user['name'] ?? ''} ${user['surname'] ?? ''}".trim(),
      entryDate: json['created_at'] ?? '',
      entryTitle: json['title'] ?? json['content'] ?? '',
      entryDescription: json['description'] ?? '',
      upvoteCount: json['upvote_count'] ?? json['like_count'] ?? 0,
      downvoteCount: json['downvote_count'] ?? json['dislike_count'] ?? 0,
      isOwner: json['is_owner'] ?? false,
      topicCategoryId: json['topic_category_id'] ?? 0,
      topicId: json['topic_id'] ?? 0,
      topicTitle: topic['name'] ?? '', // 🆕 nested erişim
    );
  }
}
