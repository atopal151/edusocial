import 'package:edusocial/models/group_models/grup_suggestion_model.dart';
import 'package:edusocial/models/post_model.dart';
import 'package:edusocial/models/school_department_model.dart';
import 'package:edusocial/models/school_model.dart';
import 'package:edusocial/models/entry_model.dart';

class PeopleProfileModel {
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
  final List<EntryModel> entries;
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
  
  // Hesap doğrulama alanları
  final bool? isVerified;
  final bool? verified;
  final String? verificationStatus;
  final bool? accountVerified;
  final bool? emailVerified;
  final bool? phoneVerified;
  final bool? documentVerified;
  final bool? identityVerified;
  final String? verificationLevel;
  final String? verificationType;

  PeopleProfileModel({
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
    required this.entries,
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
    this.isVerified,
    this.verified,
    this.verificationStatus,
    this.accountVerified,
    this.emailVerified,
    this.phoneVerified,
    this.documentVerified,
    this.identityVerified,
    this.verificationLevel,
    this.verificationType,
  });

  factory PeopleProfileModel.fromJson(Map<String, dynamic> json) {
    return PeopleProfileModel(
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
      posts: (json['posts'] as List?)?.map((e) {
            return PostModel.fromJsonForProfile(
              e,
              json['avatar'] ?? '',
              "${json['name']} ${json['surname']}",
              json['username'] ?? '', // Ana kullanıcının username'ini geç
            );
          }).toList() ??
          [],
      entries: (json['entries'] as List?)?.map((e) => EntryModel.fromJson(e)).toList() ?? [],
      language: json['language']?['name'],
      approvedGroups: json['groups'] != null
        ? List<GroupSuggestionModel>.from(
            json['groups'].map((x) => GroupSuggestionModel.fromJson(x)))
        : [],
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
      followings: json['followings'] ?? [],
      followers: json['followers'] ?? [],
      approvedFollowings: json['approved_followings'] ?? [],
      approvedFollowers: json['approved_followers'] ?? [],
      stories: json['stories'] ?? [],
      followingStories: json['following_stories'] ?? [],
      // Hesap doğrulama alanları
      isVerified: json['is_verified'],
      verified: json['verified'],
      verificationStatus: json['verification_status'],
      accountVerified: json['account_verified'],
      emailVerified: json['email_verified'],
      phoneVerified: json['phone_verified'],
      documentVerified: json['document_verified'],
      identityVerified: json['identity_verified'],
      verificationLevel: json['verification_level'],
      verificationType: json['verification_type'],
    );
  }

}
