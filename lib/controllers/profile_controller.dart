import 'package:get/get.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class ProfileController extends GetxController {
  // Mock Kullanıcı Verileri
  var isPrLoading = false.obs; // Yüklenme durumu

  var profileImage = "https://i.pravatar.cc/150?img=20".obs;
  var fullName = "Canan Kara".obs;
  var bio =
      "Lise buluşması için etkinlik yapıyoruz katılmak isteyen tüm arkadaşları bu güzel etkinliğe bekliyoruz.."
          .obs;

  var postCount = 352.obs;
  var followers = 2352.obs;
  var following = 532.obs;

  final ProfileService _profileService = ProfileService();

  Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      ProfileModel data = await _profileService.fetchProfileData();
      profile.value = data;
    } catch (e) {
      //print("Hata: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void getToSettingScreen() async {
    Get.toNamed("/settings");
  }

  void getToUserSettingScreen() async {
    Get.toNamed("/userSettings");
  }

void getToPeopleProfileScreen() async {
    Get.toNamed("/peopleProfile");
  }
  void updateProfile(String name, String newBio) {
    fullName.value = name;
    bio.value = newBio;
  }
}
