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
    // Dummy örnek yorumlar
    entryComments.assignAll([
     EntryModel(
    profileImage: "https://randomuser.me/api/portraits/women/45.jpg",
    userName: "Elena Petrova",
    entryDate: "14.02.2021 10:12",
    entryTitle: "",
    entryDescription:
        "hayat; çoğu zaman beklemediğin anda karşına çıkan bir kahve kokusu gibidir.\ntanım: tesadüfen huzur.",
    upvoteCount: 213,
    downvoteCount: 23,
    isActive: true,
  ),
  EntryModel(
    profileImage: "https://randomuser.me/api/portraits/men/28.jpg",
    userName: "Markus Heine",
    entryDate: "03.03.2020 22:45",
    entryTitle: "",
    entryDescription:
        "güneşin batışı kadar yalnızdır bazı cümleler.\ntanım: söyleyemediklerin.",
    upvoteCount: 322,
    downvoteCount: 12,
    isActive: false,
  ),
  EntryModel(
    profileImage: "https://randomuser.me/api/portraits/women/12.jpg",
    userName: "Sofia Dimitrova",
    entryDate: "19.07.2019 08:33",
    entryTitle: "",
    entryDescription:
        "evrende yalnız olmadığımızı gösteren tek şey, bir başkasının sesini duyabilmek.\ntanım: radyo sinyali gibi dostluk.",
    upvoteCount: 98,
    downvoteCount: 8,
    isActive: true,
  ),
  EntryModel(
    profileImage: "https://randomuser.me/api/portraits/men/54.jpg",
    userName: "Carlos Mendez",
    entryDate: "01.01.2022 00:01",
    entryTitle: "",
    entryDescription:
        "yeni yılın ilk dakikası, eski yılın son hayal kırıklığını gömer.\ntanım: umudun resmi.",
    upvoteCount: 201,
    downvoteCount: 15,
    isActive: true,
  ),
  EntryModel(
    profileImage: "https://randomuser.me/api/portraits/women/64.jpg",
    userName: "Amelia Watson",
    entryDate: "08.08.2023 13:14",
    entryTitle: "",
    entryDescription:
        "kitapların tozunu yutmuş birinin gözlerindeki bilgelik, çoğu zaman kelimelerden fazlasını anlatır.\ntanım: yaşanmışlık.",
    upvoteCount: 456,
    downvoteCount: 22,
    isActive: false,
  ),
  EntryModel(
    profileImage: "https://randomuser.me/api/portraits/men/19.jpg",
    userName: "Kenji Tanaka",
    entryDate: "29.11.2021 17:50",
    entryTitle: "",
    entryDescription:
        "sessizlik, bazen en yüksek çığlıktır.\ntanım: kelimelerden arta kalan.",
    upvoteCount: 173,
    downvoteCount: 9,
    isActive: true,
  ),
  EntryModel(
    profileImage: "https://randomuser.me/api/portraits/women/38.jpg",
    userName: "Mira Yıldız",
    entryDate: "12.06.2022 21:00",
    entryTitle: "",
    entryDescription:
        "hayal etmek, düşmekten korkmayanların işidir.\ntanım: zihinsel cesaret.",
    upvoteCount: 289,
    downvoteCount: 11,
    isActive: false,
  ),
  EntryModel(
    profileImage: "https://randomuser.me/api/portraits/men/11.jpg",
    userName: "Tobias Keller",
    entryDate: "24.09.2020 06:34",
    entryTitle: "",
    entryDescription:
        "herkesin hayatında en az bir 'keşke' vardır, ama bazıları 'iyi ki' olur.\ntanım: pişmanlık ile umut arasında.",
    upvoteCount: 312,
    downvoteCount: 19,
    isActive: true,
  ),
  EntryModel(
    profileImage: "https://randomuser.me/api/portraits/women/22.jpg",
    userName: "Isabelle Fournier",
    entryDate: "15.05.2023 19:22",
    entryTitle: "",
    entryDescription:
        "bir yabancının gülümsemesi bazen en yakın arkadaşının sessizliğinden daha çok şey ifade eder.\ntanım: anlık bağ.",
    upvoteCount: 154,
    downvoteCount: 5,
    isActive: true,
  ),
  EntryModel(
    profileImage: "https://randomuser.me/api/portraits/men/42.jpg",
    userName: "Dimitri Ivanov",
    entryDate: "05.04.2024 11:11",
    entryTitle: "",
    entryDescription:
        "zaman; kaybedilince fark edilen en değerli hazinedir.\ntanım: geç kalma sanatı.",
    upvoteCount: 407,
    downvoteCount: 33,
    isActive: false,
  ),
    ]);
  }

  @override
  void onInit() {
    super.onInit();
    fetchEntryComments();
  }
}
