class UserSearchModel {
  final int id;
  final String name;
  final String surname;
  final String username;
  final String avatarUrl;
  final bool isOnline;
  final bool isFollowing;
  final bool isFollowingPending;

  UserSearchModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.username,
    required this.avatarUrl,
    required this.isOnline,
    required this.isFollowing,
    required this.isFollowingPending,
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) {
    return UserSearchModel(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      isOnline: json['is_online'],
      isFollowing: json['is_following'],
      isFollowingPending: json['is_following_pending'],
    );
  }
}
