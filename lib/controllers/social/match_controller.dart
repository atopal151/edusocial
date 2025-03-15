import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../screens/main_screen.dart';
import '../nav_bar_controller.dart';

class MatchController extends GetxController {
  final TextEditingController textFieldController = TextEditingController();
  var savedTopics = <String>[].obs;
  var isLoading = false.obs;
  var matches = <MatchModel>[].obs;
  var currentIndex = 0.obs;

  final NavigationController navigationController =
      Get.put(NavigationController()); // Get.find yerine Get.put kullan

  MatchModel get currentMatch => matches[currentIndex.value];

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void findMatch() {
    Get.toNamed("/match");
  }

  void _loadMockData() {
   
   matches.addAll([
      MatchModel(
        name: "Khan Aleran",
        age: 25,
        about: "ysa ki dostoyevski; dünyaca ünlü ukraynalı yazar raskolnikov'un tercih ettiği bir çeşit salamura zeytindir. tanım: korkan birisinin beyanı. derin korkularının vardır bir sebebi, muhakkak.",
        profileImage: "https://randomuser.me/api/portraits/men/1.jpg",
        isOnline: true,
        schoolName: "Monnet International School",
        schoolLogo: "https://s3-alpha-sig.figma.com/img/5dd4/2293/d960cc339e8c771cd95a449eb4c4aa42?Expires=1742774400&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=WAWo5lofVH2qVIGeHFaFrhd9sQY07hAbg-trezJOzP2QAwZEZBZ2HnSJ3w3VwBYYuW7X5DLsz5m7k9BGq6QBqHn7i7HyF~BqCivZ~KrPXPdBx40P2Zrg8qiY~Zz4718z0DdjFT-P5q5MmdFvtz75TvUdCW4rqRf5A0s5~4UO71pAEaTGFExDxfRLGPLDwx7hjRGc~ks6aZ5zB5ZiPPMu9fofP9kPv8mw53ROQMFLuVZWLt0xYSPcVfQzHsB5XaGRi2GFW~lwvPaP-~4k71LfhmwBdAKTm~xrJZUTRqEp3swN8hHwcWbOXjomU9xidIQJxLsg3tTtYfNuOI-SHl7yEA__",
        department: "Computer Engineering",
        grade: 2,
        matchedTopics: ["Veri Yapıları ve Algoritmalar", "Pazarlama Yönetimi",],
      ),
      MatchModel(
        name: "Elena Moris",
        age: 22,
        about: "ysa ki dostoyevski; dünyaca ünlü ukraynalı yazar raskolnikov'un tercih ettiği bir çeşit salamura zeytindir. tanım: korkan birisinin beyanı. derin korkularının vardır bir sebebi, muhakkak.",
        profileImage: "https://randomuser.me/api/portraits/women/2.jpg",
        isOnline: false,
        schoolName: "Harvard University",
        schoolLogo: "https://s3-alpha-sig.figma.com/img/5dd4/2293/d960cc339e8c771cd95a449eb4c4aa42?Expires=1742774400&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=WAWo5lofVH2qVIGeHFaFrhd9sQY07hAbg-trezJOzP2QAwZEZBZ2HnSJ3w3VwBYYuW7X5DLsz5m7k9BGq6QBqHn7i7HyF~BqCivZ~KrPXPdBx40P2Zrg8qiY~Zz4718z0DdjFT-P5q5MmdFvtz75TvUdCW4rqRf5A0s5~4UO71pAEaTGFExDxfRLGPLDwx7hjRGc~ks6aZ5zB5ZiPPMu9fofP9kPv8mw53ROQMFLuVZWLt0xYSPcVfQzHsB5XaGRi2GFW~lwvPaP-~4k71LfhmwBdAKTm~xrJZUTRqEp3swN8hHwcWbOXjomU9xidIQJxLsg3tTtYfNuOI-SHl7yEA__",
        department: "Business Administration",
        grade: 3,
        matchedTopics: ["Yönetim Stratejileri", "Ekonomi","Deneme",],
      ),
      // 8 tane daha örnek veri ekleyebilirsin
    ]);
  }

  void followUser() {
    Get.snackbar("Takip", "${currentMatch.name} takip edildi!",
        snackPosition: SnackPosition.BOTTOM);
  }

  void startChat() {
    Get.snackbar("Mesaj", "${currentMatch.name} ile mesajlaşma başlatılıyor...",
        snackPosition: SnackPosition.BOTTOM);
  }

  void nextMatch() {
    if (currentIndex.value < matches.length - 1) {
      currentIndex.value++;
    } else {
      currentIndex.value = 0; // Baştan başla
    }
  }

  void addTopic() {
    if (textFieldController.text.isNotEmpty) {
      savedTopics.add(textFieldController.text);
      textFieldController.clear();
    }
  }

  void removeTopic(String topic) {
    savedTopics.remove(topic);
  }

  void findMatches() {
    isLoading.value = true;
    Future.delayed(Duration(seconds: 2), () {
      isLoading.value = false;
      Get.snackbar("Eşleşme", "Uygun eşleşmeler bulundu!",
          backgroundColor: Colors.white);

      // Yeni yönlendirme
      navigationController.changeIndex(2);
      Get.offAll(() => MainScreen()); // Sayfanın tamamen yenilenmesini sağlar
    });
  }
}

class MatchModel {
  String name;
  int age;
  String profileImage;
  bool isOnline;
  String schoolName;
  String schoolLogo;
  String department;
  String about;
  int grade;
  List<String> matchedTopics;

  MatchModel({
    required this.name,
    required this.age,
    required this.profileImage,
    required this.isOnline,
    required this.schoolName,
    required this.schoolLogo,
    required this.department,
    required this.about,
    required this.grade,
    required this.matchedTopics,
  });
}
