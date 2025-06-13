class DetailLinkModel {
  final String title;
  final String url;

  DetailLinkModel({
    required this.title,
    required this.url,
  });

  factory DetailLinkModel.fromJson(Map<String, dynamic> json) {
    return DetailLinkModel(
      title: json['title'] ?? 'Link',
      url: json['url'] ?? '',
    );
  }
}
