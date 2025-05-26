import 'package:edusocial/screens/home/story/story_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../components/cards/story_card.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/story_controller.dart';

class MyStoryList extends StatefulWidget {
  const MyStoryList({super.key});

  @override
  State<MyStoryList> createState() => _MyStoryListState();
}

class _MyStoryListState extends State<MyStoryList> {
  final StoryController storyController = Get.find<StoryController>();
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final myStory = storyController.getMyStory();
      if (myStory != null && myStory.storyUrls.isEmpty) {
        storyController.loadMyStoryFromServer(profileController.userId.value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Story listesinde varsa, kullan
      final myStory = storyController.getMyStory();

      // Yoksa, profil bilgilerinden oluştur
      if (myStory != null && myStory.hasStory) {
        return StoryCard(story: myStory);
      }

      // Boşsa ve kendi hikayesi yoksa gösterilecek widget
      return GestureDetector(
        onTap: () async {
          await storyController
              .loadMyStoryFromServer(profileController.userId.value);

          final myIndex =
              storyController.storyList.indexWhere((e) => e.isMyStory);
          if (myIndex != -1) {
            Get.to(() => StoryViewerPage(initialIndex: myIndex));
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      image: (profileController.profileImage.value.isNotEmpty &&
                              profileController.profileImage.value
                                  .startsWith("http"))
                          ? DecorationImage(
                              image: NetworkImage(
                                  profileController.profileImage.value),
                              fit: BoxFit.cover,
                              onError: (error, stackTrace) {
                                debugPrint("⚠️ Görsel yüklenemedi: $error");
                              },
                            )
                          : null, // görsel geçersizse sadece gri daire göster
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        Get.toNamed('/addStory');
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_circle_rounded,
                            size: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                profileController.username.value.isNotEmpty
                    ? profileController.username.value
                    : "@sen",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      );
    });
  }
}
