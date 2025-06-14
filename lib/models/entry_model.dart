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
  final bool? is_like; // Added for vote status
  final bool? is_dislike; // Added for vote status

  EntryModel({
    required this.id,
    required this.content,
    required this.upvotes_count,
    required this.downvotes_count,
    required this.human_created_at,
    required this.user,
    this.topic,
    this.is_like,
    this.is_dislike,
  });

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final topicJson = json['topic'];

    return EntryModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      upvotes_count: json['upvote_count'] ?? 0,
      downvotes_count: json['downvote_count'] ?? 0,
      human_created_at: json['human_created_at'] ?? '',
      user: UserModel.fromJson(userJson ?? {}),
      topic: topicJson != null ? TopicModel.fromJson(topicJson) : null,
      is_like: json['is_like'],
      is_dislike: json['is_dislike'],
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
    bool? is_like,
    bool? is_dislike,
  }) {
    return EntryModel(
      id: id ?? this.id,
      content: content ?? this.content,
      upvotes_count: upvotes_count ?? this.upvotes_count,
      downvotes_count: downvotes_count ?? this.downvotes_count,
      human_created_at: human_created_at ?? this.human_created_at,
      user: user ?? this.user,
      topic: topic ?? this.topic,
      is_like: is_like ?? this.is_like,
      is_dislike: is_dislike ?? this.is_dislike,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'upvotes_count': upvotes_count,
      'downvotes_count': downvotes_count,
      'human_created_at': human_created_at,
      'user': user.toJson(),
      'topic': topic?.toJson(),
      'is_like': is_like,
      'is_dislike': is_dislike,
    };
  }
}
