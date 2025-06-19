class DocumentModel {
  final String id;
  final String name;
  final double sizeMb;
  final String humanCreatedAt;
  final DateTime createdAt;
  final String? url;

  DocumentModel({
    required this.id,
    required this.name,
    required this.sizeMb,
    required this.humanCreatedAt,
    required this.createdAt,
    this.url,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'].toString(),
      name: json['name'],
      sizeMb: (json['size_mb'] as num).toDouble(),
      humanCreatedAt: json['human_created_at'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sizeMb': sizeMb,
      'humanCreatedAt': humanCreatedAt,
      'createdAt': createdAt.toIso8601String(),
      'url': url,
    };
  }
}
