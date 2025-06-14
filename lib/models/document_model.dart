class DocumentModel {
  final String name;
  final String url;
  final double sizeMb;
  final DateTime date;

  DocumentModel({
    required this.name,
    required this.url,
    required this.sizeMb,
    required this.date,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      sizeMb: (json['sizeMb'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'sizeMb': sizeMb,
      'date': date.toIso8601String(),
    };
  }
}
