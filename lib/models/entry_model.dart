import 'package:edusocial/models/user_model.dart';
import 'package:edusocial/models/topic_model.dart';

class EntryModel {
  final int id;
  final String content;
  final int upvotescount;
  final int downvotescount;
  final String humancreatedat;
  final DateTime? createdat; // Tarih sıralaması için
  final UserModel user;
  final TopicModel? topic; // topic opsiyonel olabilir
  final bool? islike; // Added for vote status
  final bool? isdislike; // Added for vote status

  EntryModel({
    required this.id,
    required this.content,
    required this.upvotescount,
    required this.downvotescount,
    required this.humancreatedat,
    this.createdat,
    required this.user,
    this.topic,
    this.islike,
    this.isdislike,
  });

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final topicJson = json['topic'];

    // Eğer user field'ı yoksa, boş bir UserModel oluştur
    UserModel user;
    if (userJson != null) {
      user = UserModel.fromJson(userJson);
    } else {
      // API'den user field'ı gelmiyorsa, temel bilgilerle oluştur
      user = UserModel(
        id: json['user_id'] ?? 0,
        accountType: 'public',
        languageId: 1,
        avatar: '',
        banner: '',
        schoolId: 1,
        schoolDepartmentId: 1,
        name: '',
        surname: '',
        username: '',
        email: '',
        notificationEmail: true,
        notificationMobile: true,
        isActive: true,
        isOnline: false,
        avatarUrl: '',
        bannerUrl: '',
        isFollowing: false,
        isFollowingPending: false,
        isSelf: false,
      );
    }

    return EntryModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      upvotescount: json['upvote_count'] ?? 0,
      downvotescount: json['downvote_count'] ?? 0,
      humancreatedat: json['human_created_at'] ?? '',
      createdat: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      user: user,
      topic: topicJson != null ? TopicModel.fromJson(topicJson) : null,
      islike: json['is_like'],
      isdislike: json['is_dislike'],
    );
  }

  EntryModel copyWith({
    int? id,
    String? content,
    int? upvotescount,
    int? downvotescount,
    String? humancreatedat,
    DateTime? createdat,
    UserModel? user,
    TopicModel? topic,
    bool? islike,
    bool? isdislike,
  }) {
    return EntryModel(
      id: id ?? this.id,
      content: content ?? this.content,
      upvotescount: upvotescount ?? this.upvotescount,
      downvotescount: downvotescount ?? this.downvotescount,
      humancreatedat: humancreatedat ?? this.humancreatedat,
      createdat: createdat ?? this.createdat,
      user: user ?? this.user,
      topic: topic ?? this.topic,
      islike: islike ?? this.islike,
      isdislike: isdislike ?? this.isdislike,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'upvotes_count': upvotescount,
      'downvotes_count': downvotescount,
      'human_created_at': humancreatedat,
      'created_at': createdat?.toIso8601String(),
      'user': user.toJson(),
      'topic': topic?.toJson(),
      'is_like': islike,
      'is_dislike': isdislike,
    };
  }
}
