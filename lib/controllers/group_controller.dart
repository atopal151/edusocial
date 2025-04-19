// group_controller.dart
import 'package:edusocial/models/group_detail_model.dart';
import 'package:edusocial/models/grup_suggestion_model.dart';
import 'package:get/get.dart';
import '../models/document_model.dart';
import '../models/event_model.dart';
import '../models/group_model.dart';
import '../models/link_model.dart';
import '../services/group_service.dart';

class GroupController extends GetxController {
  var userGroups = <GroupModel>[].obs;
  var allGroups = <GroupModel>[].obs;
  var suggestionGroups = <GroupSuggestionModel>[].obs;
  var isLoading = false.obs;
  var selectedCategory = "Kimya".obs;
  var groupDetail = Rxn<GroupDetailModel>();
  var filteredGroups = <GroupModel>[].obs;

  var categories = ["Kimya", "Fizik", "Teknoloji", "Eğitim"].obs;

  final GroupServices _groupServices = GroupServices();

  @override
  void onInit() {
    super.onInit();
    fetchUserGroups();
    fetchAllGroups();
    fetchSuggestionGroups();
    loadMockGroupData(); // backend yerine simule veri
    ever(selectedCategory, (_) => updateFilteredGroups());
  }

  void loadMockGroupData() {
    groupDetail.value = GroupDetailModel(
      id: "group_001",
      name: "Murata Hayranlar Grubu",
      description:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      imageUrl: "https://randomuser.me/api/portraits/men/9.jpg",
      coverImageUrl: "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1", // örnek kapak
      memberImageUrls: [
        "https://randomuser.me/api/portraits/men/1.jpg",
        "https://randomuser.me/api/portraits/men/2.jpg",
        "https://randomuser.me/api/portraits/men/3.jpg",
        "https://randomuser.me/api/portraits/men/4.jpg",
        "https://randomuser.me/api/portraits/men/5.jpg",
        "https://randomuser.me/api/portraits/men/7.jpg",
        "https://randomuser.me/api/portraits/men/6.jpg",
        "https://randomuser.me/api/portraits/men/2.jpg",
        "https://randomuser.me/api/portraits/men/8.jpg",
        "https://randomuser.me/api/portraits/men/9.jpg",
        "https://randomuser.me/api/portraits/men/10.jpg",
        "https://randomuser.me/api/portraits/men/13.jpg",
      ],
      memberCount: 14040,
      createdAt: DateTime(2025, 1, 27),
      documents: [
        DocumentModel(
          name: "Edusocial.png",
          sizeMb: 3.72,
          date: DateTime(2025, 1, 27),
          url: "https://randomuser.me/api/portraits/men/4.jpg",
        ),
        DocumentModel(
          name: "Edusocial.png",
          sizeMb: 3.72,
          date: DateTime(2025, 1, 27),
          url: "https://randomuser.me/api/portraits/men/4.jpg",
        ),
        DocumentModel(
          name: "Edusocial.png",
          sizeMb: 3.72,
          date: DateTime(2025, 1, 27),
          url: "https://randomuser.me/api/portraits/men/4.jpg",
        ),
        DocumentModel(
          name: "Edusocial.png",
          sizeMb: 3.72,
          date: DateTime(2025, 1, 27),
          url: "https://randomuser.me/api/portraits/men/4.jpg",
        ),
        DocumentModel(
          name: "Edusocial.png",
          sizeMb: 3.72,
          date: DateTime(2025, 1, 27),
          url: "https://randomuser.me/api/portraits/men/4.jpg",
        ),
        DocumentModel(
          name: "Edusocial.png",
          sizeMb: 3.72,
          date: DateTime(2025, 1, 27),
          url: "https://randomuser.me/api/portraits/men/4.jpg",
        ),
      ],
      links: [
        LinkModel(
          title: "github.com",
          url: "https://github.com/monegonllc",
        ),
        LinkModel(
          title: "github.com",
          url: "https://github.com/monegonllc",
        ),
        LinkModel(
          title: "github.com",
          url: "https://github.com/monegonllc",
        ),
        LinkModel(
          title: "github.com",
          url: "https://github.com/monegonllc",
        ),
        LinkModel(
          title: "github.com",
          url: "https://github.com/monegonllc",
        ),
        LinkModel(
          title: "github.com",
          url: "https://github.com/monegonllc",
        ),
      ],
      photoUrls: [
        "https://randomuser.me/api/portraits/men/1.jpg",
        "https://randomuser.me/api/portraits/men/2.jpg",
        "https://randomuser.me/api/portraits/men/3.jpg",
        "https://randomuser.me/api/portraits/men/4.jpg",
        "https://randomuser.me/api/portraits/men/5.jpg",
        "https://randomuser.me/api/portraits/men/6.jpg",
        "https://randomuser.me/api/portraits/men/7.jpg",
        "https://randomuser.me/api/portraits/men/8.jpg",
        "https://randomuser.me/api/portraits/men/9.jpg",
        "https://randomuser.me/api/portraits/men/10.jpg",
        "https://randomuser.me/api/portraits/men/11.jpg",
        "https://randomuser.me/api/portraits/men/12.jpg",
        "https://randomuser.me/api/portraits/men/13.jpg",
        "https://randomuser.me/api/portraits/men/14.jpg",
      ],
      events: [
        EventModel(
          title: "Yapay Zeka Sohbetleri",
          description:
              "AI teknolojileri üzerine güncel gelişmeler konuşulacak.",
          date: "28 Mart 2025",
          location: "Denizli",
          image:
              "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        ),
        EventModel(
          title: "Flutter Atölyesi",
          description: "Flutter ile mobil uygulama geliştirmeye giriş.",
          date: "30 Mart 2025",
          location: "Denizli",
          image:
              "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        ),
        EventModel(
          title: "Networking Buluşması",
          description: "Sektör profesyonelleriyle tanışma ve sohbet fırsatı.",
          date: "2 Nisan 2025",
          location: "Denizli",
          image:
              "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        ),
        EventModel(
          title: "Hackathon 2025",
          description:
              "48 saat sürecek yazılım geliştirme yarışmasına hazır olun!",
          date: "5 Nisan 2025",
          location: "Denizli",
          image:
              "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        ),
      ],
    );
  }

  void fetchUserGroups() async {
    isLoading.value = true;
    userGroups.value = await _groupServices.fetchUserGroups();
    isLoading.value = false;
  }

  void fetchSuggestionGroups() async {
    isLoading.value = true;
    suggestionGroups.value = await _groupServices.fetchSuggestionGroups();
    isLoading.value = false;
  }

  void fetchAllGroups() async {
    isLoading.value = true;
    allGroups.value = await _groupServices.fetchAllGroups();
    updateFilteredGroups(); // ✅ burada tetikleniyor
    isLoading.value = false;
  }

  void getGrupDetail() {
    Get.toNamed("/group_detail_screen");
  }

  void getToGroupChatDetail() {
    Get.toNamed("/group_chat_detail");
  }

  void updateFilteredGroups() {
    filteredGroups.value = allGroups
        .where((group) => group.category == selectedCategory.value)
        .toList();
  }

  void joinGroup(String id) {
    final index = allGroups.indexWhere((group) => group.id == id);
    if (index != -1) {
      allGroups[index] = allGroups[index].copyWith(isJoined: true);
      Get.snackbar(
          "Katılım Başarılı", "${allGroups[index].name} grubuna katıldınız");
    }
  }
}
