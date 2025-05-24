import 'package:edusocial/services/entry_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/entry_model.dart';

class EntryController extends GetxController {
  var entryList = <EntryModel>[].obs;
  var entryPersonList = <EntryModel>[].obs;

  RxMap<String, int> categoryMap = <String, int>{}.obs; // 🔁 Kategori adı -> id
  RxList<String> categoryEntry =
      <String>[].obs; // UI’da gösterilecek kategori adları
  RxString selectedCategory = "".obs;

  var isEntryLoading = false.obs;
  final TextEditingController titleEntryController = TextEditingController();
  final TextEditingController bodyEntryController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchTopicCategories(); // 🔁 Kategori listesini dinamik çek
    fetchEntries();
  }

  /// 🔁 Backend'den kategori listesini al
  void fetchTopicCategories() async {
    final data = await EntryServices.fetchTopicCategories();
    categoryMap.value = data;
    categoryEntry.value = data.keys.toList();
    if (categoryEntry.isNotEmpty) {
      selectedCategory.value = categoryEntry.first;
    }
  }

  /// 📤 Entry oluştur
  void shareEntryPost() async {
    final title = titleEntryController.text.trim();
    final body = bodyEntryController.text.trim();
    final categoryName = selectedCategory.value;

    if (title.isEmpty || body.isEmpty || categoryName.isEmpty) {
      Get.snackbar("Eksik Bilgi", "Lütfen tüm alanları doldurun");
      return;
    }

    isEntryLoading.value = true;

    final topicCategoryId = getCategoryIdFromName(categoryName);

    final success = await EntryServices.createTopicWithEntry(
      name: title,
      content: body,
      topicCategoryId: topicCategoryId,
    );

    isEntryLoading.value = false;

    if (success) {
      Get.back();
      Get.snackbar("Başarılı", "Konu başarıyla oluşturuldu");
      titleEntryController.clear();
      bodyEntryController.clear();
      selectedCategory.value = "";
      fetchEntries(); // listeyi yenile
    } else {
      Get.snackbar("Hata", "Konu oluşturulamadı");
    }
  }

  /// 🔁 Kategori adı -> ID
  int getCategoryIdFromName(String name) {
    return categoryMap[name] ?? 1;
  }

  void shareEntry() {
    Get.toNamed("/entryShare");
  }

  /// 📥 Tüm entry'leri getir
  void fetchEntries() async {
    isEntryLoading.value = true;
    final entries = await EntryServices.fetchTimelineEntries();
    entryList.assignAll(entries);

    entryPersonList.assignAll(
      entries.where((entry) => entry.isOwner == true).toList(),
    ); // ✅ filtreleme

    isEntryLoading.value = false;
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
