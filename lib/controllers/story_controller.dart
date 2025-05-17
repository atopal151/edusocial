import 'package:edusocial/services/story_service.dart';
import 'package:get/get.dart';

import '../models/story_model.dart';

class StoryController extends GetxController {
  final isLoading = false.obs;
  final RxList<StoryModel> storyList = <StoryModel>[].obs;


//----------------------------------------------------------------------------//
  Future<void> fetchStories() async {
    isLoading.value = true;
    final result = await StoryService.fetchStories();
    storyList.assignAll(result);
    isLoading.value = false;
  }

//----------------------------------------------------------------------------//
  void updateMyStory(List<String> imagePaths) {
    final myStory = getMyStory();
    if (myStory != null) {
      myStory.storyUrls = imagePaths;
      myStory.hasStory = true;
      myStory.createdAt = DateTime.now();

      // listeyi tetiklemek için yeniden ata
      storyList.refresh();
    }
  }
//----------------------------------------------------------------------------//

  StoryModel? getMyStory() {
    return storyList.firstWhereOrNull((story) => story.isMyStory);
  }

//----------------------------------------------------------------------------//
  List<StoryModel> getOtherStories() {
    return storyList.where((story) => !story.isMyStory).toList();
  }
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
}
