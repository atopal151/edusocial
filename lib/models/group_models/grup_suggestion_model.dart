

class GroupSuggestionModel {
  final String id;
  final String groupName;
  final String groupImage; // Kapak fotoğrafı
  final String groupAvatar; // Grup profili (yuvarlak)
  final int memberCount; // Üye sayısı
  final String description;

  GroupSuggestionModel({
    required this.id,
    required this.groupName,
    required this.groupImage,
    required this.groupAvatar,
    required this.memberCount,
    required this.description,
  });

  factory GroupSuggestionModel.fromJson(Map<String, dynamic> json) {
  return GroupSuggestionModel(
    id: json['id'].toString(),
    groupName: json['name'] ?? '',
    description: json['description'] ?? '',
    memberCount: json['user_count_with_admin'] ?? 0,
    groupAvatar: (json['avatar_url'] != null && json['avatar_url'].toString().isNotEmpty)
        ? json['avatar_url']
        : 'https://via.placeholder.com/150',
    groupImage: (json['banner_url'] != null && json['banner_url'].toString().isNotEmpty)
        ? json['banner_url']
        : 'https://via.placeholder.com/300x150',
  );
}

}
