import 'package:get/get.dart';
import '../models/post_model.dart';

class PostController extends GetxController {
  var isLoading = true.obs;
  var postList = <PostModel>[].obs;

  @override
  void onInit() {
    fetchPosts(); // Sayfa açıldığında verileri çek
    super.onInit();
  }

  void fetchPosts() async {
    await Future.delayed(Duration(seconds: 2)); // API çağrısı simülasyonu

    var fetchedPosts = [
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/women/44.jpg",
        userName: "Alara Christie",
        postDate: "31 Oca Cum",
        postDescription:
            "Çözmeye çalıştım ama iç içe türev alma kısmında kafam karıştı...",
        postImage: "https://s3-alpha-sig.figma.com/img/614c/4772/ae89e0da6e3074c4679e33c95eb40629?Expires=1743379200&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=ZhvqwqhcnB2KgTdqiy4JUHUxwnhgHlI-12rx67EzIG-5UB6ll4Vp6An5fQj5PktmWRjXEdnvIISkK0UvHtGTQJzQb6P6L9-QGx9P4i1FgsVwTsv-jj8jQyVVX3YWO2Cz9BGCLxieo3jDZgnlrPG6hz6LoNIpffXWwxXE-Mm3Ag9RYHXfu2zqeLxrphDMfdxeGl3gwjP9R7X9zm2UdWsiadtuxwwShIbOdOA8rdtc7nWE28hUWg9Z3z3fDrFTe4R0nhvx90rosAjcaQ8dYuEUSq1Bwv9HFmy6FeJRo5~NQ6TSGsYL1jpSe5WRWVyQNMlz3as3vNuWGVUHMTE3yip8Ww__",
        likeCount: 253,
        commentCount: 8434,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/men/50.jpg",
        userName: "Emre Yıldız",
        postDate: "2 Şub Cum",
        postDescription: "Diferansiyel denklemlerle ilgili çalışıyorum.",
        postImage: null, // Bu gönderide fotoğraf yok
        likeCount: 180,
        commentCount: 1290,
      ), PostModel(
        profileImage: "https://randomuser.me/api/portraits/men/50.jpg",
        userName: "Emre Yıldız",
        postDate: "2 Şub Cum",
        postDescription: "Diferansiyel denklemlerle ilgili çalışıyorum.",
        postImage: null, // Bu gönderide fotoğraf yok
        likeCount: 180,
        commentCount: 1290,
      ), PostModel(
        profileImage: "https://randomuser.me/api/portraits/men/50.jpg",
        userName: "Emre Yıldız",
        postDate: "2 Şub Cum",
        postDescription: "Diferansiyel denklemlerle ilgili çalışıyorum.",
        postImage: null, // Bu gönderide fotoğraf yok
        likeCount: 180,
        commentCount: 1290,
      ),
    ];

    postList.assignAll(fetchedPosts);
    isLoading.value = false;
  }
}
