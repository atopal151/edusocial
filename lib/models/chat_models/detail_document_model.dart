class DetailDocumentModel {
  final String name;
  final String url;
  final String date;

  DetailDocumentModel({
    required this.name,
    required this.url,
    required this.date,
  });

  factory DetailDocumentModel.fromJson(Map<String, dynamic> json) {
    return DetailDocumentModel(
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      date: json['date']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'date': date,
    };
  }
}
