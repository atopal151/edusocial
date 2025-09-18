// language_model.dart

class LanguageModel {
  final int id;
  final String name;
  final String code;
  final String? imageFullPath;

  LanguageModel({
    required this.id, 
    required this.name, 
    required this.code,
    this.imageFullPath,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'],
      name: json['name'],
      code: json['code'] ?? 'en', // Varsayılan olarak 'en'
      imageFullPath: json['image_full_path'],
    );
  }
}
