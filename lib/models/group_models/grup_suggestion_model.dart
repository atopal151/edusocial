class GroupSuggestionModel {
  final String id;
  final String groupName;
  final String groupImage; // Kapak fotoğrafı
  final String groupAvatar; // Grup profili (yuvarlak)
  final int memberCount; // Üye sayısı
  final String description;
  final String status;
  final bool isPrivate;
  final int messageCount;
  final bool isFounder;
  final bool isMember;
  final bool isPending;
  final String humanCreatedAt;
  final String groupAreaName; // JSON'daki group_area içindeki name alanı

  GroupSuggestionModel({
    required this.id,
    required this.groupName,
    required this.groupImage,
    required this.groupAvatar,
    required this.memberCount,
    required this.description,
    required this.status,
    required this.isPrivate,
    required this.messageCount,
    required this.isFounder,
    required this.isMember,
    required this.isPending,
    required this.humanCreatedAt,
    required this.groupAreaName,
  });

  factory GroupSuggestionModel.fromJson(Map<String, dynamic> json) {
    final groupArea = json['group_area'];
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
      status: json['status'] ?? '',
      isPrivate: json['is_private'] ?? false,
      messageCount: json['message_count'] ?? 0,
      isFounder: json['is_founder'] ?? false,
      isMember: json['is_member'] ?? false,
      isPending: json['is_pending'] ?? false,
      humanCreatedAt: json['human_created_at'] ?? '',
      groupAreaName: groupArea != null && groupArea['name'] != null
          ? groupArea['name']
          : '',
    );
  }
}
