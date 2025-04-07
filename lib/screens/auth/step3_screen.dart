import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/cards/group_card.dart';
import '../../components/onboarding_header/on_header.dart';
import '../../controllers/onboarding_controller.dart';

class Step3View extends StatelessWidget {
  const Step3View({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find();

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
              title: "Bilgilerinizi Tamamlayın",
              subtitle:
                  "Okulunu, bölümünü ve sınıfını ekleyerek platformu sana özel hale getir!",
            ),
            SizedBox(height: 30),
            Text(
              "Katılmak İsteyeceğin Gruplar",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff9CA3AE)),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.groups.map((group) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GroupCard(
                      action: group["action"]??"",
                      imageUrl: group["image"] ?? "",
                      groupName: group["name"] ?? "Bilinmeyen Grup",
                      groupDescription: group["description"] ?? "Açıklama yok",
                      memberCount: group["members"] ?? 0,
                      onJoinPressed: () {
                       /* print(
                            "Gruba katılma isteği gönderildi: ${group["name"]}");*/
                        controller.joinGroup(group["name"] ?? "");
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 30),
            CustomButton(

                        height: 50,
                        borderRadius: 15,
              text: "Hesabı Tamamla",
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
