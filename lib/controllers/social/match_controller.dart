import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/match_model.dart';
import '../nav_bar_controller.dart';

class MatchController extends GetxController {
  final TextEditingController textFieldController = TextEditingController();
  var savedTopics = <String>[].obs;
  var isLoading = false.obs;
  var matches = <MatchModel>[].obs;
  var currentIndex = 0.obs;

  final NavigationController navigationController = Get.find();

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
        name: "Merve Gökçen",
        age: 24,
        about: "Tıpta uzmanlık alanım nöroloji. Bilimsel makale yazıyorum.",
        profileImage:
            "https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg",
        isOnline: true,
        schoolName: "Hacettepe Üniversitesi",
        schoolLogo:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvoc1IJGlYmyiG6XEhiO7YKCs9Rf2HZzBuNw&s",
        department: "Medicine",
        grade: 5,
        matchedTopics: ["Nöroloji", "Genetik Araştırmalar"],
      ),
      MatchModel(
        name: "Ayşe Nur Kaya",
        age: 21,
        about: "Psikoloji alanında gözlem yapmayı ve yazmayı seviyorum.",
        profileImage:
            "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg",
        isOnline: true,
        schoolName: "Boğaziçi Üniversitesi",
        schoolLogo:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcReiTPY4lDPjzgH1SWoUQRPcZhED7fAqT5eRQ&s",
        department: "Psychology",
        grade: 2,
        matchedTopics: ["Davranış Bilimleri", "Toplum Psikolojisi"],
      ),
      MatchModel(
        name: "Sofia Ramirez",
        age: 23,
        about:
            "İlgi alanım yapay zekâ, sürdürülebilirlik ve kadın girişimciliği.",
        profileImage:
            "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
        isOnline: true,
        schoolName: "Oxford University",
        schoolLogo:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcReiTPY4lDPjzgH1SWoUQRPcZhED7fAqT5eRQ&s",
        department: "Artificial Intelligence",
        grade: 3,
        matchedTopics: ["Makine Öğrenmesi", "Etik ve Teknoloji"],
      ),
      MatchModel(
        name: "Liam Chen",
        age: 24,
        about: "Kod yazmayı ve açık kaynak katkılarını çok severim.",
        profileImage:
            "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg",
        isOnline: false,
        schoolName: "Stanford University",
        schoolLogo:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7Tioo73anZDRZ2DK90mLk1nUcsUfY1ga8Cg&s",
        department: "Computer Science",
        grade: 4,
        matchedTopics: ["Veri Yapıları", "Blockchain Teknolojisi"],
      ),
      MatchModel(
        name: "Takeshi Nakamura",
        age: 22,
        about:
            "UI/UX tasarımı ve insan-bilgisayar etkileşimi konularında çalışıyorum.",
        profileImage:
            "https://images.pexels.com/photos/1704488/pexels-photo-1704488.jpeg",
        isOnline: false,
        schoolName: "Kyoto University",
        schoolLogo:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7Tioo73anZDRZ2DK90mLk1nUcsUfY1ga8Cg&s",
        department: "Design Engineering",
        grade: 3,
        matchedTopics: ["Kullanıcı Deneyimi", "Arayüz Tasarımı"],
      ),
      MatchModel(
        name: "Nora Jensen",
        age: 20,
        about: "Çevre politikaları üzerine çalışıyor ve yazılar yazıyorum.",
        profileImage:
            "https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg",
        isOnline: true,
        schoolName: "Copenhagen University",
        schoolLogo:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvoc1IJGlYmyiG6XEhiO7YKCs9Rf2HZzBuNw&s",
        department: "Environmental Science",
        grade: 2,
        matchedTopics: ["İklim Değişikliği", "Sürdürülebilir Kalkınma"],
      ),
      MatchModel(
        name: "Marco Esposito",
        age: 26,
        about:
            "Girişimcilik ve teknoloji tabanlı iş modelleri üzerine çalışıyorum.",
        profileImage:
            "https://images.pexels.com/photos/2379005/pexels-photo-2379005.jpeg",
        isOnline: false,
        schoolName: "Politecnico di Milano",
        schoolLogo:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7Tioo73anZDRZ2DK90mLk1nUcsUfY1ga8Cg&s",
        department: "Business Innovation",
        grade: 4,
        matchedTopics: ["Startup Kültürü", "Yatırım Altyapısı"],
      ),
      MatchModel(
        name: "Elif Demir",
        age: 22,
        about: "Yazılım mühendisliği okuyorum. Mobil uygulama geliştiriyorum.",
        profileImage:
            "https://images.pexels.com/photos/762020/pexels-photo-762020.jpeg",
        isOnline: true,
        schoolName: "İstanbul Teknik Üniversitesi",
        schoolLogo:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7Tioo73anZDRZ2DK90mLk1nUcsUfY1ga8Cg&s",
        department: "Software Engineering",
        grade: 3,
        matchedTopics: ["Flutter", "Siber Güvenlik"],
      ),
      MatchModel(
        name: "David Wilson",
        age: 27,
        about: "Veri bilimi ve istatistiksel modelleme üzerine uzmanlaştım.",
        profileImage:
            "https://images.pexels.com/photos/1704487/pexels-photo-1704487.jpeg",
        isOnline: false,
        schoolName: "MIT",
        schoolLogo:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7Tioo73anZDRZ2DK90mLk1nUcsUfY1ga8Cg&s",
        department: "Data Science",
        grade: 4,
        matchedTopics: ["İstatistiksel Modelleme", "Makine Öğrenmesi"],
      ),
      
      MatchModel(
        name: "Alex Müller",
        age: 21,
        about: "Sanat ve teknoloji birleşimi konularında çalışıyorum.",
        profileImage:
            "https://images.pexels.com/photos/1704486/pexels-photo-1704486.jpeg",
        isOnline: false,
        schoolName: "Berlin University of the Arts",
        schoolLogo:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvoc1IJGlYmyiG6XEhiO7YKCs9Rf2HZzBuNw&s",
        department: "Digital Arts",
        grade: 2,
        matchedTopics: ["Dijital Medya", "Yaratıcı Kodlama"],
      ),
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

    Future.delayed(Duration(seconds: 1), () {
      isLoading.value = false;

      // Verileri buraya ekle
      matches.assignAll([
        MatchModel(
          name: "Merve Gökçen",
          age: 24,
          about: "Tıpta uzmanlık alanım nöroloji. Bilimsel makale yazıyorum.",
          profileImage:
              "https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg",
          isOnline: true,
          schoolName: "Hacettepe Üniversitesi",
          schoolLogo:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvoc1IJGlYmyiG6XEhiO7YKCs9Rf2HZzBuNw&s",
          department: "Medicine",
          grade: 5,
          matchedTopics: ["Nöroloji", "Genetik Araştırmalar"],
        ),
        MatchModel(
          name: "Ayşe Nur Kaya",
          age: 21,
          about: "Psikoloji alanında gözlem yapmayı ve yazmayı seviyorum.",
          profileImage:
              "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg",
          isOnline: true,
          schoolName: "Boğaziçi Üniversitesi",
          schoolLogo:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcReiTPY4lDPjzgH1SWoUQRPcZhED7fAqT5eRQ&s",
          department: "Psychology",
          grade: 2,
          matchedTopics: ["Davranış Bilimleri", "Toplum Psikolojisi"],
        ),
        // ... devamındaki tüm MatchModel verilerini buraya ekle ...
      ]);
      print(matches);
      print('MATCH controller hash: ${navigationController.hashCode}');

      Get.snackbar("Eşleşme", "Uygun eşleşmeler bulundu!",
          backgroundColor: Colors.white);

      navigationController.changeIndex(2);
      //Get.toNamed("/match_result");
      
    print("Index set edildi: ${navigationController.selectedIndex.value}");
    });
  }
}
