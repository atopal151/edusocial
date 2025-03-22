import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
  }
}
