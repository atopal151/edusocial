
class LastMessage {
  final String message;
  final String createdAt;

  LastMessage({
    required this.message,
    required this.createdAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'created_at': createdAt,
    };
  }
}