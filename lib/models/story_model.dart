class StoryModel {
  final String id;
  final String userId;
  final String username;
  final String profileImage;
  final bool isMyStory;
  final bool hasStory;
  final List<String> storyUrls;
  final DateTime createdAt;

  final bool isViewed;

  StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.profileImage,
    required this.isMyStory,
    required this.hasStory,
    required this.storyUrls,
    this.isViewed = false,
    required this.createdAt,
  });
}
