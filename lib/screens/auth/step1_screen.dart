import 'package:edusocial/components/dropdowns/custom_dropdown.dart';
import 'package:edusocial/components/widgets/general_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/dialogs/warning_box.dart';
import '../../components/onboarding_header/on_header.dart';
import '../../controllers/onboarding_controller.dart';
import '../../services/language_service.dart';

class Step1View extends StatelessWidget {
  const Step1View({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find();
    final LanguageService languageService = Get.find<LanguageService>();

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
                title: languageService.tr("step1.header.title"),
                subtitle: languageService.tr("step1.header.subtitle"),
              ),
              SizedBox(height: 30),
              Obx(() {
                if (controller.schools.isEmpty) {
                  return Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: GeneralLoadingIndicator(
                        size: 32,
                        showText: true,
                        showIcon: false,
                      ),
                    ),
                  );
                }
                return CustomDropDown(
                  label: languageService.tr("step1.form.school"),
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
                  return Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: GeneralLoadingIndicator(
                        size: 32,
                        showText: true,
                        showIcon: false,
                      ),
                    ),
                  );
                }
                return CustomDropDown(
                  label: languageService.tr("step1.form.department"),
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
                  message: languageService.tr("step1.warning")),
              SizedBox(height: 30),
              CustomButton(
                height: 50,
                borderRadius: 15,
                text: languageService.tr("step1.continueButton"),
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
