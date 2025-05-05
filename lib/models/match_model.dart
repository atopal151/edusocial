class MatchModel {
  String name;
  int age;
  String profileImage;
  bool isOnline;
  String schoolName;
  String schoolLogo;
  String department;
  String about;
  int grade;
  List<String> matchedTopics;

  MatchModel({
    required this.name,
    required this.age,
    required this.profileImage,
    required this.isOnline,
    required this.schoolName,
    required this.schoolLogo,
    required this.department,
    required this.about,
    required this.grade,
    required this.matchedTopics,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      profileImage: json['profile_image'] ?? '',
      isOnline: json['is_online'] ?? false,
      schoolName: json['school_name'] ?? '',
      schoolLogo: json['school_logo'] ?? '',
      department: json['department'] ?? '',
      about: json['about'] ?? '',
      grade: json['grade'] ?? 0,
      matchedTopics: List<String>.from(json['matched_topics'] ?? []),
    );
  }
}
