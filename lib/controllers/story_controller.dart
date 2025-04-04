import 'package:get/get.dart';

import '../models/story_model.dart';

class StoryController extends GetxController {
  final isLoading = false.obs;
  final RxList<StoryModel> storyList = <StoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStories(); // simülasyon
  }

  void fetchStories() {
    storyList.assignAll([
      StoryModel(
        id: '1',
        userId: 'myId',
        username: 'kale34',
        profileImage: 'https://randomuser.me/api/portraits/men/1.jpg',
        isMyStory: true,
        hasStory: false,
        storyUrls: [],
      ),
      StoryModel(
        id: '2',
        userId: '2',
        username: 'serht56',
        profileImage: 'https://randomuser.me/api/portraits/men/32.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: ['https://picsum.photos/200/300'],
      ),
      StoryModel(
        id: '3',
        userId: '3',
        username: 'kale34',
        profileImage: 'https://randomuser.me/api/portraits/women/5.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: ['https://picsum.photos/200/301'],
      ),StoryModel(
        id: '4',
        userId: '4',
        username: 'serht56',
        profileImage: 'https://randomuser.me/api/portraits/men/32.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: ['https://picsum.photos/200/300'],
      ),
      StoryModel(
        id: '5',
        userId: '5',
        username: 'kale34',
        profileImage: 'https://randomuser.me/api/portraits/women/5.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: ['https://picsum.photos/200/301'],
      ),StoryModel(
        id: '6',
        userId: '6',
        username: 'serht56',
        profileImage: 'https://randomuser.me/api/portraits/men/32.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: ['https://picsum.photos/200/300'],
      ),
      StoryModel(
        id: '7',
        userId: '7',
        username: 'kale34',
        profileImage: 'https://randomuser.me/api/portraits/women/5.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: ['https://picsum.photos/200/301'],
      ),
    ]);
  }

  StoryModel? getMyStory() {
    return storyList.firstWhereOrNull((story) => story.isMyStory);
  }

  List<StoryModel> getOtherStories() {
    return storyList.where((story) => !story.isMyStory).toList();
  }
}
