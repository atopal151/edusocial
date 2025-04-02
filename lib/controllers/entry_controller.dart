import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/entry_model.dart';

class EntryController extends GetxController {
  var entryList = <EntryModel>[].obs;
  var entryPersonList = <EntryModel>[].obs;


  RxList<String> categoryEntry = <String>[].obs;
  RxString selectedCategory = "".obs;
  var isEntryLoading = false.obs;
  final TextEditingController titleEntryController = TextEditingController();
  final TextEditingController bodyEntryController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    categoryEntry.value = ["Genel", "Felsefe", "Spor", "Tarih"]; // örnek
    fetchEntries();
    fetchPersonEntries();
  }

  void shareEntryPost() {
    Get.snackbar("Paylaşıldı", "Entry paylaşıldı");
  }

  void shareEntry() {
    Get.toNamed("/entryShare");
  }

  void fetchEntries() {
    entryList.assignAll([
      EntryModel(
        profileImage: "https://randomuser.me/api/portraits/women/44.jpg",
        userName: "Alara Christie",
        entryDate: "26.12.2010 16:56",
        entryTitle: "Geziciler dostoyevski'yi isviçre peyniri sanıyor",
        entryDescription:
            "Oysa ki Dostoyevski; dünyaca ünlü Ukraynalı yazar Raskolnikov'un tercih ettiği bir çeşit salamura zeytindir.",
        upvoteCount: 345,
        downvoteCount: 345,
        isActive: false,
      ),
      EntryModel(
        profileImage: "https://randomuser.me/api/portraits/women/45.jpg",
        userName: "Deniz Yılmaz",
        entryDate: "05.08.2015 12:30",
        entryTitle: "Kitap okumak neden önemli?",
        entryDescription:
            "Bilgi edinmek ve hayal gücünü geliştirmek için kitap okumak büyük önem taşır.",
        upvoteCount: 198,
        downvoteCount: 45,
        isActive: true,
      ),
      EntryModel(
        profileImage: "https://randomuser.me/api/portraits/men/32.jpg",
        userName: "Ahmet Kaya",
        entryDate: "12.01.2021 09:45",
        entryTitle: "Kedilerin gizemli dünyası",
        entryDescription:
            "Kediler neden 4 ayak üstüne düşer? Bilim bu soruya cevap arıyor.",
        upvoteCount: 99,
        downvoteCount: 12,
        isActive: false,
      ),
      EntryModel(
        profileImage: "https://randomuser.me/api/portraits/women/33.jpg",
        userName: "Selin Turan",
        entryDate: "20.11.2023 18:10",
        entryTitle: "Kahve mi, çay mı?",
        entryDescription:
            "Sonsuz tartışma: sabahları ayılmak için hangisi daha etkili?",
        upvoteCount: 301,
        downvoteCount: 24,
        isActive: true,
      ),
      EntryModel(
        profileImage: "https://randomuser.me/api/portraits/men/12.jpg",
        userName: "Burak Çelik",
        entryDate: "09.03.2019 22:00",
        entryTitle: "Zaman yolculuğu mümkün mü?",
        entryDescription:
            "Fizikçiler bu konuda ikiye bölünmüş durumda. Sen ne düşünüyorsun?",
        upvoteCount: 120,
        downvoteCount: 76,
        isActive: false,
      ),
      EntryModel(
        profileImage: "https://randomuser.me/api/portraits/women/12.jpg",
        userName: "Zeynep Koç",
        entryDate: "14.07.2018 11:11",
        entryTitle: "Rüyalar ne anlatır?",
        entryDescription:
            "Bilinçaltımızla bağlantılı rüyalar geleceğimizi mi yansıtıyor?",
        upvoteCount: 222,
        downvoteCount: 30,
        isActive: true,
      ),
      EntryModel(
        profileImage: "https://randomuser.me/api/portraits/men/17.jpg",
        userName: "Can Yüce",
        entryDate: "03.05.2022 15:42",
        entryTitle: "Film müziklerinin gücü",
        entryDescription:
            "Doğru müzik bir sahneyi efsane yapabilir. En sevdiğin örnek ne?",
        upvoteCount: 150,
        downvoteCount: 15,
        isActive: true,
      ),
      EntryModel(
        profileImage: "https://randomuser.me/api/portraits/women/28.jpg",
        userName: "Gizem Erdem",
        entryDate: "01.01.2020 00:00",
        entryTitle: "Yeni yıl kararları",
        entryDescription:
            "Her yıl aynı kararlar, aynı hayal kırıklıkları... Bu yıl farklı olacak mı?",
        upvoteCount: 210,
        downvoteCount: 18,
        isActive: false,
      ),
      EntryModel(
        profileImage: "https://randomuser.me/api/portraits/men/48.jpg",
        userName: "Mert Aslan",
        entryDate: "23.04.2024 09:30",
        entryTitle: "23 Nisan kutlamaları",
        entryDescription:
            "Çocuk bayramı dünyada tek. Mustafa Kemal Atatürk'e selam olsun.",
        upvoteCount: 480,
        downvoteCount: 5,
        isActive: true,
      ),
      EntryModel(
        profileImage: "https://randomuser.me/api/portraits/women/8.jpg",
        userName: "Eda Taş",
        entryDate: "10.10.2021 14:14",
        entryTitle: "En iyi tatil rotası",
        entryDescription:
            "Deniz mi dağ mı? Tatil planı yaparken siz hangisini tercih edersiniz?",
        upvoteCount: 333,
        downvoteCount: 10,
        isActive: true,
      ),
    ]);
  }

  void fetchPersonEntries() {
    entryPersonList.assignAll([
      EntryModel(
          profileImage: "https://randomuser.me/api/portraits/women/44.jpg",
          userName: "Alara Christie",
          entryDate: "26.12.2010 16:56",
          entryTitle: "Geziciler dostoyevski'yi isviçre peyniri sanıyor",
          entryDescription:
              "Oysa ki Dostoyevski; dünyaca ünlü Ukraynalı yazar Raskolnikov'un tercih ettiği bir çeşit salamura zeytindir.",
          upvoteCount: 345,
          downvoteCount: 345,
          isActive: false),
      EntryModel(
          profileImage: "https://randomuser.me/api/portraits/women/44.jpg",
          userName: "Alara Christie",
          entryDate: "05.08.2015 12:30",
          entryTitle: "Kitap okumak neden önemli?",
          entryDescription:
              "Bilgi edinmek ve hayal gücünü geliştirmek için kitap okumak büyük önem taşır.",
          upvoteCount: 198,
          downvoteCount: 45,
          isActive: true),
    ]);
  }

  void upvotePersonEntry(int index) {
    entryPersonList[index].upvoteCount++;
    entryPersonList.refresh();
  }

  void downvotePersonEntry(int index) {
    entryPersonList[index].downvoteCount++;
    entryPersonList.refresh();
  }

  void upvoteEntry(int index) {
    entryList[index].upvoteCount++;
    entryList.refresh();
  }

  void downvoteEntry(int index) {
    entryList[index].downvoteCount++;
    entryList.refresh();
  }
}
