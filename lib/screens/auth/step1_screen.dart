import 'package:edusocial/components/dropdowns/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/dialogs/warning_box.dart';
import '../../components/onboarding_header/on_header.dart';
import '../../controllers/onboarding_controller.dart';

class Step1View extends StatelessWidget {
  const Step1View({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find();

    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              OnboardingHeader(
                imagePath: "images/icons/Graduate.png",
                title: "Okul Bilgilerinizi Tamamlayın",
                subtitle:
                    "Okulunu, bölümünü ve sınıfını ekleyerek platformu sana özel hale getir!",
              ),
              SizedBox(height: 30),
              Obx(() {
                if (controller.schools.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                return CustomDropDown(
                  label: "Okul",
                  items: controller.schools
                      .map((e) => e['name'].toString())
                      .toList(),
                  selectedItem: controller.selectedSchool.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.onSchoolChanged(value);
                    }
                  },
                );
              }),
              SizedBox(height: 20),
              Obx(() {
                if (controller.departments.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                return CustomDropDown(
                  label: "Bölüm",
                  items: controller.departments
                      .map((e) => e['title'].toString())
                      .toList(),
                  selectedItem: controller.selectedDepartment.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.onDepartmentChanged(value);
                    }
                  },
                );
              }),
              SizedBox(height: 20),
              WarningBox(
                  message:
                      "Üyeliğinizi doğru doldurmadığınız taktirde hesabınız kalıcı olarak kapatılabilir."),
              SizedBox(height: 30),
              CustomButton(
                height: 50,
                borderRadius: 15,
                text: "Devam Et",
                onPressed: controller.proceedToNextStep,
                isLoading: controller.isLoading,
                backgroundColor: Color(0xFF414751),
                textColor: Color(0xffffffff),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
