class GroupAreaModel {
  final String id;
  final String name;

  GroupAreaModel({required this.id, required this.name});

  factory GroupAreaModel.fromJson(Map<String, dynamic> json) {
    return GroupAreaModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupAreaModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
