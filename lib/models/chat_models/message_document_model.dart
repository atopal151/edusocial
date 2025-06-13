class MessageDocumentModel {
  final int id;
  final String path;
  final String name;
  final String type;
  final String size;

  MessageDocumentModel({
    required this.id,
    required this.path,
    required this.name,
    required this.type,
    required this.size,
  });

  factory MessageDocumentModel.fromJson(Map<String, dynamic> json) {
    return MessageDocumentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      path: json['path'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      size: json['size'] ?? '',
    );
  }
} 