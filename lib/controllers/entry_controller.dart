import 'package:edusocial/services/entry_services.dart';
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

 void fetchEntries() async {
  isEntryLoading.value = true;

  final entries = await EntryServices.fetchTimelineEntries();
  entryList.assignAll(entries);

  isEntryLoading.value = false;
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
