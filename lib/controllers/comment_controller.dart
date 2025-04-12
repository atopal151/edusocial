import 'package:get/get.dart';
import '../models/comment_model.dart';

class CommentController extends GetxController {
  var comments = <CommentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMockComments();
  }

  void fetchMockComments() {
    comments.value = [
      CommentModel(
        username: "Ahmet Yılmaz",
        userProfileImage: "https://randomuser.me/api/portraits/men/10.jpg",
        commentText: "Bu gönderi harika!",
        commentDate: "2 saat önce",
      ),
      CommentModel(
        username: "Zeynep Kara",
        userProfileImage: "https://randomuser.me/api/portraits/women/21.jpg",
        commentText: "Tebrikler 👏",
        commentDate: "1 saat önce",
      ),
    ];
  }

  void addComment(String text) {
    comments.insert(
      0,
      CommentModel(
        username: "Sen",
        userProfileImage: "https://randomuser.me/api/portraits/men/32.jpg",
        commentText: text,
        commentDate: "Şimdi",
      ),
    );
  }
}
