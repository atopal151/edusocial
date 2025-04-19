class GroupModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int memberCount;
  final String category;
  final bool isJoined;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.memberCount,
    required this.category,
    required this.isJoined,
  });


  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? memberCount,
    String? category,
    bool? isJoined,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      memberCount: memberCount ?? this.memberCount,
      category: category ?? this.category,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}



class GroupSearchModel {
  final String name;
  final String description;
  final int memberCount;
  final String image;

  GroupSearchModel(
      {required this.name,
      required this.description,
      required this.memberCount,
      required this.image});
}