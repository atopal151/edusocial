class HotTopicsModel {
  final String title;

  HotTopicsModel({required this.title});

  factory HotTopicsModel.fromJson(Map<String, dynamic> json) {
    return HotTopicsModel(
      title: json['title'] ?? '',
    );
  }
}
