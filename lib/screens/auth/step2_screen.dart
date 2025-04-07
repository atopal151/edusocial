import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/dialogs/warning_box.dart';
import '../../components/input_fields/custom_textfield_step2.dart';
import '../../components/lists/custom_chip_list.dart';
import '../../components/onboarding_header/on_header.dart';
import '../../controllers/onboarding_controller.dart';

class Step2View extends StatelessWidget {
  const Step2View({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find();

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
                SizedBox(height: 40),
                OnboardingHeader(
                  imagePath: "images/icons/Group.png",
                  title: "Bilgilerinizi Tamamlayın",
                  subtitle:
                      "Okulunu, bölümünü ve sınıfını ekleyerek platformu sana özel hale getir!",
                ),
                SizedBox(height: 30),
                Text(
                  "Hangi dersleri alıyorsun?",
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
                  "Kaydedilen Konular",
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
                  message:
                      "Üyeliğinizi doğru doldurmadığınız taktirde hesabınız kalıcı olarak kapatılabilir.",
                ),
                SizedBox(height: 30),
                CustomButton(

                        height: 50,
                        borderRadius: 15,
                      text: "Devam Et",
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
