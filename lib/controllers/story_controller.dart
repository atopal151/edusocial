import 'package:get/get.dart';
import '../models/story_model.dart';
import '../services/story_service.dart';

class StoryController extends GetxController {
  var storyList = <StoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStories();
  }

  void fetchStories() {
    storyList.value = StoryService.getMockStories();
  }
}
