import 'package:get/get.dart';
import '../controllers/search_text_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchTextController>(() => SearchTextController());
  }
}
