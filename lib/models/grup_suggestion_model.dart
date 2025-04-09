
class GroupSuggestionModel {
  final String groupName;
  final String groupImage;  // Kapak fotoğrafı
  final String groupAvatar; // Grup profili (yuvarlak)
  final int memberCount;    // Üye sayısı
  final String description;

  GroupSuggestionModel({
    required this.groupName,
    required this.groupImage,
    required this.groupAvatar,
    required this.memberCount,
     required this.description,
  });

  factory GroupSuggestionModel.fromJson(Map<String, dynamic> json) {
    return GroupSuggestionModel(
      groupName: json['groupName'],
      groupImage: json['groupImage'],
      groupAvatar: json['groupAvatar'],
      memberCount: json['memberCount'],
      description: json['description'],
    );
  }
}