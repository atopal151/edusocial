class SchoolModel {
  final int id;
  final String name;
  final String? logo;

  SchoolModel({required this.id, required this.name, this.logo});

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'],
    );
  }
}
