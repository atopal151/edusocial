class StoryModel {
  final String username;
  final String profileImage;
  final bool isViewed;

  StoryModel({
    required this.username,
    required this.profileImage,
    this.isViewed = false,
  });
}
