import 'package:edusocial/models/entry_model.dart';
import 'package:edusocial/models/topic_model.dart';

// 📦 topic_category_model.dart
class TopicCategoryModel {
  final int id;
  final String title;
  final String slug;
  final String description;
  final int topicCount;
  final int entryCount;
  final List<TopicModel>? topics;
  final EntryModel? firstentry;

  TopicCategoryModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.topicCount,
    required this.entryCount,
    this.topics,
    this.firstentry,
  });

  factory TopicCategoryModel.fromJson(Map<String, dynamic> json) {
    return TopicCategoryModel(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      description: json['description'],
      topicCount: json['topic_count'],
      entryCount: json['entry_count'],
      topics: json['topics'] != null
          ? (json['topics'] as List)
              .map((i) => TopicModel.fromJson(i))
              .toList()
          : null,
      firstentry: json['first_entry'] != null
          ? EntryModel.fromJson(json['first_entry'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'topic_count': topicCount,
      'entry_count': entryCount,
      'topics': topics?.map((e) => e.toJson()).toList(),
      'first_entry': firstentry?.toJson(),
    };
  }
}