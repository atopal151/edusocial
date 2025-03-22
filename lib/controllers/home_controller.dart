import 'package:get/get.dart';
import 'story_controller.dart';

class HomeController extends GetxController {
  late StoryController storyController;

  @override
  void onInit() {
    super.onInit();
    storyController = Get.put(StoryController());
  }
}
