class PostModel {
  final String profileImage;
  final String userName;
  final String postDate;
  final String postDescription;
  final String? postImage; // Gönderi fotoğrafı opsiyonel
  final int likeCount;
  final int commentCount;

  PostModel({
    required this.profileImage,
    required this.userName,
    required this.postDate,
    required this.postDescription,
    this.postImage,
    required this.likeCount,
    required this.commentCount,
  });

  // JSON'dan Model'e dönüştürme fonksiyonu
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      profileImage: json["profileImage"],
      userName: json["userName"],
      postDate: json["postDate"],
      postDescription: json["postDescription"],
      postImage: json["postImage"], // Opsiyonel alan olabilir
      likeCount: json["likeCount"],
      commentCount: json["commentCount"],
    );
  }
}
