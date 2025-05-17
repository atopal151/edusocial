import 'package:edusocial/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/post_model.dart';

class PostController extends GetxController {
  var isLoading = true.obs;
  var isHomeLoading = true.obs;
  var postList = <PostModel>[].obs;
  var postHomeList = <PostModel>[].obs;

  @override
  void onInit() {
    fetchPosts(); // Sayfa açıldığında verileri çek
    fetchHomePosts(); // Sayfa açıldığında verileri çek
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
        postImage:
            "https://images.pexels.com/photos/31341763/pexels-photo-31341763/free-photo-of-toskana-daki-siyah-ve-beyaz-kis-ormani.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        likeCount: 253,
        commentCount: 8434,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/women/44.jpg",
        userName: "Alara Christie",
        postDate: "2 Şub Cum",
        postDescription: "Diferansiyel denklemlerle ilgili çalışıyorum.",
        postImage: null, // Bu gönderide fotoğraf yok
        likeCount: 180,
        commentCount: 1290,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/women/44.jpg",
        userName: "Alara Christie",
        postDate: "2 Şub Cum",
        postDescription: "Diferansiyel denklemlerle ilgili çalışıyorum.",
        postImage: null, // Bu gönderide fotoğraf yok
        likeCount: 180,
        commentCount: 1290,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/women/44.jpg",
        userName: "Alara Christie",
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

  void fetchHomePosts() async {
    isHomeLoading.value = true;
    try {
      final posts = await PostServices.fetchHomePosts();
      postHomeList.assignAll(posts);
      debugPrint(posts as String?, wrapWidth: 1024);
    } catch (e) {
      debugPrint("❗ Post çekme hatası: $e",wrapWidth: 1024);
    } finally {
      isHomeLoading.value = false;
    }
  }
}
