// 📦 topic_model.dart
import 'topic_category_model.dart';
import 'entry_model.dart';
import 'user_model.dart';
import 'package:flutter/foundation.dart';

class TopicModel {
  final int id;
  final int userId;
  final int topicCategoryId;
  final String name;
  final String slug;
  final String status;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int entryCount;
  final int entryCountLast24;
  final String badgeType;
  final TopicCategoryModel? category;
  final EntryModel? last_entry;
  final UserModel? user;

  TopicModel({
    required this.id,
    required this.userId,
    required this.topicCategoryId,
    required this.name,
    required this.slug,
    required this.status,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.entryCount,
    required this.entryCountLast24,
    required this.badgeType,
    this.category,
    this.last_entry,
    this.user,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    // debugPrint('📦 Topic JSON: $json');
    // debugPrint('📦 Last Entry JSON: ${json['last_entry']}');
    
    return TopicModel(
      id: json['id'],
      userId: json['user_id'],
      topicCategoryId: json['topic_category_id'],
      name: json['name'],
      slug: json['slug'],
      status: json['status'],
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      entryCount: json['entry_count'] ?? 0,
      entryCountLast24: json['entry_count_last_24'] ?? 0,
      badgeType: json['badge_type'] ?? 'black',
      category: json['category'] != null
          ? TopicCategoryModel.fromJson(json['category'])
          : null,
      last_entry: json['last_entry'] != null
          ? EntryModel.fromJson(json['last_entry'])
          : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'topic_category_id': topicCategoryId,
      'name': name,
      'slug': slug,
      'status': status,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'entry_count': entryCount,
      'entry_count_last_24': entryCountLast24,
      'badge_type': badgeType,
      'last_entry': last_entry?.toJson(),
      'user': user?.toJson(),
    };
  }

  TopicModel copyWith({
    int? id,
    int? userId,
    int? topicCategoryId,
    String? name,
    String? slug,
    String? status,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? entryCount,
    int? entryCountLast24,
    String? badgeType,
    EntryModel? last_entry,
    UserModel? user,
    TopicCategoryModel? category,
  }) {
    return TopicModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      topicCategoryId: topicCategoryId ?? this.topicCategoryId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      status: status ?? this.status,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      entryCount: entryCount ?? this.entryCount,
      entryCountLast24: entryCountLast24 ?? this.entryCountLast24,
      badgeType: badgeType ?? this.badgeType,
      last_entry: last_entry ?? this.last_entry,
      user: user ?? this.user,
      category: category ?? this.category,
    );
  }
}