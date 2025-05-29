class TopicModel {
  final int id;
  final String name;
  final int topicCategoryId;

  TopicModel({
    required this.id,
    required this.name,
    required this.topicCategoryId,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'],
      name: json['name'],
      topicCategoryId: json['topic_category_id'],
    );
  }
}
