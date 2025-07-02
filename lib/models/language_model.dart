// language_model.dart

class LanguageModel {
  final int id;
  final String name;
  final String code;

  LanguageModel({required this.id, required this.name, required this.code});

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'],
      name: json['name'],
      code: json['code'] ?? 'en', // Varsayılan olarak 'en'
    );
  }
}
