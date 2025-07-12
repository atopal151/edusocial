import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/cards/group_card.dart';
import '../../components/onboarding_header/on_header.dart';
import '../../controllers/onboarding_controller.dart';
import '../../services/language_service.dart';

class Step3View extends StatelessWidget {
  const Step3View({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find();
    final LanguageService languageService = Get.find<LanguageService>();

    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            OnboardingHeader(
              imagePath: "images/icons/Vector.png",
              title: languageService.tr("step3.header.title"),
              subtitle: languageService.tr("step3.header.subtitle"),
            ),
            SizedBox(height: 30),
            Text(
              languageService.tr("step3.groupsSection.title"),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff272727)),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  children: controller.groups.map((group) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GroupCard(
                        action: group.isMember
                            ? languageService.tr("step3.groupActions.joined")
                            : (group.isPending ? languageService.tr("step3.groupActions.pending") : group.isPrivate ? languageService.tr("step3.groupActions.joinRequest"): languageService.tr("step3.groupActions.join")),
                        imageUrl: group.bannerUrl,
                        groupName: group.name,
                        groupDescription: group.description,
                        memberCount: group.userCountWithAdmin,
                        onJoinPressed: () {
                          controller.joinGroup(group.name);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 30),
            CustomButton(
              height: 50,
              borderRadius: 15,
              text: languageService.tr("step3.completeButton"),
              onPressed: controller.completeOnboarding,
              isLoading: controller.isLoading,
              backgroundColor: Color(0xFF414751),
              textColor: Colors.white,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
