import 'package:get/get.dart';
import '../controllers/entry_detail_controller.dart';

class EntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EntryDetailController>(() => EntryDetailController());
  }
}
