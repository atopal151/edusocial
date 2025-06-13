class DetailDocumentModel {
  final String name;
  final DateTime date;
  final String url;

  DetailDocumentModel({
    required this.name,
    required this.date,
    required this.url,
  });

  factory DetailDocumentModel.fromJson(Map<String, dynamic> json) {
    return DetailDocumentModel(
      name: json['name'] ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
      url: json['url'] ?? '',
    );
  }
}
