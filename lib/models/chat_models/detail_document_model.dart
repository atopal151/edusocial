class DetailDocumentModel {
  final String id;
  final String name;
  final String url;
  final String date;

  DetailDocumentModel({
    required this.id,
    required this.name,
    required this.url,
    required this.date,
  });

  factory DetailDocumentModel.fromJson(Map<String, dynamic> json) {
    return DetailDocumentModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      date: json['date']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'date': date,
    };
  }
}
