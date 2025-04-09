class SchoolDepartmentData {
  final String school;
  final List<String> departments;

  SchoolDepartmentData({required this.school, required this.departments});

  factory SchoolDepartmentData.fromJson(Map<String, dynamic> json) {
    return SchoolDepartmentData(
      school: json['school'],
      departments: List<String>.from(json['departments']),
    );
  }
}
