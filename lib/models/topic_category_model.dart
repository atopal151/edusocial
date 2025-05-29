import 'topic_model.dart';

class TopicCategoryModel {
  final int id;
  final String name;
  final List<TopicModel> topics;

  TopicCategoryModel({
    required this.id,
    required this.name,
    required this.topics,
  });

  factory TopicCategoryModel.fromJson(Map<String, dynamic> json) {
    return TopicCategoryModel(
      id: json['id'],
      name: json['name'],
      topics: (json['topics'] as List)
          .map((e) => TopicModel.fromJson(e))
          .toList(),
    );
  }
}
