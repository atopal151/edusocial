class LinkModel {
  final String url;
  final String title;

  LinkModel({
    required this.url,
    required this.title,
  });

  factory LinkModel.fromJson(Map<String, dynamic> json) {
    return LinkModel(
      url: json['url']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
    };
  }
}
