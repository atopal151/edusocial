import 'package:edusocial/components/user_appbar/user_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/cards/story_card.dart';
import '../../controllers/story_controller.dart';
import 'group_suggestion_list.dart';
import '../../controllers/group_controller/group_controller.dart';
import '../../controllers/home_controller.dart';
import 'hot_topics_list.dart';
import 'story/my_story_list.dart';
import 'post_home_list.dart';
import 'story/story_viewer_page.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.find();
  final GroupController groupController = Get.find();
  final StoryController storyController = Get.find();
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: UserAppBar(),
      floatingActionButton: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFEF5050), Color(0xFFFF7743)],
            begin: Alignment.bottomCenter,
            end: Alignment.topRight,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () {
            Get.toNamed("/create_post");
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  InkWell(
                      onTap: () {
                        final myIndex = storyController.storyList
                            .indexWhere((e) => e.isMyStory);
                        if (myIndex != -1) {
                          Get.to(() => StoryViewerPage(initialIndex: myIndex));
                        }
                      },
                      child: MyStoryList()), // İlk eleman: kendi story
                  SizedBox(width: 5),
                  ...storyController
                      .getOtherStories()
                      .map((story) => StoryCard(story: story)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 12),
              child: const Text(
                "İlgini Çekebilecek Gruplar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1F1F1F),
                ),
              ),
            ),
            GroupSuggestionListView(),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 12),
              child: const Text(
                "Gündemdeki Konular",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1F1F1F),
                ),
              ),
            ),
            HotTopicsListView(),
            PostHomeList(),
          ],
        ),
      ),
    );
  }
}
