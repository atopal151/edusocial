import 'package:edusocial/services/story_service.dart';
import 'package:get/get.dart';

import '../models/story_model.dart';

class StoryController extends GetxController {
  final isLoading = false.obs;
  final RxList<StoryModel> storyList = <StoryModel>[].obs;

@override
  void onInit() {
    super.onInit();
    fetchStories();
  }
//----------------------------------------------------------------------------//
 void fetchStories() async {
  isLoading.value = true;
  final result = await StoryService.fetchStories();

  // Mevcut user için "MyStory" mock veya gerçek şekilde eklensin
  final myStory = StoryModel(
    id: "0",
    userId: "self",
    username: "Sen",
    profileImage: "",
    isMyStory: true,
    isViewed: false,
    storyUrls: [],
    createdAt: DateTime.now(),
    hasStory: false,
  );

  // önce varsa eski myStory’yi çıkar
  result.removeWhere((e) => e.isMyStory);

  // en başa ekle
  storyList.assignAll([myStory, ...result]);
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

  Future<void> loadMyStoryFromServer(String userId) async {
  final mediaList = await StoryService.fetchStoriesByUserId(userId);

  final myStory = getMyStory();
  if (myStory != null) {
    myStory.storyUrls = mediaList;
    myStory.hasStory = mediaList.isNotEmpty;
    myStory.createdAt = DateTime.now();
    storyList.refresh();
  }
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
