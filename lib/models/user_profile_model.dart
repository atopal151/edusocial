class UserProfile {
  String profileImage;
  String username;
  String name;
  String surname;
  String email;
  String phone;
  String birthday;
  String instagram;
  String twitter;
  String facebook;
  String linkedin;
  bool demoNotification;
  bool emailNotification;
  bool mobileNotification;
  String accountType;
  String schoolId;
  String departmentId;
  List<String> lessons;

  UserProfile({
    required this.profileImage,
    required this.username,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.birthday,
    required this.instagram,
    required this.twitter,
    required this.facebook,
    required this.linkedin,
    required this.demoNotification,
    required this.emailNotification,
    required this.mobileNotification,
    required this.accountType,
    required this.schoolId,
    required this.departmentId,
    required this.lessons,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      profileImage: json['avatar'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      birthday: json['birthday'] ?? '',
      instagram: json['instagram'] ?? '',
      twitter: json['twitter'] ?? '',
      facebook: json['facebook'] ?? '',
      linkedin: json['linkedin'] ?? '',
      demoNotification: false,
      emailNotification: json['notification_email'] == 1,
      mobileNotification: json['notification_mobile'] == 1,
      accountType: json['account_type'] ?? 'private',
      schoolId: json['school_id']?.toString() ?? '',
      departmentId: json['school_department_id']?.toString() ?? '',
      lessons: List<String>.from(json['lessons'] ?? []),
    );
  }

  static UserProfile empty() {
    return UserProfile(
      profileImage: '',
      username: '',
      name: '',
      surname: '',
      email: '',
      phone: '',
      birthday: '',
      instagram: '',
      twitter: '',
      facebook: '',
      linkedin: '',
      demoNotification: false,
      emailNotification: true,
      mobileNotification: true,
      accountType: 'private',
      schoolId: '',
      departmentId: '',
      lessons: [],
    );
  }
}
