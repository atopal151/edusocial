class TopicModel {
  final int id;
  final String name;
  final int topicCategoryId;
  final String status;
  final String badgeType;
  final int entryCount;
  final String createdAt;

  TopicModel({
    required this.id,
    required this.name,
    required this.topicCategoryId,
    required this.status,
    required this.badgeType,
    required this.entryCount,
    required this.createdAt,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json["id"],
      name: json["name"] ?? "",
      topicCategoryId: json["topic_category_id"] ?? 0,
      status: json["status"] ?? "",
      badgeType: json["badge_type"] ?? "",
      entryCount: json["entry_count"] ?? 0,
      createdAt: json["created_at"] ?? "",
    );
  }
}
