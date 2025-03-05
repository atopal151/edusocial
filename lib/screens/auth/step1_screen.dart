import 'package:edusocial/components/dropdowns/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/dialogs/warning_box.dart';
import '../../components/onboarding_header/on_header.dart';

class Step1View extends StatelessWidget {
  const Step1View({super.key});

  @override
  Widget build(BuildContext context) {
    final RxString selectedSchool = "Monnet International School".obs;
    final RxString selectedDepartment = "Computer Engineering".obs;
    final RxBool isLoading = false.obs;

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
              imagePath: "images/icons/Graduate.png",
              title: "Okul Bilgilerinizi Tamamlayın",
              subtitle: "Okulunu, bölümünü ve sınıfını ekleyerek platformu sana özel hale getir!",
            ),
            SizedBox(height: 30),
            CustomDropDown(
              label: "Okul",
              items: ["Monnet International School", "Another School"],
              selectedItem: selectedSchool.value,
              onChanged: (value) => selectedSchool.value = value!,
            ),
            SizedBox(height: 20),
            CustomDropDown(
              label: "Bölüm",
              items: ["Computer Engineering", "Mathematics", "Physics"],
              selectedItem: selectedDepartment.value,
              onChanged: (value) => selectedDepartment.value = value!,
            ),
            SizedBox(height: 20),
            WarningBox(message: "Üyeliğinizi doğru doldurmadığınız taktirde hesabınız kalıcı olarak kapatılabilir."),
            SizedBox(height: 30),
            CustomButton(
              text: "Devam Et",
              onPressed: () {
                isLoading.value = true;
                Future.delayed(Duration(seconds: 2), () {
                  isLoading.value = false;
                  Get.toNamed("/step2");
                });
              },
              isLoading: isLoading,
              backgroundColor: Color(0xFF414751),
            ),
          ],
        ),
      ),
    );
  }
}