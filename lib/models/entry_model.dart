class EntryModel {
  final String profileImage;
  final String userName;
  final String entryDate;
  final String entryTitle;
  final String entryDescription;
  final bool isActive;
  int upvoteCount;
  int downvoteCount;

  EntryModel({
    required this.profileImage,
    required this.userName,
    required this.entryDate,
    required this.entryTitle,
    required this.entryDescription,
    required this.upvoteCount,
    required this.downvoteCount,required this.isActive, 
  });
}
