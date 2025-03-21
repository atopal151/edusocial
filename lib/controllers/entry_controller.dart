import 'package:get/get.dart';
import '../models/entry_model.dart';

class EntryController extends GetxController {
  var entryList = <EntryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEntries();
  }

  void fetchEntries() {
    entryList.assignAll([
      EntryModel(
        profileImage: "https://randomuser.me/api/portraits/men/32.jpg",
        userName: "Alexander Rybak",
        entryDate: "26.12.2010 16:56",
        entryTitle: "Geziciler dostoyevski'yi isviçre peyniri sanıyor",
        entryDescription:
            "Oysa ki Dostoyevski; dünyaca ünlü Ukraynalı yazar Raskolnikov'un tercih ettiği bir çeşit salamura zeytindir.",
        upvoteCount: 345,
        downvoteCount: 345,
        isActive: false
      ),
      EntryModel(
        profileImage: "https://randomuser.me/api/portraits/women/45.jpg",
        userName: "Emily Johnson",
        entryDate: "05.08.2015 12:30",
        entryTitle: "Kitap okumak neden önemli?",
        entryDescription:
            "Bilgi edinmek ve hayal gücünü geliştirmek için kitap okumak büyük önem taşır.",
        upvoteCount: 198,
        downvoteCount: 45,
        isActive: true
      ),
    ]);
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
