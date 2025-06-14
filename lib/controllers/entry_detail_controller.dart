import 'package:get/get.dart';
import '../../models/entry_model.dart';
import '../../services/entry_services.dart';
import '../../models/topic_model.dart';
import 'package:flutter/foundation.dart';

class EntryDetailController extends GetxController {
  // Detay sayfasında gösterilecek topic
  var currentTopic = Rxn<TopicModel>();

  // Entry'ye yapılan yorumları tutan liste
  var entryComments = <EntryModel>[].obs;

  // Topic belirleme (detay sayfasına giderken atanır)
  void setCurrentTopic(TopicModel? topic) {
    currentTopic.value = topic;
  }

  Future<void> fetchEntryComments() async {
    debugPrint("🔄 EntryDetailController: Yorumlar çekiliyor...");
    if (currentTopic.value?.id != null) {
      final response = await EntryServices.fetchEntriesByTopicId(currentTopic.value!.id);
      debugPrint("📥 EntryDetailController: fetchEntriesByTopicId yanıtı: ${response?.topic?.name} - entries count: ${response?.entries.length}");
      if (response != null && response.entries.isNotEmpty) {
        // İlk entry ana entry, geri kalanlar yorumlar
        entryComments.value = response.entries.skip(1).toList();
        debugPrint("✅ EntryDetailController: Yorumlar güncellendi, yeni yorum sayısı: ${entryComments.length}");
      } else {
        debugPrint("⚠️ EntryDetailController: Yorum bulunamadı veya yanıt boş.");
        entryComments.clear(); // Eğer yorum yoksa listeyi temizle
      }
    } else {
      debugPrint("❌ EntryDetailController: currentTopic ID null, yorumlar çekilemedi.");
      entryComments.clear();
    }
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    // debugPrint("⚠️ EntryDetailController onClose: entryComments listesi temizleniyor.");
    // entryComments.clear(); // Temizleme işlemi artık widget'ın dispose metodunda yapılacak
    super.onClose();
  }
}
