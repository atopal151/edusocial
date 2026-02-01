class UserSearchModel {
  final int id;
  final String name;
  final String surname;
  final String username;
  final String avatarUrl;
  final bool isOnline;
  final bool isFollowing;
  final bool isFollowingPending;
  final bool? isVerified; // Hesap doğrulama durumu

  UserSearchModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.username,
    required this.avatarUrl,
    required this.isOnline,
    required this.isFollowing,
    required this.isFollowingPending,
    this.isVerified,
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
      // Hesap doğrulama: birden fazla alan gelebileceği için hepsini kontrol et
      isVerified: _computeIsVerified(json),
    );
  }

  // Search API farklı alanlarla dönebildiği için hepsini güvenli şekilde değerlendir
  static bool _computeIsVerified(Map<String, dynamic> json) {
    bool? pick(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value == 1;
      if (value is String) {
        final lower = value.toLowerCase();
        if (lower == 'true' || lower == '1') return true;
        if (lower == 'false' || lower == '0') return false;
      }
      return null;
    }

    final fromIsVerified = pick(json['is_verified']);
    final fromVerified = pick(json['verified']);
    final fromAccount = pick(json['account_verified']);
    final fromDocument = pick(json['document_verified']);
    final fromIdentity = pick(json['identity_verified']);

    final status = json['verification_status']?.toString().toLowerCase();
    final level = json['verification_level']?.toString().toLowerCase();
    final type = json['verification_type']?.toString().toLowerCase();
    final stringVerified =
        status == 'verified' || level == 'verified' || type == 'verified';

    return fromIsVerified ??
        fromVerified ??
        fromAccount ??
        fromDocument ??
        fromIdentity ??
        stringVerified;
  }
}
