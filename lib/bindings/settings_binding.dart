import 'package:get/get.dart';
import '../controllers/profile_update_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileUpdateController>(() => ProfileUpdateController());
  }
}
