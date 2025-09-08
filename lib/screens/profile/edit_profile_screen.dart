import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/input_fields/custom_textfield_step2.dart';
import '../../controllers/profile_update_controller.dart';
import '../../services/language_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileUpdateController controller = Get.put(ProfileUpdateController());
  final LanguageService languageService = Get.find<LanguageService>();
  final ImagePicker _picker = ImagePicker();
  var accountType = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Color(0xffFAFAFA),
        backgroundColor: Color(0xffFAFAFA),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: controller.goBack,
            child: Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: SvgPicture.asset('images/icons/back_icon.svg'),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xffFAFAFA),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEF5050),))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderPhotoWithAvatar(),
                    const SizedBox(height: 12),
                    _buildImageFormatWarning(),
                    const SizedBox(height: 20),
                    _buildTextField(
                        languageService.tr("profile.editProfile.username"), "@", controller.usernameController),
                    const SizedBox(height: 10),
                    _buildTextField(languageService.tr("profile.editProfile.name"), "", controller.nameController),
                    const SizedBox(height: 10),
                    _buildTextField(languageService.tr("profile.editProfile.surname"), "", controller.surnameController),
                    const SizedBox(height: 10),
                    _buildTextField(languageService.tr("profile.editProfile.email"), "", controller.emailController),
                    const SizedBox(height: 10),
                    _buildTextField(languageService.tr("profile.editProfile.phone"), "", controller.phoneController),
                    const SizedBox(height: 10),
                    _buildTextField(
                        languageService.tr("profile.editProfile.birthday"), "", controller.birthdayController),
                    const SizedBox(height: 10),
                    _buildTextField(
                        languageService.tr("profile.editProfile.bio"), "", controller.descriptionController),
                    const SizedBox(height: 20),
                    _sectionTitle(languageService.tr("profile.editProfile.socialMediaAccounts")),
                    const SizedBox(height: 10),
                    _buildTextField(
                        "Instagram", "@", controller.instagramController),
                    const SizedBox(height: 10),
                    _buildTextField(
                        "Twitter", "@", controller.twitterController),
                    const SizedBox(height: 10),
                    _buildTextField(
                        "Facebook", "/", controller.facebookController),
                    const SizedBox(height: 10),
                    _buildTextField(
                        "LinkedIn", "/", controller.linkedinController),
                    const SizedBox(height: 10),
                    _buildTextField("Tiktok", "@", controller.tiktokController),
                    _sectionTitle(languageService.tr("profile.editProfile.schoolAndDepartment")),
                    const SizedBox(height: 10),
                    _buildSchoolDropdown(),
                    const SizedBox(height: 10),
                    _buildDepartmentDropdown(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle(languageService.tr("profile.editProfile.courses")),
                        InkWell(
                          onTap: () {
                            Get.toNamed('/match');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(0xFFEF5050),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              languageService.tr("match.resultScreen.addCourseButton"),
                              style: GoogleFonts.inter(
                                color: Color(0xffffffff),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomTextFieldStep2(
                      controller: controller.lessonController,
                      onAdd: () {
                        if (controller.lessonController.text.trim().isNotEmpty) {
                          controller.addLesson(controller.lessonController.text.trim());
                          controller.lessonController.clear();
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildLessonChips(),
                    const SizedBox(height: 20),
                    _sectionTitle(languageService.tr("profile.editProfile.notificationSettings")),
                    const SizedBox(height: 10),
                    _buildSwitchTile(
                        languageService.tr("profile.editProfile.emailNotification"),
                        controller.emailNotification,
                        controller.toggleEmailNotification),
                    const SizedBox(height: 20),
                    _buildSwitchTile(
                        languageService.tr("profile.editProfile.mobileNotification"),
                        controller.mobileNotification,
                        controller.toggleMobileNotification),
                    const SizedBox(height: 20),
                    _sectionTitle(languageService.tr("profile.editProfile.languageSelection")),
                    const SizedBox(height: 20),
                    _buildLanguageDropdown(),
                    const SizedBox(height: 20),
                    _sectionTitle(languageService.tr("profile.editProfile.accountType")),
                    const SizedBox(height: 10),
                    _buildAccountTypeDropdown(),
                    const SizedBox(height: 30),
                    CustomButton(
                      height: 50,
                      borderRadius: 15,
                      text: languageService.tr("common.buttons.save"),
                      onPressed: controller.saveProfile,
                      isLoading: controller.isLoading,
                      backgroundColor: const Color(0xFFEF5050),
                      textColor: Colors.white,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            )),
    );
  }

  Widget _buildAccountTypeDropdown() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: controller.accountType.value.isNotEmpty
                ? controller.accountType.value
                : null,
            hint: Text(
              languageService.tr("profile.editProfile.accountTypeSelection"),
              style: GoogleFonts.inter(
                fontSize: 13.28,
                fontWeight: FontWeight.w400,
                color: Color(0xff9ca3ae),
              ),
            ),
            items: ['public', 'private'].map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type.capitalizeFirst ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 13.28,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff414751),
                  ),
                ),
              );
            }).toList(),
            onChanged: (selected) {
              if (selected != null) {
                controller.changeAccountType(selected);
              }
            },
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: BorderRadius.circular(50),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,
            value: controller.selectedLanguageId.value,
            hint: Text(
              languageService.tr("profile.editProfile.languageSelection"),
              style: GoogleFonts.inter(
                fontSize: 13.28,
                fontWeight: FontWeight.w400,
                color: Color(0xff9ca3ae),
              ),
            ),
            items: controller.languages.map((language) {
              return DropdownMenuItem<int>(
                value: language.id,
                child: Text(
                  language.name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.28,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff414751),
                  ),
                ),
              );
            }).toList(),
            onChanged: (selected) {
              if (selected != null) {
                controller.onLanguageSelected(selected);
              }
            },
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ),
      ),
    );
  }

  Widget _buildSchoolDropdown() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: BorderRadius.circular(50),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: controller.selectedSchoolName.value.isNotEmpty
                ? controller.selectedSchoolName.value
                : null,
            hint: Text(
              languageService.tr("profile.editProfile.schoolSelection"),
              style: GoogleFonts.inter(
                fontSize: 13.28,
                fontWeight: FontWeight.w400,
                color: Color(0xff9ca3ae),
              ),
            ),
            items: controller.userSchools.map((school) {
              return DropdownMenuItem<String>(
                value: school['name'],
                child: Text(
                  school['name'],
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.28,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff414751),
                  ),
                ),
              );
            }).toList(),
            onChanged: (selected) {
              if (selected != null) {
                controller.onSchoolChanged(selected);
              }
            },
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: BorderRadius.circular(50),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: controller.selectedDepartmentName.value.isNotEmpty
                ? controller.selectedDepartmentName.value
                : null,
            hint: Text(
              languageService.tr("profile.editProfile.departmentSelection"),
              style: GoogleFonts.inter(
                fontSize: 13.28,
                fontWeight: FontWeight.w400,
                color: Color(0xff9ca3ae),
              ),
            ),
            items: controller.userDepartments.map((department) {
              return DropdownMenuItem<String>(
                value: department['title'],
                child: Text(
                  department['title'],
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.28,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff414751),
                  ),
                ),
              );
            }).toList(),
            onChanged: (selected) {
              if (selected != null) {
                controller.onDepartmentChanged(selected);
              }
            },
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderPhotoWithAvatar() {
    return SizedBox(
      height: 160, // 120 kapak + 60 profil yüksekliği (yarısı taşar)
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Kapak Fotoğrafı
          IgnorePointer(
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(20),
                image: controller.selectedCoverPhoto != null
                    ? DecorationImage(
                        image: FileImage(controller.selectedCoverPhoto!),
                        fit: BoxFit.cover,
                      )
                    : controller.userProfileModel.value?.bannerUrl
                                .startsWith('http') ==
                            true
                        ? DecorationImage(
                            image: NetworkImage(
                                controller.userProfileModel.value!.bannerUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
              ),
            ),
          ),

          // 2. Profil Fotoğrafı
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: GestureDetector(
              onTap: () async {
                final pickedFile = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 60,
                );
                if (pickedFile != null) {
                  setState(() {
                    controller.selectedAvatar = File(pickedFile.path);
                  });
                }
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0xfffafafa),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      backgroundImage: controller.selectedAvatar != null
                          ? FileImage(controller.selectedAvatar!)
                          : (controller.userProfileModel.value?.avatarUrl
                                          .startsWith('http') ==
                                      true
                                  ? NetworkImage(controller
                                      .userProfileModel.value!.avatarUrl)
                                  : const AssetImage('images/user1.png'))
                              as ImageProvider,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xfffb535c),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // 3. Kapak Fotoğrafı Düzenleme Butonu
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () async {
                final pickedFile = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 60,
                );
                if (pickedFile != null) {
                  setState(() {
                    controller.selectedCoverPhoto = File(pickedFile.path);
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xfffb535c),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, String prefix, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13.28,
                color: Color(0xff9ca3ae))),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            borderRadius: BorderRadius.circular(50),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(
                color: Color(0xff414751),
                fontSize: 13.28,
                fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              prefixText: prefix.isNotEmpty ? "$prefix " : null,
              prefixStyle: GoogleFonts.inter(color: Color(0xffd0d4db)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
      String title, RxBool value, Function(bool) onChanged) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13.28,
                color: Color(0xff9ca3ae),
              ),
            ),
            GestureDetector(
              onTap: () => onChanged(!value.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                alignment:
                    value.value ? Alignment.centerRight : Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Color(0xffffffff), // track arka planı tamamen kaldırıldı
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: value.value
                        ? const Color(0xFFEF5050) // açıkken kırmızı
                        : const Color(0xFFD3D3D3), // kapalıda gri
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ));
  }



  Widget _buildLessonChips() {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.selectedLessons.map((lesson) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lesson,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => controller.removeLessonFromUI(lesson),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Color(0xff414751),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ));
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
          fontWeight: FontWeight.w600, fontSize: 13.28, color: Color(0xff414751)),
    );
  }

  Widget _buildImageFormatWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xfff3f4f6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Color(0xff6b7280),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              languageService.tr("profile.editProfile.imageFormatWarning"),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Color(0xff6b7280),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
