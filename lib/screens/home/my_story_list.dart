import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/story_controller.dart';

class MyStoryList extends StatefulWidget {
  const MyStoryList({super.key});

  @override
  State<MyStoryList> createState() => _MyStoryListState();
}

class _MyStoryListState extends State<MyStoryList> {
  final StoryController storyController = Get.find<StoryController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final myStory = storyController.getMyStory();
      if (myStory == null) return SizedBox.shrink();

      return GestureDetector(
        onTap: () {
          if (myStory.hasStory) {
            Get.toNamed("/myStoryDetail", arguments: myStory);
          } else {
            // Yeni story paylaş
           // print("Yeni story ekle");
          }
        },
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: myStory.hasStory
                        ? const LinearGradient(
                            colors: [
                              Color(0xfffb535c),
                              Color.fromARGB(255, 211, 156, 55)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Color(0xffd3d2d2), Color(0xffd3d2d2)],
                          ),
                    image: DecorationImage(
                      image: NetworkImage(myStory.profileImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (!myStory.hasStory)
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
                      child: Icon(Icons.add_circle_rounded, size: 18, color: Colors.black),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '@${myStory.username}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    });
  }
}
