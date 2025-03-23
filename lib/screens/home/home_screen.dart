import 'package:edusocial/components/user_appbar/user_appbar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/cards/story_card.dart';
import 'group_suggestion_list.dart';
import '../../controllers/group_controller.dart';
import '../../controllers/home_controller.dart';
import 'hot_topics_list.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.find();
  final GroupController groupController = Get.put(GroupController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: UserAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Story alanı
          SizedBox(
            height: 120,
            child: Obx(() {
              return Container(
                decoration: BoxDecoration(color: Color(0xffffffff)),
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 8, top: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.storyController.storyList.length,
                  itemBuilder: (context, index) {
                    return StoryCard(
                        story: controller.storyController.storyList[index]);
                  },
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.only(left:16.0,top: 12,bottom: 12),
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
            padding: const EdgeInsets.only(left:16.0,top: 12,bottom: 12),
            child: const Text(
              "Gündemdeki Konular",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff1F1F1F),
              ),
            ),
          ),
          HotTopicsListView()
        ],
      ),
    );
  }
}
