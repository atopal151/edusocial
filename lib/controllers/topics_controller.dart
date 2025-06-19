import 'package:get/get.dart';
import '../models/hot_topics_model.dart';
import '../services/hot_topics_service.dart';
import '../models/entry_model.dart';
import '../services/entry_services.dart';
import 'package:flutter/foundation.dart';

class TopicsController extends GetxController {
  var isLoading = false.obs;
  var hotTopics = <HotTopicsModel>[].obs;

  final HotTopicsService _service = HotTopicsService();

  var selectedTopic = ''.obs;

  void selectTopic(String topic) {
    selectedTopic.value = topic;
    // filtreleme, içerik çağırma vs. işlemler buraya eklenebilir
  }

  // Hot topic'e tıklandığında entry detay sayfasına yönlendir
  void onHotTopicTap(HotTopicsModel topic) async {
    debugPrint("🔥 Hot topic tıklandı: ${topic.title} (ID: ${topic.id})");
    try {
      // Topic ID'si ile ilgili entry'yi bul
      final entry = await _findEntryForTopic(topic.id);
      if (entry != null) {
        debugPrint("✅ Entry bulundu, detay sayfasına yönlendiriliyor...");
        debugPrint("📝 Entry ID: ${entry.id}");
        debugPrint("📝 Entry Topic: ${entry.topic?.name}");
        debugPrint("📝 Entry Topic Category: ${entry.topic?.category?.title}");
        // Entry detay sayfasına yönlendir
        Get.toNamed("/entryDetail", arguments: {'entry': entry});
      } else {
        debugPrint("❌ Entry bulunamadı");
        Get.snackbar("Hata", "Bu konu için entry bulunamadı");
      }
    } catch (e) {
      debugPrint("❌ Hata oluştu: $e");
      Get.snackbar("Hata", "Bir hata oluştu");
    }
  }

  // Topic ID'si ile ilgili entry'yi bul ve topic bilgisini enjekte et
  Future<EntryModel?> _findEntryForTopic(int topicId) async {
    debugPrint("🔍 Topic ID $topicId için entry aranıyor...");
    try {
      final response = await EntryServices.fetchEntriesByTopicId(topicId);
      if (response != null && response.entries.isNotEmpty) {
        debugPrint("📦 API yanıtı alındı:");
        debugPrint("📦 Topic: ${response.topic.name}");
        debugPrint("📦 Topic Category: ${response.topic.category?.title}");
        debugPrint("📦 Entry sayısı: ${response.entries.length}");
        
        // İlk entry'yi al (ana entry)
        final firstEntry = response.entries.first;
        debugPrint("📝 İlk entry ID: ${firstEntry.id}");
        debugPrint("📝 İlk entry topic: ${firstEntry.topic?.name}");
        
        // Topic bilgisini entry'ye enjekte et
        final entryWithTopic = firstEntry.copyWith(
          topic: response.topic.copyWith(
            category: response.topic.category,
          ),
        );
        
        debugPrint("✅ Entry topic bilgisi enjekte edildi");
        debugPrint("✅ Final entry topic: ${entryWithTopic.topic?.name}");
        debugPrint("✅ Final entry category: ${entryWithTopic.topic?.category?.title}");
        
        return entryWithTopic;
      } else {
        debugPrint("⚠️ API yanıtı boş veya entry yok");
        return null;
      }
    } catch (e) {
      debugPrint("❌ _findEntryForTopic hatası: $e");
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchHotTopics();
  }

  void fetchHotTopics() async {
    isLoading.value = true;
    hotTopics.value = await _service.fetchHotTopics();
    isLoading.value = false;
  }
}
