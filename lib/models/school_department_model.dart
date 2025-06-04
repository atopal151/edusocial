class SchoolDepartmentModel {
  final int id;
  final String title;

  SchoolDepartmentModel({
    required this.id,
    required this.title,
  });

  factory SchoolDepartmentModel.fromJson(Map<String, dynamic> json) {
    return SchoolDepartmentModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
    );
  }
}
