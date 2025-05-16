import 'package:edusocial/models/group_models/grup_suggestion_model.dart';
import 'package:edusocial/models/post_model.dart';

class ProfileModel {
  final String name;
  final String surname;
  final String username;
  final String email;
  final String phone;
  final String avatar;
  final String coverPhoto;
  final String bio;
  final String instagram;
  final String twitter;
  final String facebook;
  final String linkedin;
  final String accountType;
  final bool notificationEmail;
  final bool notificationMobile;
  final String schoolId;
  final String schoolDepartmentId;

  final int followers;
  final int following;
  final int postCount;

  final String schoolName;
  final String schoolLogo;
  final String schoolDepartment;
  final String schoolGrade;
  final String birthDate;

  final List<String> courses;
  final List<GroupSuggestionModel> joinedGroups;
  final List<PostModel> posts;

  ProfileModel({
    required this.name,
    required this.surname,
    required this.username,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.coverPhoto,
    required this.bio,
    required this.instagram,
    required this.twitter,
    required this.facebook,
    required this.linkedin,
    required this.accountType,
    required this.notificationEmail,
    required this.notificationMobile,
    required this.schoolId,
    required this.schoolDepartmentId,
    required this.followers,
    required this.following,
    required this.postCount,
    required this.schoolName,
    required this.schoolLogo,
    required this.schoolDepartment,
    required this.schoolGrade,
    required this.birthDate,
    required this.courses,
    required this.joinedGroups,
    required this.posts,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar_url'] ?? '',
      coverPhoto: json['cover_photo'] ?? '',
      bio: json['bio'] ?? '',
      instagram: json['instagram'] ?? '',
      twitter: json['twitter'] ?? '',
      facebook: json['facebook'] ?? '',
      linkedin: json['linkedin'] ?? '',
      accountType: json['account_type'] ?? 'private',
      notificationEmail: json['notification_email'] ?? true,
      notificationMobile: json['notification_mobile'] ?? true,
      schoolId: json['school_id']?.toString() ?? '',
      schoolDepartmentId: json['school_department_id']?.toString() ?? '',
      followers: (json['followers'] is List)
          ? json['followers'].length
          : (json['followers'] is int ? json['followers'] : 0),
      following: (json['followings'] is List)
          ? json['followings'].length
          : (json['followings'] is int ? json['followings'] : 0),
      postCount: (json['posts'] is List) ? json['posts'].length : 0,
      schoolName: json['school']?['name'] ?? '',
      schoolLogo: json['school']?['logo'] ?? '',
      schoolDepartment: json['school_department']?['name'] ?? '',
      schoolGrade: json['school_grade'] ?? '',
      birthDate: json['birthday'] ?? '',
      courses: (json['lessons'] as List?)
              ?.map((e) => e['name'].toString())
              .toList() ??
          [],
      joinedGroups: (json['approved_groups'] as List?)
              ?.map((group) => GroupSuggestionModel.fromJson(group))
              .toList() ??
          [],
      posts: (json['posts'] as List?)
              ?.map((e) => PostModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
