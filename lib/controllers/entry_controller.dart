import 'package:edusocial/services/entry_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/entry_model.dart';

class EntryController extends GetxController {
  var entryList = <EntryModel>[].obs;
  var entryPersonList = <EntryModel>[].obs;
  final RxList<EntryModel> filteredByCategoryList = <EntryModel>[].obs;
  final RxList<EntryModel> filteredEntries = <EntryModel>[].obs;

  RxMap<String, int> categoryMap = <String, int>{}.obs; // 🔁 Kategori adı -> id
  RxList<String> categoryEntry = <String>[].obs; // UI’da gösterilecek kategori adları
  RxString selectedCategory = "".obs;

  var isEntryLoading = false.obs;
  final TextEditingController titleEntryController = TextEditingController();
  final TextEditingController bodyEntryController = TextEditingController();
final RxString topicName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTopicCategories(); // 🔁 Kategori listesini dinamik çek
      /// 🔁 Kategori değiştiğinde entry'leri otomatik getir
  ever(selectedCategory, (_) {
    fetchEntriesForSelectedCategory();
  });
  }

/// 🔄 Seçilen kategoriye ait entry'leri getir
Future<void> fetchEntriesForSelectedCategory() async {
  final categoryName = selectedCategory.value;
  final categoryId = getCategoryIdFromName(categoryName);

  isEntryLoading.value = true;

  final entries = await EntryServices.fetchEntriesByTopicId(categoryId);

  // 🔄 Hem genel hem filtrelenmiş listeye atama yap
  entryList.value = entries;
  filteredByCategoryList.value = entries;
  isEntryLoading.value = false;
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

  // 🐞 DEBUG: Kontrol için kategori adı ve ID yazdır
  debugPrint("🟡 Seçilen Kategori: $categoryName");
  debugPrint("🟡 Gönderilen topicCategoryId: $topicCategoryId");

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
  } else {
    Get.snackbar("Hata", "Konu oluşturulamadı");
  }
}

  /// Kategori adına göre ID döndür
  int getCategoryIdFromName(String name) {
    return categoryMap[name] ?? 1;
  }

  void shareEntry() {
    Get.toNamed("/entryShare");
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
