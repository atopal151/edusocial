class SenderModel {
  final int id;
  final String accountType;
  final String name;
  final String surname;
  final String username;
  final String avatarUrl;

  SenderModel({
    required this.id,
    required this.accountType,
    required this.name,
    required this.surname,
    required this.username,
    required this.avatarUrl,
  });

  factory SenderModel.fromJson(Map<String, dynamic> json) {
    return SenderModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      accountType: json['account_type'] ?? '',
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }

  factory SenderModel.empty() {
    return SenderModel(
      id: 0,
      accountType: '',
      name: '',
      surname: '',
      username: '',
      avatarUrl: '',
    );
  }
}
