class HotTopicsModel {
  final int id;
  final String title;
  final String? slug;
  final int? entryCount;

  HotTopicsModel({
    required this.id,
    required this.title,
    this.slug,
    this.entryCount,
  });

  factory HotTopicsModel.fromJson(Map<String, dynamic> json) {
    return HotTopicsModel(
      id: json['id'] ?? 0,
      title: json['name'] ?? '',
      slug: json['slug'],
      entryCount: json['entry_count'],
    );
  }
}
