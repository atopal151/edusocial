
class UserProfile {
  String profileImage;
  String username;
  String instagram;
  String youtube;
  bool demoNotification;

  UserProfile({
    required this.profileImage,
    required this.username,
    required this.instagram,
    required this.youtube,
    required this.demoNotification,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      profileImage: json['profileImage'] ?? '',
      username: json['username'] ?? '',
      instagram: json['instagram'] ?? '',
      youtube: json['youtube'] ?? '',
      demoNotification: json['demoNotification'] ?? false,
    );
  }

  static UserProfile empty() {
    return UserProfile(
      profileImage: "https://i.pravatar.cc/150?img=20",
      username: "",
      instagram: "",
      youtube: "",
      demoNotification: false,
    );
  }
}