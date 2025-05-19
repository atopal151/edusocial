import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
                    _buildHeaderPhotoWithAvatar(),
                    const SizedBox(height: 50),
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
                    const SizedBox(height: 10),
                    _buildTextField(
                        "Biyografi", "", controller.descriptionController),
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
                    const SizedBox(height: 10),
                    _buildTextField("Tiktok", "@", controller.tiktokController),

                    /*
                    _sectionTitle("Okul ve Bölüm Bilgisi"),
                    const SizedBox(height: 10),
                    _buildTextField(
                        "Okul ID", "", controller.schoolIdController),
                    const SizedBox(height: 10),
                    _buildTextField(
                        "Bölüm ID", "", controller.departmentIdController),
                    const SizedBox(height: 20),*/
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
                    const SizedBox(height: 20),
                    _buildSwitchTile(
                        "Mobil Bildirimi",
                        controller.mobileNotification,
                        controller.toggleMobileNotification),
                    const SizedBox(height: 20),
                    _buildTextField(
                        "Dil ID", "", controller.languageIdController),
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

  Widget _buildHeaderPhotoWithAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildCoverPhotoSection(),
        Positioned(
          bottom: -40,
          left: Get.width / 2 - 55,
          child: _buildProfilePicture(),
        )
      ],
    );
  }

  Widget _buildCoverPhotoSection() {
    return Stack(
      children: [
        // Cover fotoğrafı gösterimi
        Container(
          height: 130,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: controller.selectedCoverPhoto != null
                  ? FileImage(controller.selectedCoverPhoto!)
                  : (controller.userProfileModel.value?.bannerUrl
                                  .startsWith('http') ==
                              true
                          ? NetworkImage(
                              controller.userProfileModel.value!.bannerUrl)
                          : const AssetImage('images/card_car.png'))
                      as ImageProvider,
            ),
          ),
        ),

        // Değiştir butonu (kamera simgesi)
        Positioned(
          bottom: 10,
          right: 10,
          child: GestureDetector(
            onTap: () async {
              final picked = await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 60,
              );
              if (picked != null) {
                setState(() {
                  controller.selectedCoverPhoto = File(picked.path);
                });
                Get.snackbar(
                    "Kapak Fotoğrafı", "Yeni kapak fotoğrafı seçildi.");
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFEF5050),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
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
                final pickedprofile = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 50,
                );
                if (pickedprofile != null) {
                  setState(() {
                    controller.selectedAvatar = File(pickedprofile.path);
                  });
                  Get.snackbar("Başarılı", "Profil fotoğrafı seçildi.");
                }
              },
              child: Container(
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
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13.28,
                color: Color(0xff9ca3ae))),
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
                  color: Colors.white, // track arka planı tamamen kaldırıldı
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
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
                    onTap: () => controller.removeLesson(lesson),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildAccountTypeSelector() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAccountTypeBox('public'),
            const SizedBox(width: 8),
            _buildAccountTypeBox('private'),
          ],
        ));
  }

  Widget _buildAccountTypeBox(String type) {
    final isSelected = controller.accountType.value == type;
    return GestureDetector(
      onTap: () => controller.changeAccountType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE7E7E7) : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type.capitalizeFirst ?? '',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.black : const Color(0xFF1F1F1F),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check, size: 16, color: Colors.black),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
          fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xff414751)),
    );
  }
}
