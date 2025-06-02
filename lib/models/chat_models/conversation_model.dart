class ConversationModel {
  final int id;
  final int userOne;
  final int userTwo;

  ConversationModel({
    required this.id,
    required this.userOne,
    required this.userTwo,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      userOne: json['user_one'] is int
          ? json['user_one']
          : int.tryParse(json['user_one'].toString()) ?? 0,
      userTwo: json['user_two'] is int
          ? json['user_two']
          : int.tryParse(json['user_two'].toString()) ?? 0,
    );
  }

  factory ConversationModel.empty() {
    return ConversationModel(
      id: 0,
      userOne: 0,
      userTwo: 0,
    );
  }
}
