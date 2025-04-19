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
        userId: '1',
        username: 'kale34',
        profileImage: 'https://randomuser.me/api/portraits/men/1.jpg',
        isMyStory: true,
        hasStory: false,
        storyUrls: [],
        createdAt: DateTime.now().subtract(Duration(hours: 12)),
      ),
      StoryModel(
        id: '2',
        userId: '2',
        username: 'serht56',
        profileImage: 'https://randomuser.me/api/portraits/men/2.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: [
          'https://picsum.photos/200/300',
          'https://picsum.photos/200/301',
          'https://picsum.photos/200/302',
        ],
        createdAt: DateTime.now().subtract(Duration(hours: 20)),
      ),
      StoryModel(
        id: '3',
        userId: '3',
        username: 'zeynep87',
        profileImage: 'https://randomuser.me/api/portraits/women/3.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: ['https://picsum.photos/200/303'],
        createdAt: DateTime.now().subtract(Duration(hours: 23)),
      ),
      StoryModel(
        id: '4',
        userId: '4',
        username: 'mehmet23',
        profileImage: 'https://randomuser.me/api/portraits/men/4.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: [
          'https://picsum.photos/200/304',
          'https://picsum.photos/200/305',
        ],
        createdAt: DateTime.now().subtract(Duration(hours: 4)),
      ),
      StoryModel(
        id: '5',
        userId: '5',
        username: 'elifk98',
        profileImage: 'https://randomuser.me/api/portraits/women/5.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: ['https://picsum.photos/200/306'],
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
      ),
      StoryModel(
        id: '6',
        userId: '6',
        username: 'berkinn',
        profileImage: 'https://randomuser.me/api/portraits/men/6.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: [
          'https://picsum.photos/200/307',
          'https://picsum.photos/200/308',
          'https://picsum.photos/200/309',
        ],
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
      ),
      StoryModel(
        id: '7',
        userId: '7',
        username: 'selin34',
        profileImage: 'https://randomuser.me/api/portraits/women/7.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: ['https://picsum.photos/200/310'],
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
      ),
      StoryModel(
        id: '8',
        userId: '8',
        username: 'canan56',
        profileImage: 'https://randomuser.me/api/portraits/women/8.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: ['https://picsum.photos/200/311'],
        createdAt: DateTime.now().subtract(Duration(hours: 31)),
      ),
      StoryModel(
        id: '9',
        userId: '9',
        username: 'ahmet44',
        profileImage: 'https://randomuser.me/api/portraits/men/9.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: ['https://picsum.photos/200/312'],
        createdAt: DateTime.now().subtract(Duration(hours: 35)),
      ),
      StoryModel(
        id: '10',
        userId: '10',
        username: 'aysegul01',
        profileImage: 'https://randomuser.me/api/portraits/women/10.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: [
          'https://picsum.photos/200/313',
          'https://picsum.photos/200/314',
        ],
        createdAt: DateTime.now().subtract(Duration(hours: 333)),
      ),
      StoryModel(
        id: '11',
        userId: '11',
        username: 'oguzhan',
        profileImage: 'https://randomuser.me/api/portraits/men/11.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: ['https://picsum.photos/200/315'],
        createdAt: DateTime.now().subtract(Duration(hours: 32)),
      ),
      StoryModel(
        id: '12',
        userId: '12',
        username: 'melisa23',
        profileImage: 'https://randomuser.me/api/portraits/women/12.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: ['https://picsum.photos/200/316'],
        createdAt: DateTime.now().subtract(Duration(hours: 30)),
      ),
      StoryModel(
        id: '13',
        userId: '13',
        username: 'furkan67',
        profileImage: 'https://randomuser.me/api/portraits/men/13.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: [
          'https://picsum.photos/200/317',
          'https://picsum.photos/200/318',
        ],
        createdAt: DateTime.now().subtract(Duration(hours: 103)),
      ),
      StoryModel(
        id: '14',
        userId: '14',
        username: 'esra_d',
        profileImage: 'https://randomuser.me/api/portraits/women/14.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: ['https://picsum.photos/200/319'],
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
      ),
      StoryModel(
        id: '15',
        userId: '15',
        username: 'emre_m',
        profileImage: 'https://randomuser.me/api/portraits/men/15.jpg',
        isMyStory: false,
        hasStory: true,
        storyUrls: [
          'https://picsum.photos/200/320',
          'https://picsum.photos/200/321',
          'https://picsum.photos/200/322',
        ],
        createdAt: DateTime.now().subtract(Duration(hours: 13)),
      ),
    ]);
  }
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


  StoryModel? getMyStory() {
    return storyList.firstWhereOrNull((story) => story.isMyStory);
  }

  List<StoryModel> getOtherStories() {
    return storyList.where((story) => !story.isMyStory).toList();
  }
}
