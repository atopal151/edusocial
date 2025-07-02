import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/dialogs/warning_box.dart';
import '../../components/input_fields/custom_textfield_step2.dart';
import '../../components/lists/custom_chip_list.dart';
import '../../components/onboarding_header/on_header.dart';
import '../../controllers/onboarding_controller.dart';
import '../../services/language_service.dart';

class Step2View extends StatelessWidget {
  const Step2View({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find();
    final LanguageService languageService = Get.find<LanguageService>();

    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                OnboardingHeader(
                  imagePath: "images/icons/Group.png",
                  title: languageService.tr("step2.header.title"),
                  subtitle: languageService.tr("step2.header.subtitle"),
                ),
                SizedBox(height: 30),
                Text(
                  languageService.tr("step2.form.courseQuestion"),
                  style: GoogleFonts.inter(
                      fontSize: 13.28,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff9CA3AE)),
                ),
                SizedBox(height: 10),
                CustomTextFieldStep2(
                  controller: controller.courseController,
                  onAdd: controller.addCourse,
                ),
                SizedBox(height: 20),
                Text(
                  languageService.tr("step2.form.savedCourses"),
                  style: GoogleFonts.inter(
                      fontSize: 13.28,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff9CA3AE)),
                ),
                SizedBox(height: 10),
                CustomChipList(
                  items: controller.courses,
                  onRemove: controller.removeCourse,
                  textColor: Color(0xff414751),
                  backgroundColor: Color(0xffFFFFFF),
                  iconColor: Color(0xffffffff),
                  iconbackColor: Color(0xff9CA3AE),
                ),
                SizedBox(height: 20),
                WarningBox(
                  message: languageService.tr("step2.warning"),
                ),
                SizedBox(height: 30),
                CustomButton(
                        height: 50,
                        borderRadius: 15,
                      text: languageService.tr("step2.continueButton"),
                      onPressed: controller.proceedToNextStep2,
                      isLoading: controller.isLoading,
                      backgroundColor: Color(0xFF414751),
                      textColor: Colors.white,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
