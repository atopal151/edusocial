import 'package:edusocial/components/user_appbar/user_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/cards/story_card.dart';
import '../../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.find();

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
        ],
      ),
    );
  }
}
