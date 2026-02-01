import 'package:get/get.dart';

class StoryModel {
  final String id;
  final int userId;
  String username;
  String name;
  String surname;
  String profileImage;
  RxBool isViewed;
  List<String> storyUrls;
  DateTime createdat;
  bool hasStory;

  StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.name,
    required this.surname,
    required this.profileImage,
    required bool isViewed,
    required this.storyUrls,
    required this.createdat,
    required this.hasStory,
  }) : isViewed = isViewed.obs;

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final user = json["user"] ?? {};
    final stories = json["stories"] ?? [];

    // API name/surname/username alanları opsiyonel; boşsa name'e düş
    final rawName = (user["name"] ?? "").toString();
    final rawSurname = (user["surname"] ?? "").toString();
    final rawUsername = (user["username"] ?? "").toString();

    final resolvedUsername =
        rawUsername.isNotEmpty ? rawUsername : rawName; // username yoksa ad kullan
    final resolvedName = rawName;
    final resolvedSurname = rawSurname;

    return StoryModel(
      id: user["id"].toString(),
      userId: user["id"],
      username: resolvedUsername,
      name: resolvedName,
      surname: resolvedSurname,
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

  /// Log ve debug için modelin JSON karşılığı
  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "username": username,
        "name": name,
        "surname": surname,
        "profileImage": profileImage,
        "isViewed": isViewed.value,
        "storyUrls": storyUrls,
        "createdat": createdat.toIso8601String(),
        "hasStory": hasStory,
      };
}
