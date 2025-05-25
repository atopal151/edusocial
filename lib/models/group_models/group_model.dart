class GroupModel {
  final String id;
  final int userId;
  final int groupAreaId;
  final String name;
  final String description;
  final String status;
  final bool isPrivate;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int userCountWithAdmin;
  final int userCountWithoutAdmin;
  final int messageCount;
  final bool isFounder;
  final bool isMember;
  final bool isPending;
  final String avatarUrl;
  final String bannerUrl;
  final String humanCreatedAt;
  final String? pivotCreatedAt;
  final String? pivotUpdatedAt;

  GroupModel({
    required this.id,
    required this.userId,
    required this.groupAreaId,
    required this.name,
    required this.description,
    required this.status,
    required this.isPrivate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.userCountWithAdmin,
    required this.userCountWithoutAdmin,
    required this.messageCount,
    required this.isFounder,
    required this.isMember,
    required this.isPending,
    required this.avatarUrl,
    required this.bannerUrl,
    required this.humanCreatedAt,
    this.pivotCreatedAt,
    this.pivotUpdatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'].toString(),
      userId: json['user_id'] ?? 0,
      groupAreaId: json['group_area_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      isPrivate: json['is_private'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
      userCountWithAdmin: json['user_count_with_admin'] ?? 0,
      userCountWithoutAdmin: json['user_count_without_admin'] ?? 0,
      messageCount: json['message_count'] ?? 0,
      isFounder: json['is_founder'] ?? false,
      isMember: json['is_member'] ?? false,
      isPending: json['is_pending'] ?? false,
      avatarUrl: json['avatar_url'] ?? '',
      bannerUrl: json['banner_url'] ?? '',
      humanCreatedAt: json['human_created_at'] ?? '',
      pivotCreatedAt: json['pivot']?['created_at'],
      pivotUpdatedAt: json['pivot']?['updated_at'],
    );
  }

  GroupModel copyWith({
    bool? isJoined,
  }) {
    return GroupModel(
      id: id,
      userId: userId,
      groupAreaId: groupAreaId,
      name: name,
      description: description,
      status: status,
      isPrivate: isPrivate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      userCountWithAdmin: userCountWithAdmin,
      userCountWithoutAdmin: userCountWithoutAdmin,
      messageCount: messageCount,
      isFounder: isFounder,
      isMember: isJoined ?? isMember,
      isPending: isPending,
      avatarUrl: avatarUrl,
      bannerUrl: bannerUrl,
      humanCreatedAt: humanCreatedAt,
      pivotCreatedAt: pivotCreatedAt,
      pivotUpdatedAt: pivotUpdatedAt,
    );
  }
}