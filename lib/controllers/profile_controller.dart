import 'package:get/get.dart';

import '../models/profile_model.dart';
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

  // 📦 Takipçi listesi (Mock)
  var followerList = [
    {
      "username": "alihanmatrak",
      "fullName": "ALİ HAN MATRAK",
      "avatarUrl": "https://randomuser.me/api/portraits/men/10.jpg",
    },
    {
      "username": "srt_umt",
      "fullName": "Ümit SERT",
      "avatarUrl": "https://randomuser.me/api/portraits/men/12.jpg",
    },
    {
      "username": "ismailysr20",
      "fullName": "İsmail Yaşar",
      "avatarUrl": "https://randomuser.me/api/portraits/men/14.jpg",
    },
  ].obs;

  // 📦 Takip edilenler listesi (Mock)
  var followingList = [
    {
      "username": "srt_umt",
      "fullName": "Ümit SERT",
      "avatarUrl": "https://randomuser.me/api/portraits/men/12.jpg",
    },
    {
      "username": "earaz__",
      "fullName": "Erdal Araz",
      "avatarUrl": "https://randomuser.me/api/portraits/men/3.jpg",
    },
  ].obs;

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
