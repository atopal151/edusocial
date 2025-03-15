import 'package:get/get.dart';

class NavigationController extends GetxController {
  RxInt selectedIndex = 0.obs;

  void changeIndex(int index) {
  selectedIndex.value = index;
  print("Navbar Index Değişti: $index"); // Terminalde kontrol et
}

}
