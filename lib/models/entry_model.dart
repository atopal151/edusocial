import 'package:edusocial/models/user_model.dart';
import 'package:edusocial/models/topic_model.dart';

class EntryModel {
  final int id;
  final String content;
  final int upvoteCount;
  final int downvoteCount;
  final String createdAt;
  final UserModel user;
  final TopicModel? topic; // topic opsiyonel olabilir

  EntryModel({
    required this.id,
    required this.content,
    required this.upvoteCount,
    required this.downvoteCount,
    required this.createdAt,
    required this.user,
    this.topic,
  });

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final topicJson = json['topic'];

    return EntryModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      upvoteCount: json['upvote_count'] ?? json['upvotes_count'] ?? 0,
      downvoteCount: json['downvote_count'] ?? json['downvotes_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      user: UserModel.fromJson(userJson ?? {}),
      topic: topicJson != null ? TopicModel.fromJson(topicJson) : null,
    );
  }
}
