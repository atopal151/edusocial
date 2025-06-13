import 'package:get/get.dart';
import '../../models/entry_model.dart';
import '../../services/entry_services.dart';

class EntryDetailController extends GetxController {
  // Detay sayfasında gösterilecek entry (başlık bilgisi vs.)
  EntryModel? selectedEntry;

  // Entry'ye yapılan yorumları tutan liste
  var entryComments = <EntryModel>[].obs;

  // Entry belirleme (detay sayfasına giderken atanır)
  void setSelectedEntry(EntryModel entry) {
    selectedEntry = entry;
    fetchEntryComments(); // Entry set edildiğinde yorumları çek
  }

  Future<void> fetchEntryComments() async {
    if (selectedEntry?.topic?.id != null) {
      final response = await EntryServices.fetchEntriesByTopicId(selectedEntry!.topic!.id);
      if (response != null && response.entries.isNotEmpty) {
        // İlk entry ana entry, geri kalanlar yorumlar
        entryComments.value = response.entries.skip(1).toList();
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
  }
}
