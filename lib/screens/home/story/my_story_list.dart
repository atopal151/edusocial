// my_story_list.dart
import 'package:edusocial/components/cards/user_story_card.dart';
import 'package:edusocial/screens/home/story/my_story_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/story_controller.dart';
import '../../../services/language_service.dart';

class MyStoryList extends StatelessWidget {
  final StoryController storyController = Get.find<StoryController>();
  final ProfileController profileController = Get.find<ProfileController>();

  MyStoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    return Obx(() {
      final myStory = storyController.myStory.value;

      if (myStory != null && myStory.hasStory) {
        return GestureDetector(
            onTap: () {
              final hasMyStory = storyController.getMyStory() != null;
              if (hasMyStory) {
                Get.to(() => const MyStoryViewerPage());
              } else {
                debugPrint("❗ My story yok, story viewer açılamaz");
              }
            },
            child: UserStoryCard(story: myStory));
      }

      return GestureDetector(
        onTap: () => Get.toNamed('/addStory'),
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
                      color: Color(0xfffafafa),
                      image: profileController.profileImage.value.isNotEmpty &&
                              profileController.profileImage.value
                                  .startsWith("http")
                          ? DecorationImage(
                              image: NetworkImage(
                                  profileController.profileImage.value),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Color(0xffffffff),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add_circle_rounded,
                          size: 18, color: Color(0xff272727)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Column(
                children: [
                  Text(
                    profileController.fullName.value.isNotEmpty 
                        ? profileController.fullName.value
                        : profileController.username.value.isNotEmpty
                            ? profileController.username.value
                            : languageService.tr("story.myStoryList.you"),
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff272727)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (profileController.fullName.value.isNotEmpty && profileController.username.value.isNotEmpty)
                    Text(
                      profileController.username.value,
                      style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff9ca3ae)),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
