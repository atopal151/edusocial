class StoryModel {
  final String id;
  final String userId;
  final String username;
  final String profileImage;
  late final bool isMyStory;
  final bool isViewed;
  List<String> storyUrls;
  DateTime createdAt;
  bool hasStory;

  StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.profileImage,
    required this.isMyStory,
    required this.isViewed,
    required this.storyUrls,
    required this.createdAt,
    required this.hasStory,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final stories = json["stories"] ?? [];
    return StoryModel(
      id: json["id"].toString(),
      userId: json["user_id"].toString(),
      username: json["username"] ?? "",
      profileImage: json["profile_image"] ?? "",
      isMyStory: false,
      hasStory: false,
      isViewed: false,
      storyUrls: List<String>.from(stories.map((e) => e["url"])),
      createdAt: stories.isNotEmpty
          ? DateTime.parse(stories[0]["created_at"])
          : DateTime.now(),
    );
  }
}
