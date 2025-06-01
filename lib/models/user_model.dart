// 📦 entry_user_model.dart
class UserModel {
  final int id;
  final String accountType;
  final int languageId;
  final String avatar;
  final String banner;
  final String? description;
  final int schoolId;
  final int schoolDepartmentId;
  final String name;
  final String surname;
  final String username;
  final String email;
  final String? phone;
  final DateTime? birthday;
  final String? instagram;
  final String? tiktok;
  final String? twitter;
  final String? facebook;
  final String? linkedin;
  final bool notificationEmail;
  final bool notificationMobile;
  final bool isActive;
  final bool isOnline;
  final String avatarUrl;
  final String bannerUrl;
  final bool isFollowing;
  final bool isFollowingPending;
  final bool isSelf;

  UserModel({
    required this.id,
    required this.accountType,
    required this.languageId,
    required this.avatar,
    required this.banner,
    this.description,
    required this.schoolId,
    required this.schoolDepartmentId,
    required this.name,
    required this.surname,
    required this.username,
    required this.email,
    this.phone,
    this.birthday,
    this.instagram,
    this.tiktok,
    this.twitter,
    this.facebook,
    this.linkedin,
    required this.notificationEmail,
    required this.notificationMobile,
    required this.isActive,
    required this.isOnline,
    required this.avatarUrl,
    required this.bannerUrl,
    required this.isFollowing,
    required this.isFollowingPending,
    required this.isSelf,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      accountType: json['account_type'] ?? '',
      languageId: json['language_id'],
      avatar: json['avatar'] ?? '',
      banner: json['banner'] ?? '',
      description: json['description'],
      schoolId: json['school_id'],
      schoolDepartmentId: json['school_department_id'],
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      birthday: json['birthday'] != null ? DateTime.tryParse(json['birthday']) : null,
      instagram: json['instagram'],
      tiktok: json['tiktok'],
      twitter: json['twitter'],
      facebook: json['facebook'],
      linkedin: json['linkedin'],
      notificationEmail: json['notification_email'],
      notificationMobile: json['notification_mobile'],
      isActive: json['is_active'],
      isOnline: json['is_online'],
      avatarUrl: json['avatar_url'] ?? '',
      bannerUrl: json['banner_url'] ?? '',
      isFollowing: json['is_following'],
      isFollowingPending: json['is_following_pending'],
      isSelf: json['is_self'],
    );
  }
}