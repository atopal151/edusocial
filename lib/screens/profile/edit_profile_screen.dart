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
              decoration: BoxDecoration(
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
      backgroundColor: Color(0xffFAFAFA),
      body: Obx(() => controller.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfilePicture(),
                    SizedBox(height: 20),
                    _buildTextField(
                        "Kullanıcı Adı", "@", controller.usernameController),
                    SizedBox(height: 10),
                    _buildTextField("Ad", "", controller.nameController),
                    SizedBox(height: 10),
                    _buildTextField("Soyad", "", controller.surnameController),
                    SizedBox(height: 10),
                    _buildTextField("E-posta", "", controller.emailController),
                    SizedBox(height: 10),
                    _buildTextField("Telefon", "", controller.phoneController),
                    SizedBox(height: 10),
                    _buildTextField(
                        "Doğum Tarihi", "", controller.birthdayController),
                    SizedBox(height: 20),
                    _sectionTitle("Sosyal Medya Hesapları"),
                    SizedBox(height: 10),
                    _buildTextField(
                        "Instagram", "@", controller.instagramController),
                    SizedBox(height: 10),
                    _buildTextField(
                        "Twitter", "@", controller.twitterController),
                    SizedBox(height: 10),
                    _buildTextField(
                        "Facebook", "/", controller.facebookController),
                    SizedBox(height: 10),
                    _buildTextField(
                        "LinkedIn", "/", controller.linkedinController),
                    SizedBox(height: 20),
                    _sectionTitle("Okul ve Bölüm Bilgisi"),
                    SizedBox(height: 10),
                    _buildTextField(
                        "Okul ID", "", controller.schoolIdController),
                    SizedBox(height: 10),
                    _buildTextField(
                        "Bölüm ID", "", controller.departmentIdController),
                    SizedBox(height: 20),
                    _sectionTitle("Dersler"),
                    SizedBox(height: 10),
                    _buildLessonChips(),
                    SizedBox(height: 20),
                    _sectionTitle("Bildirim Ayarları"),
                    SizedBox(height: 10),
                    _buildSwitchTile(
                        "E-posta Bildirimi",
                        controller.emailNotification,
                        controller.toggleEmailNotification),
                    _buildSwitchTile(
                        "Mobil Bildirimi",
                        controller.mobileNotification,
                        controller.toggleMobileNotification),
                    SizedBox(height: 20),
                    _sectionTitle("Hesap Tipi"),
                    _buildAccountTypeSelector(),
                    SizedBox(height: 30),
                    CustomButton(
                      height: 50,
                      borderRadius: 15,
                      text: "Kaydet",
                      onPressed: controller.saveProfile,
                      isLoading: controller.isLoading,
                      backgroundColor: Color(0xFFEF5050),
                      textColor: Colors.white,
                    ),
                    SizedBox(height: 40),
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
                : (controller.userProfile.value.profileImage.startsWith('http')
                    ? NetworkImage(controller.userProfile.value.profileImage)
                    : AssetImage('images/user1.png')) as ImageProvider,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                final picked = await _picker.pickImage(
                    source: ImageSource.gallery, imageQuality: 50);
                if (picked != null) {
                  controller.selectedAvatar =
                      File(picked.path); // ✅ doğru dosya seçiliyor
                  controller.userProfile.update((val) {
                    val?.profileImage = picked.path; // ✅ görünümü güncelle
                  });
                  Get.snackbar("Başarılı",
                      "Profil fotoğrafı seçildi."); // (isteğe bağlı)
                }
              },
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
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
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.28,
                color: Color(0xff414751))),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixText: prefix.isNotEmpty ? "$prefix " : null,
              prefixStyle: TextStyle(color: Color(0xffd0d4db)),
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
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.28,
                  color: Color(0xff414751))),
          value: value.value,
          onChanged: onChanged,
          activeColor: Color(0xFFEF5050),
        ));
  }

  Widget _buildLessonChips() {
    return Obx(() => Wrap(
          spacing: 8,
          children: controller.selectedLessons.map((lesson) {
            return Chip(
              label: Text(lesson),
              onDeleted: () => controller.removeLesson(lesson),
              deleteIcon: Icon(Icons.close, size: 18),
            );
          }).toList(),
        ));
  }

  Widget _buildAccountTypeSelector() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: Text("Public"),
              selected: controller.accountType.value == 'public',
              onSelected: (_) => controller.changeAccountType('public'),
            ),
            SizedBox(width: 8),
            ChoiceChip(
              label: Text("Private"),
              selected: controller.accountType.value == 'private',
              onSelected: (_) => controller.changeAccountType('private'),
            ),
          ],
        ));
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xff414751)),
    );
  }
}
