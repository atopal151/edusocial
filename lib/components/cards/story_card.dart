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
    final ProfileController profileController=Get.find<ProfileController>();
    final StoryController storyController = Get.find<StoryController>();

    // Şu anki story'nin index'ini buluyoruz
    final index = storyController.getOtherStories().indexOf(story);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top:10.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: story.isViewed
                  ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade200])
                  : const LinearGradient(colors: [Color(0xfffb535c), Colors.orange]),
            ),
            child: InkWell(
              onTap: () {
                Get.to(() => StoryViewerPage(initialIndex: index));
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
          ),
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
