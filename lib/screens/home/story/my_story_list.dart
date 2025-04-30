import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/cards/story_card.dart';
import '../../../controllers/story_controller.dart';

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

      if (myStory.hasStory) {
        // Story mevcutsa diğerleri gibi göster
        return StoryCard(story: myStory);
      } else {
        // Story yoksa paylaşım arayüzü
        return GestureDetector(
          onTap: () {
            Get.toNamed('/addStory'); // paylaşım sayfasına yönlendirme
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
                        image: DecorationImage(
                          image: NetworkImage(myStory.profileImage),
                          fit: BoxFit.cover,
                        ),
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
                        child: Icon(Icons.add_circle_rounded,
                            size: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('@${myStory.username}', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      }
    });
  }
}
