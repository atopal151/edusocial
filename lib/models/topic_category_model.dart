
// 📦 topic_category_model.dart
class TopicCategoryModel {
  final int id;
  final String title;
  final String slug;
  final String description;
  final int topicCount;
  final int entryCount;

  TopicCategoryModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.topicCount,
    required this.entryCount,
  });

  factory TopicCategoryModel.fromJson(Map<String, dynamic> json) {
    return TopicCategoryModel(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      description: json['description'],
      topicCount: json['topic_count'],
      entryCount: json['entry_count'],
    );
  }
}