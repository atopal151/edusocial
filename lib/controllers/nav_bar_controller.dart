import 'package:get/get.dart';
import 'package:edusocial/controllers/match_controller.dart';
import 'package:flutter/foundation.dart';

class NavigationController extends GetxController {
  RxInt selectedIndex = 0.obs;
  late MatchController matchController;

  @override
  void onInit() {
    super.onInit();
    matchController = Get.find<MatchController>();
  }

  void changeIndex(int index) {
    debugPrint('🔄 NavigationController: Changing index from ${selectedIndex.value} to $index');
    selectedIndex.value = index;
    
    // Match tab'i seçildiğinde eşleşmeleri getir
    if (index == 2) {
      matchController.findMatches();
    }
  }
}
