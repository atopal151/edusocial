class StoryModel {
  final String id;
  final String userId;
  final String username;
  final String profileImage;
  final bool isMyStory;

  final bool isViewed;

    /// Değiştirilebilir alanlar
  List<String> storyUrls;
  bool hasStory;
  DateTime createdAt;

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
