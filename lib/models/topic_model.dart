

// 📦 topic_model.dart
import 'topic_category_model.dart';

class TopicModel {
  final int id;
  final int userId;
  final int topicCategoryId;
  final String name;
  final String slug;
  final String status;
  final String createdAt;
  final String updatedAt;
  final int entryCount;
  final int entryCountLast24;
  final String badgeType;
  final TopicCategoryModel category;

  TopicModel({
    required this.id,
    required this.userId,
    required this.topicCategoryId,
    required this.name,
    required this.slug,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.entryCount,
    required this.entryCountLast24,
    required this.badgeType,
    required this.category,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'],
      userId: json['user_id'],
      topicCategoryId: json['topic_category_id'],
      name: json['name'],
      slug: json['slug'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      entryCount: json['entry_count'],
      entryCountLast24: json['entry_count_last_24'],
      badgeType: json['badge_type'],
      category: TopicCategoryModel.fromJson(json['category']),
    );
  }
}