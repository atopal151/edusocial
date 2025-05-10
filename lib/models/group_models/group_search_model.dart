class GroupSearchModel {
  final String name;
  final String description;
  final int memberCount;
  final String image;

  GroupSearchModel({
    required this.name,
    required this.description,
    required this.memberCount,
    required this.image,
  });

  factory GroupSearchModel.fromJson(Map<String, dynamic> json) {
    return GroupSearchModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      memberCount: json['member_count'] ?? 0,
      image: json['image'] ?? '',
    );
  }
}
