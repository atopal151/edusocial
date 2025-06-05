import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/story_model.dart';
import '../../screens/home/story/story_viewer_page.dart';

class UserStoryCard extends StatelessWidget {
  final StoryModel? story; // nullable yaptık
  final bool isMe;

  const UserStoryCard({
    super.key,
    required this.story,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    // Eğer kullanıcıya ait story yoksa "Add Story" göster
    if (isMe) {
      return GestureDetector(
        onTap: () => Get.toNamed('/addStory'),
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
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_circle_rounded,
                        size: 18, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text("@sen", style: TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    // Aksi halde normal hikaye göster
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Obx(() {
            return InkWell(
              onLongPress: () {
                Get.toNamed('/addStory');
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: story!.isViewed.value
                      ? LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade200])
                      : const LinearGradient(
                          colors: [Color(0xfffb535c), Color(0xfffb535c)]),
                ),
                child: InkWell(
                  onTap: () {
                    Get.to(() => const StoryViewerPage(initialIndex: 0));
                    story!.isViewed.value = true;
                  },
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 30,
                    backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(story!.profileImage),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          story!.username,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }
}
