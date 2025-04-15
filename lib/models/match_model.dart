
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
}
