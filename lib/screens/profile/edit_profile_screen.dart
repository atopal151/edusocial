import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/buttons/custom_button.dart';
import '../../controllers/profile_update_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileUpdateController controller = Get.put(ProfileUpdateController());
  final ImagePicker _picker = ImagePicker();

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
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfilePicture(),
                    const SizedBox(height: 20),
                    _buildTextField(
                        "Kullanıcı Adı", "@", controller.usernameController),
                    const SizedBox(height: 10),
                    _buildTextField("Ad", "", controller.nameController),
                    const SizedBox(height: 10),
                    _buildTextField("Soyad", "", controller.surnameController),
                    const SizedBox(height: 10),
                    _buildTextField("E-posta", "", controller.emailController),
                    const SizedBox(height: 10),
                    _buildTextField("Telefon", "", controller.phoneController),
                    const SizedBox(height: 10),
                    _buildTextField(
                        "Doğum Tarihi", "", controller.birthdayController),
                    const SizedBox(height: 20),
                    _sectionTitle("Sosyal Medya Hesapları"),
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
                    const SizedBox(height: 20),
                    _sectionTitle("Okul ve Bölüm Bilgisi"),
                    const SizedBox(height: 10),
                    _buildTextField(
                        "Okul ID", "", controller.schoolIdController),
                    const SizedBox(height: 10),
                    _buildTextField(
                        "Bölüm ID", "", controller.departmentIdController),
                    const SizedBox(height: 20),
                    _sectionTitle("Dersler"),
                    const SizedBox(height: 10),
                    _buildLessonChips(),
                    const SizedBox(height: 20),
                    _sectionTitle("Bildirim Ayarları"),
                    const SizedBox(height: 10),
                    _buildSwitchTile(
                        "E-posta Bildirimi",
                        controller.emailNotification,
                        controller.toggleEmailNotification),
                    _buildSwitchTile(
                        "Mobil Bildirimi",
                        controller.mobileNotification,
                        controller.toggleMobileNotification),
                    const SizedBox(height: 20),
                    _sectionTitle("Hesap Tipi"),
                    _buildAccountTypeSelector(),
                    const SizedBox(height: 30),
                    CustomButton(
                      height: 50,
                      borderRadius: 15,
                      text: "Kaydet",
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

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: controller.selectedAvatar != null
                ? FileImage(controller.selectedAvatar!)
                : (controller.userProfileModel.value?.avatar
                            .startsWith('http') ==
                        true
                    ? NetworkImage(controller.userProfileModel.value!.avatar)
                    : AssetImage('images/user1.png')) as ImageProvider,
            onBackgroundImageError: (_, __) {
              debugPrint(
                  "⚠️ Avatar yüklenemedi, varsayılan resim gösteriliyor.");
            },
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 50,
                );
                if (picked != null) {
                  controller.selectedAvatar = File(picked.path);
                  Get.snackbar("Başarılı", "Profil fotoğrafı seçildi.");
                }
              },
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF5050),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child:
                      SvgPicture.asset('images/icons/edit_icon.svg', width: 18),
                ),
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
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.28,
                color: Color(0xff414751))),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixText: prefix.isNotEmpty ? "$prefix " : null,
              prefixStyle: const TextStyle(color: Color(0xffd0d4db)),
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
    return Obx(() => SwitchListTile(
          title: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.28,
                  color: Color(0xff414751))),
          value: value.value,
          onChanged: onChanged,
          activeColor: const Color(0xFFEF5050),
        ));
  }

  Widget _buildLessonChips() {
    return Obx(() => Wrap(
          spacing: 8,
          children: controller.selectedLessons.map((lesson) {
            return Chip(
              label: Text(lesson),
              onDeleted: () => controller.removeLesson(lesson),
              deleteIcon: const Icon(Icons.close, size: 18),
            );
          }).toList(),
        ));
  }

  Widget _buildAccountTypeSelector() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: const Text("Public"),
              selected: controller.accountType.value == 'public',
              onSelected: (_) => controller.changeAccountType('public'),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text("Private"),
              selected: controller.accountType.value == 'private',
              onSelected: (_) => controller.changeAccountType('private'),
            ),
          ],
        ));
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xff414751)),
    );
  }
}
