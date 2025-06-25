import 'package:get/get.dart';

class StoryModel {
  final String id;
  final int userId;
   String username;
   String profileImage;
  RxBool isViewed;
  List<String> storyUrls;
  DateTime createdat;
  bool hasStory;

  StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.profileImage,
    required bool isViewed,
    required this.storyUrls,
    required this.createdat,
    required this.hasStory,
  }) : isViewed = isViewed.obs;

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final user = json["user"] ?? {};
    final stories = json["stories"] ?? [];

    return StoryModel(
      id: user["id"].toString(),
      userId: user["id"],
      username: user["name"] ?? "",
      profileImage: user["avatar"] ?? "",
      hasStory: stories.isNotEmpty,
      isViewed: (user["is_showed"] ?? false) == true,
      storyUrls: stories
          .where((e) => e["path"] != null && e["path"].toString().isNotEmpty)
          .map<String>((e) => e["path"].toString())
          .toList(),
      createdat: stories.isNotEmpty && stories[0]["created_at"] != null
          ? DateTime.tryParse(stories[0]["created_at"]) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
