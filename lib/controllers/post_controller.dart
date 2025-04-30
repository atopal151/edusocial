import 'package:edusocial/services/post_service.dart';
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
        postImage: "https://images.pexels.com/photos/31341763/pexels-photo-31341763/free-photo-of-toskana-daki-siyah-ve-beyaz-kis-ormani.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
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
      ), PostModel(
       profileImage: "https://randomuser.me/api/portraits/women/44.jpg",
        userName: "Alara Christie",
        postDate: "2 Şub Cum",
        postDescription: "Diferansiyel denklemlerle ilgili çalışıyorum.",
        postImage: null, // Bu gönderide fotoğraf yok
        likeCount: 180,
        commentCount: 1290,
      ), PostModel(
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
    print(posts);
  } catch (e) {
    print("❗ Post çekme hatası: $e");
  } finally {
    isHomeLoading.value = false;
  }
}

/*
    void fetchHomePosts() async {
    await Future.delayed(Duration(seconds: 2)); // API çağrısı simülasyonu

    var fetchedHomePosts = [
           PostModel(
        profileImage: "https://randomuser.me/api/portraits/men/0.jpg",
        userName: "Mert Aslan",
        postDate: "15 Mar Cum",
        postDescription: "Bugünkü matematik sınavı gerçekten zordu.",
        postImage: "https://images.pexels.com/photos/31341763/pexels-photo-31341763/free-photo-of-toskana-daki-siyah-ve-beyaz-kis-ormani.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        likeCount: 95,
        commentCount: 1527,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/women/1.jpg",
        userName: "Ceren Güneş",
        postDate: "3 Mar Cum",
        postDescription: "Makale sunumum için biraz yardıma ihtiyacım var.",
        postImage: null,
        likeCount: 201,
        commentCount: 1553,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/men/2.jpg",
        userName: "Yusuf Demir",
        postDate: "26 Mar Cum",
        postDescription: "Yeni öğrendiğim algoritmalar çok işime yaradı.",
        postImage: null,
        likeCount: 494,
        commentCount: 1255,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/women/3.jpg",
        userName: "Sude Yıldız",
        postDate: "19 Mar Cum",
        postDescription: "Uygulama geliştirme süreci harika ilerliyor.",
        postImage: "https://images.pexels.com/photos/31341763/pexels-photo-31341763/free-photo-of-toskana-daki-siyah-ve-beyaz-kis-ormani.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        
        likeCount: 484,
        commentCount: 2106,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/men/4.jpg",
        userName: "Ali Kılıç",
        postDate: "24 Mar Cum",
        postDescription: "Bitirme projem için kaynak arıyorum.",
        postImage: null,
        likeCount: 141,
        commentCount: 2890,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/women/5.jpg",
        userName: "Elif Aksoy",
        postDate: "10 Mar Cum",
        postDescription: "Sınav haftası başlasın o zaman...",
        postImage: null,
        likeCount: 450,
        commentCount: 562,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/men/6.jpg",
        userName: "Kerem Şahin",
        postDate: "1 Mar Cum",
        postDescription: "Zaman yönetimi konusunda hala gelişmem lazım.",
        postImage: "https://images.pexels.com/photos/31341763/pexels-photo-31341763/free-photo-of-toskana-daki-siyah-ve-beyaz-kis-ormani.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        
        likeCount: 207,
        commentCount: 355,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/women/7.jpg",
        userName: "Zeynep Kurt",
        postDate: "24 Mar Cum",
        postDescription: "Staj başvurularımı tamamladım!",
        postImage: null,
        likeCount: 213,
        commentCount: 1759,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/men/8.jpg",
        userName: "Baran Eroğlu",
        postDate: "14 Mar Cum",
        postDescription: "Yeni kulübe katıldım, çok heyecanlıyım.",
        postImage: null,
        likeCount: 70,
        commentCount: 2671,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/women/9.jpg",
        userName: "Ayşe Toprak",
        postDate: "12 Mar Cum",
        postDescription: "Kampüste güzel bir gün.",
        postImage: "https://images.pexels.com/photos/31341763/pexels-photo-31341763/free-photo-of-toskana-daki-siyah-ve-beyaz-kis-ormani.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        
        likeCount: 400,
        commentCount: 314,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/men/10.jpg",
        userName: "Deniz Sarı",
        postDate: "27 Mar Cum",
        postDescription: "Sabaha kadar proje!",
        postImage: null,
        likeCount: 264,
        commentCount: 2876,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/women/11.jpg",
        userName: "Berkay Tuncel",
        postDate: "3 Mar Cum",
        postDescription: "Sunumum gayet güzel geçti.",
        postImage: null,
        likeCount: 113,
        commentCount: 2933,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/men/12.jpg",
        userName: "Melis Arslan",
        postDate: "1 Mar Cum",
        postDescription: "Kütüphane bugünkü ofisim.",
        postImage: "https://images.pexels.com/photos/31341763/pexels-photo-31341763/free-photo-of-toskana-daki-siyah-ve-beyaz-kis-ormani.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        
        likeCount: 433,
        commentCount: 334,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/women/13.jpg",
        userName: "Burak Çelik",
        postDate: "6 Mar Cum",
        postDescription: "Bölüm arkadaşlarım çok destekleyici.",
        postImage: null,
        likeCount: 397,
        commentCount: 918,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/men/14.jpg",
        userName: "Nazlı Koç",
        postDate: "14 Mar Cum",
        postDescription: "Yeni öğrendiğim framework süpermiş.",
        postImage: null,
        likeCount: 455,
        commentCount: 594,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/women/15.jpg",
        userName: "Onur Polat",
        postDate: "3 Mar Cum",
        postDescription: "Dünya Kadınlar Günü kutlu olsun!",
        postImage: "https://images.pexels.com/photos/31341763/pexels-photo-31341763/free-photo-of-toskana-daki-siyah-ve-beyaz-kis-ormani.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        
        likeCount: 87,
        commentCount: 1329,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/men/16.jpg",
        userName: "Gamze Yavuz",
        postDate: "26 Mar Cum",
        postDescription: "Bugün derse geç kaldım...",
        postImage: null,
        likeCount: 208,
        commentCount: 1179,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/women/17.jpg",
        userName: "Kaan Demirtaş",
        postDate: "18 Mar Cum",
        postDescription: "Yeni kitaplar aldım, okumak için sabırsızım.",
        postImage: null,
        likeCount: 256,
        commentCount: 1314,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/men/18.jpg",
        userName: "Duru Aydın",
        postDate: "16 Mar Cum",
        postDescription: "Zor bir gün ama bitti.",
        postImage: "https://images.pexels.com/photos/31341763/pexels-photo-31341763/free-photo-of-toskana-daki-siyah-ve-beyaz-kis-ormani.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        
        likeCount: 66,
        commentCount: 626,
      ),
      PostModel(
        profileImage: "https://randomuser.me/api/portraits/women/19.jpg",
        userName: "Arda Güzel",
        postDate: "4 Mar Cum",
        postDescription: "Motivasyon lazım.",
        postImage: null,
        likeCount: 307,
        commentCount: 1446,
      ),

    ];

    postHomeList.assignAll(fetchedHomePosts);
    isHomeLoading.value = false;
  }*/
}
