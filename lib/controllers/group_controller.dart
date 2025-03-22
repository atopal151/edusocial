
// group_controller.dart
import 'package:get/get.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';

class GroupController extends GetxController {
  var userGroups = <GroupModel>[].obs;
  var allGroups = <GroupModel>[].obs;
  var isLoading = false.obs;
  var selectedCategory = "Kimya".obs;

  var categories = ["Kimya", "Fizik", "Teknoloji", "Eğitim"].obs;

  final GroupServices _groupServices = GroupServices();

  @override
  void onInit() {
    super.onInit();
    fetchUserGroups();
    fetchAllGroups();
  }

  void fetchUserGroups() async {
    isLoading.value = true;
    userGroups.value = await _groupServices.fetchUserGroups();
    isLoading.value = false;
  }
  

  void fetchAllGroups() async {
    isLoading.value = true;
    allGroups.value = await _groupServices.fetchAllGroups();
    isLoading.value = false;
  }

  List<GroupModel> get filteredGroups => allGroups
      .where((group) => group.category == selectedCategory.value)
      .toList();

  void joinGroup(String id) {
    final index = allGroups.indexWhere((group) => group.id == id);
    if (index != -1) {
      allGroups[index] = allGroups[index].copyWith(isJoined: true);
      Get.snackbar("Katılım Başarılı", "${allGroups[index].name} grubuna katıldınız");
    }
  }
}
