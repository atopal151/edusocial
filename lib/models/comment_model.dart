class CommentModel {
  final String username;
  final String userProfileImage;
  final String commentText;
  final String commentDate;

  CommentModel(
      {required this.username,
      required this.userProfileImage,
      required this.commentDate,
      required this.commentText});
}
