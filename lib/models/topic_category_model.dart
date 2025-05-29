class CategoryModel {
  final int id;
  final String title;
  final String description;

  CategoryModel({
    required this.id,
    required this.title,
    required this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }
}
