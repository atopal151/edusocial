import 'package:get/get.dart';
import '../../models/entry_model.dart';

class EntryDetailController extends GetxController {
  // Detay sayfasında gösterilecek entry (başlık bilgisi vs.)
  late EntryModel selectedEntry;

  // Entry'ye yapılan yorumları tutan liste
  var entryComments = <EntryModel>[].obs;

  // Entry belirleme (detay sayfasına giderken atanır)
  void setSelectedEntry(EntryModel entry) {
    selectedEntry = entry;
  }

  void fetchEntryComments() {
    
  }

  @override
  void onInit() {
    super.onInit();
    fetchEntryComments();
  }
}
