class GroupSearchModel {
  final int id;
  final int userId;
  final int groupAreaId;
  final String name;
  final String description;
  final String status;
  final bool isPrivate;
  final String createdAt;
  final String updatedAt;
  final int userCountWithAdmin;
  final int userCountWithoutAdmin;
  final int messageCount;
  final bool isFounder;
  final bool isMember;
  final bool isPending;
  final String avatarUrl;
  final String bannerUrl;
  final String humanCreatedAt;

  GroupSearchModel({
    required this.id,
    required this.userId,
    required this.groupAreaId,
    required this.name,
    required this.description,
    required this.status,
    required this.isPrivate,
    required this.createdAt,
    required this.updatedAt,
    required this.userCountWithAdmin,
    required this.userCountWithoutAdmin,
    required this.messageCount,
    required this.isFounder,
    required this.isMember,
    required this.isPending,
    required this.avatarUrl,
    required this.bannerUrl,
    required this.humanCreatedAt,
  });

  factory GroupSearchModel.fromJson(Map<String, dynamic> json) {
    return GroupSearchModel(
      id: json['id'],
      userId: json['user_id'],
      groupAreaId: json['group_area_id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      isPrivate: json['is_private'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      userCountWithAdmin: json['user_count_with_admin'],
      userCountWithoutAdmin: json['user_count_without_admin'],
      messageCount: json['message_count'],
      isFounder: json['is_founder'],
      isMember: json['is_member'],
      isPending: json['is_pending'],
      avatarUrl: json['avatar_url'],
      bannerUrl: json['banner_url'],
      humanCreatedAt: json['human_created_at'],
    );
  }
}
