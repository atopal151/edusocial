import 'package:edusocial/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/story_controller.dart';
import '../../models/story_model.dart';
import '../../screens/home/story/story_viewer_page.dart';

class StoryCard extends StatelessWidget {
  final StoryModel story;

  const StoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final StoryController storyController = Get.find<StoryController>();


    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Obx(() {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: story.isViewed.value
                    ? LinearGradient(
                        colors: [Colors.grey.shade400, Colors.grey.shade200])
                    : const LinearGradient(
                        colors: [Color(0xfffb535c), Color(0xfffb535c)]),
              ),
              child: InkWell(
                onTap: () {
                  final index = storyController.getMyStory() != null
                      ? storyController.getOtherStories().indexOf(story) +
                          1 // myStory varsa offset +1
                      : storyController.getOtherStories().indexOf(story);

                  Get.to(() => StoryViewerPage(initialIndex: index));

                  story.isViewed.value = true; // izlenmiş olarak işaretle
                },
                onLongPress: () {
                  profileController.getToPeopleProfileScreen();
                },
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(story.profileImage),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          story.username,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }
}
