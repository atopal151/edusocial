import 'package:edusocial/models/user_model.dart';
import 'package:edusocial/models/topic_model.dart';

class EntryModel {
  final int id;
  final String content;
  final int upvotes_count;
  final int downvotes_count;
  final String human_created_at;
  final UserModel user;
  final TopicModel? topic; // topic opsiyonel olabilir

  EntryModel({
    required this.id,
    required this.content,
    required this.upvotes_count,
    required this.downvotes_count,
    required this.human_created_at,
    required this.user,
    this.topic,
  });

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final topicJson = json['topic'];

    return EntryModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      upvotes_count: json['upvotes_count'] ?? 0,
      downvotes_count: json['downvotes_count'] ?? 0,
      human_created_at: json['human_created_at'] ?? '',
      user: UserModel.fromJson(userJson ?? {}),
      topic: topicJson != null ? TopicModel.fromJson(topicJson) : null,
    );
  }

  EntryModel copyWith({
    int? id,
    String? content,
    int? upvotes_count,
    int? downvotes_count,
    String? human_created_at,
    UserModel? user,
    TopicModel? topic,
  }) {
    return EntryModel(
      id: id ?? this.id,
      content: content ?? this.content,
      upvotes_count: upvotes_count ?? this.upvotes_count,
      downvotes_count: downvotes_count ?? this.downvotes_count,
      human_created_at: human_created_at ?? this.human_created_at,
      user: user ?? this.user,
      topic: topic ?? this.topic,
    );
  }
}
