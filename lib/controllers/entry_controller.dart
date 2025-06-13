import 'package:edusocial/models/topic_model.dart';
import 'package:edusocial/services/entry_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/entry_model.dart';

class EntryController extends GetxController {
  var entryList = <EntryModel>[].obs;
  var entryPersonList = <EntryModel>[].obs;
  final RxList<EntryModel> filteredByCategoryList = <EntryModel>[].obs;
  final RxList<EntryModel> filteredEntries = <EntryModel>[].obs;
  var currentTopic = Rxn<TopicModel>();

  RxMap<String, int> categoryMap = <String, int>{}.obs; // 🔁 Kategori adı -> id
  RxList<String> categoryEntry = <String>[].obs; // UI'da gösterilecek kategori adları
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

  Future<void> fetchEntriesForSelectedCategory() async {
    final categoryName = selectedCategory.value;
    final categoryId = getCategoryIdFromName(categoryName);

    isEntryLoading.value = true;

    final response = await EntryServices.fetchEntriesByTopicId(categoryId);

    if (response != null) {
      currentTopic.value = response.topic; // currentTopic'i ana topic ile güncelle
      topicName.value = response.topic.name;

      final List<EntryModel> entriesWithTopic = response.entries.map((entry) {
        return entry.copyWith(topic: response.topic); // Her entry'ye ana topic bilgisini ata
      }).toList();

      entryList.value = entriesWithTopic;
      filteredByCategoryList.value = entriesWithTopic;
    } else {
      entryList.clear();
      filteredByCategoryList.clear();
      currentTopic.value = null; // Topic bilgisini temizle
      topicName.value = "";
    }

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

  // Vote Entry
  Future<void> voteEntry(int entryId, String vote) async {
    final success = await EntryServices.voteEntry(
      vote: vote,
      entryId: entryId,
    );

    if (success) {
      // Başarılı oylama sonrası entry listesini güncelle
      await fetchEntriesForSelectedCategory();
    } else {
      Get.snackbar("Hata", "Oylama işlemi başarısız oldu");
    }
  }

  // Send Entry To Topic
  Future<void> sendEntryToTopic(int topicId, String content) async {
    final success = await EntryServices.sendEntryToTopic(
      topicId: topicId,
      content: content,
    );

    if (success) {
      // Başarılı entry gönderimi sonrası listeyi güncelle
      await fetchEntriesForSelectedCategory();
      Get.back();
      Get.snackbar("Başarılı", "Entry başarıyla gönderildi");
    } else {
      Get.snackbar("Hata", "Entry gönderilemedi");
    }
  }

  // Fetch Topic Categories With Topics
  Future<void> fetchTopicCategoriesWithTopics() async {
    final data = await EntryServices.fetchTopicCategoriesWithTopics();
    // TODO: Implement topic categories with topics data handling
  }
}
