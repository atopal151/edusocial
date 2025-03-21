import 'package:get/get.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class ProfileController extends GetxController {
  // Mock Kullanıcı Verileri
  var isPrLoading = false.obs; // Yüklenme durumu

  var profileImage = "https://s3-alpha-sig.figma.com/img/dc70/0f17/713d27d0670d7fac7b38e16f1ee729e9?Expires=1743379200&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=isoX01p8SckOVZfBpkmDgdXerAjyGElyrscVuDJgWo9pI44dGSLcm8KOYO09nzTKOVdSFxMg2QDTiNOIcE7pppxThauWu9MP4TDn-JsH0xIiVqIlJw4hRCA4Cm0yFfFMN39s1ptmdPg67hfHYVrhagmE5on~rzVloptMQ~KmewLQl84AJVyil8Bl2HhY-n-0IqgPezHySkF~2ArIphM6ifJE5wH1iGN~Ej0arY6XXOjZsMGLBE1t2QSWVQw9ez7sWtbCPFw3kBtSY0hTmm-ZuF8PK3hRXy02Lo9e8g-WTFDg4t~0z2tO1AhIsyWhfjAkrYeo22zmoWstCP9zxx~m6w__".obs;
  var fullName = "Canan Kara".obs;
  var bio = "Lise buluşması için etkinlik yapıyoruz katılmak isteyen tüm arkadaşları bu güzel etkinliğe bekliyoruz..".obs;

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

  void getToSettingScreen () async {
    Get.toNamed("/settings");
  }
  void updateProfile(String name, String newBio) {
    fullName.value = name;
    bio.value = newBio;
  }
}
