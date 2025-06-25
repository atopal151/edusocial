import 'package:edusocial/models/post_model.dart';
import 'package:edusocial/models/school_department_model.dart';
import 'package:edusocial/models/school_model.dart';
import 'package:edusocial/models/user_model.dart';
import 'package:edusocial/models/entry_model.dart';

class ProfileModel {
  final int id;
  final String accountType;
  final String? languageId;
  final String avatar;
  final String banner;
  final String? description;
  final String? schoolId;
  final String? schoolDepartmentId;
  final String name;
  final String surname;
  final String? phone;
  final String username;
  final String email;
  final String? emailVerifiedAt;
  final String birthDate;
  final String? instagram;
  final String? tiktok;
  final String? twitter;
  final String? facebook;
  final String? linkedin;
  final bool notificationEmail;
  final bool notificationMobile;
  final bool isActive;
  final bool isOnline;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;
  final bool isFollowing;
  final bool isFollowingPending;
  final String avatarUrl;
  final String bannerUrl;
  final int unreadMessagesTotalCount;
  final int followingCount;
  final int followerCount;
  final bool isSelf;
  final List<PostModel> posts;
  final dynamic language;
  final List<dynamic> approvedGroups;
  final SchoolModel? school;
  final SchoolDepartmentModel? schoolDepartment;
  final List<String> lessons;
  final List<dynamic> followings;
  final List<dynamic> followers;
  final List<dynamic> approvedFollowings;
  final List<dynamic> approvedFollowers;
  final List<dynamic> stories;
  final List<dynamic> followingStories;
  final List<EntryModel> entries;

  ProfileModel({
    required this.id,
    required this.accountType,
    required this.languageId,
    required this.avatar,
    required this.banner,
    required this.description,
    required this.schoolId,
    required this.schoolDepartmentId,
    required this.name,
    required this.surname,
    required this.phone,
    required this.username,
    required this.email,
    required this.emailVerifiedAt,
    required this.birthDate,
    required this.instagram,
    required this.tiktok,
    required this.twitter,
    required this.facebook,
    required this.linkedin,
    required this.notificationEmail,
    required this.notificationMobile,
    required this.isActive,
    required this.isOnline,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.isFollowing,
    required this.isFollowingPending,
    required this.avatarUrl,
    required this.bannerUrl,
    required this.unreadMessagesTotalCount,
    required this.followingCount,
    required this.followerCount,
    required this.isSelf,
    required this.posts,
    required this.language,
    required this.approvedGroups,
    required this.school,
    required this.schoolDepartment,
    required this.lessons,
    required this.followings,
    required this.followers,
    required this.approvedFollowings,
    required this.approvedFollowers,
    required this.stories,
    required this.followingStories,
    required this.entries,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
  return ProfileModel(
    id: json['id'],
    accountType: json['account_type'] ?? 'private',
    languageId: json['language_id']?.toString(),
    avatar: json['avatar'] ?? '',
    banner: json['banner'] ?? '',
    description: json['description'],
    schoolId: json['school_id']?.toString(),
    schoolDepartmentId: json['school_department_id']?.toString(),
    name: json['name'] ?? '',
    surname: json['surname'] ?? '',
    phone: json['phone'],
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    emailVerifiedAt: json['email_verified_at'],
    birthDate: json['birthday']?.toString() ?? '',
    instagram: json['instagram'],
    tiktok: json['tiktok'],
    twitter: json['twitter'],
    facebook: json['facebook'],
    linkedin: json['linkedin'],
    notificationEmail: json['notification_email'] ?? true,
    notificationMobile: json['notification_mobile'] ?? true,
    isActive: json['is_active'] ?? true,
    isOnline: json['is_online'] ?? true,
    deletedAt: json['deleted_at'],
    createdAt: json['created_at'] ?? '',
    updatedAt: json['updated_at'] ?? '',
    isFollowing: json['is_following'] ?? false,
    isFollowingPending: json['is_following_pending'] ?? false,
    avatarUrl: json['avatar_url'] ?? '',
    bannerUrl: json['banner_url'] ?? '',
    unreadMessagesTotalCount: json['unread_messages_total_count'] ?? 0,
    followingCount: json['following_count'] ?? 0,
    followerCount: json['follower_count'] ?? 0,
    isSelf: json['is_self'] ?? false,
    posts: (json['posts'] as List?)
            ?.map((e) => PostModel.fromJsonForProfile(
                  e,
                  json['avatar_url'] ?? '',
                  "${json['name']} ${json['surname']}",
                ))
            .toList() ??
        [],
    language: json['language']?['name'], // null koruması eklendi
    approvedGroups: (json['approved_groups'] as List<dynamic>?) ?? [],
    school: json['school'] != null && json['school'] is Map<String, dynamic>
        ? SchoolModel.fromJson(json['school'])
        : null,
    schoolDepartment: json['school_department'] != null &&
            json['school_department'] is Map<String, dynamic>
        ? SchoolDepartmentModel.fromJson(json['school_department'])
        : null,
    lessons: (json['lessons'] as List?)
            ?.map((e) => e is Map && e.containsKey('name')
                ? e['name'].toString()
                : e.toString())
            .toList() ??
        [],
    followings: (json['followings'] as List<dynamic>?) ?? [],
    followers: (json['followers'] as List<dynamic>?) ?? [],
    approvedFollowings:
        (json['approved_followings'] as List<dynamic>?) ?? [],
    approvedFollowers:
        (json['approved_followers'] as List<dynamic>?) ?? [],
    stories: (json['stories'] as List<dynamic>?) ?? [],
    followingStories:
        (json['following_stories'] as List<dynamic>?) ?? [],
    entries: (json['entries'] as List<dynamic>?)
            ?.map((e) => EntryModel.fromJson(e))
            .toList() ??
        [],
  );
}

  // ProfileModel'den UserModel'e dönüşüm
  UserModel toUserModel() {
    return UserModel(
      id: id,
      accountType: accountType,
      languageId: languageId != null ? int.tryParse(languageId!) ?? 0 : 0,
      avatar: avatar,
      banner: banner,
      description: description,
      schoolId: schoolId != null ? int.tryParse(schoolId!) ?? 0 : 0,
      schoolDepartmentId: schoolDepartmentId != null ? int.tryParse(schoolDepartmentId!) ?? 0 : 0,
      name: name,
      surname: surname,
      username: username,
      email: email,
      phone: phone,
      birthday: birthDate.isNotEmpty ? DateTime.tryParse(birthDate) : null,
      instagram: instagram,
      tiktok: tiktok,
      twitter: twitter,
      facebook: facebook,
      linkedin: linkedin,
      notificationEmail: notificationEmail,
      notificationMobile: notificationMobile,
      isActive: isActive,
      isOnline: isOnline,
      avatarUrl: avatarUrl,
      bannerUrl: bannerUrl,
      isFollowing: isFollowing,
      isFollowingPending: isFollowingPending,
      isSelf: isSelf,
    );
  }
}
