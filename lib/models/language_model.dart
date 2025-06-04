// language_model.dart

class LanguageModel {
  final int id;
  final String name;

  LanguageModel({required this.id, required this.name});

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
