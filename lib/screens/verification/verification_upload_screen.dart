import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/user_appbar/back_appbar.dart';
import '../../services/language_service.dart';
import '../../controllers/verification_controller.dart';
import '../../controllers/profile_controller.dart';

class VerificationUploadScreen extends StatefulWidget {
  const VerificationUploadScreen({super.key});

  @override
  State<VerificationUploadScreen> createState() =>
      _VerificationUploadScreenState();
}

class _VerificationUploadScreenState extends State<VerificationUploadScreen> {
  final VerificationController controller = Get.put(VerificationController());
  final ProfileController profileController = Get.find<ProfileController>();
  final LanguageService languageService = Get.find<LanguageService>();
  final Map<String, String> documentTypeNames = {
    'passport': 'passport',
    'id_card': 'id_card',
    'driver_license': 'driverLicense',
  };

  @override
  void initState() {
    super.initState();
    // Ekrana girerken hesap zaten doğrulanmışsa uyarı verip geri dön
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardVerifiedUser());
  }

  @override
  Widget build(BuildContext context) {
    final String documentType = Get.arguments['documentType'] ?? 'passport';
    final String documentTypeKey =
        documentTypeNames[documentType] ?? 'passport';

    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(
        title: languageService.tr("verification.title"),
        iconBackgroundColor: Color(0xffffffff),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            SizedBox(height: 12),
            Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Color(0xffffffff),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(0xffe5e7eb),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SvgPicture.asset(
                        'images/icons/${documentTypeKey}image.svg',
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Title
                  Text(
                    languageService
                        .tr("verification.documentUpload.$documentTypeKey"),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff414751),
                    ),
                  ),
                  SizedBox(height: 2),

                  // Description
                  Text(
                    languageService
                        .tr("verification.documentUpload.description"),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Color(0xff9ca3ae),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),

                  // Divider
                  Divider(
                    color: Color(0xffe2e5ea),
                    height: 1,
                  ),
                  SizedBox(height: 2),

                  // Upload area
                  GestureDetector(
                    onTap: () => _showFileOptions(),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      child: Obx(() => controller.hasFile
                          ? _buildFileUploaded()
                          : _buildUploadPrompt()),
                    ),
                  ),
                  
                  // Image format warning
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            languageService.tr("verification.documentUpload.imageFormatWarning"),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Color(0xff6b7280),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Verify button
            Obx(() => SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: languageService.tr("verification.actions.verify"),
                height: 50,
                borderRadius: 16,
                isLoading: controller.isLoading,
                backgroundColor: Color(0xfffb535c),
                textColor: Colors.white,
                onPressed: controller.canSendVerification
                    ? () => controller.sendVerification()
                    : () {},
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPrompt() {
    final String documentType = Get.arguments['documentType'] ?? '';
    final String documentTypeKey =
        documentTypeNames[documentType] ?? 'passport';
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xfff9fafb),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SvgPicture.asset(
            'images/icons/selected_document.svg',
            width: 28,
            height: 28,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                languageService.tr(
                    "verification.documentUpload.uploadArea.$documentTypeKey"),
                style: GoogleFonts.inter(
                  fontSize: 13.28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff374151),
                ),
              ),
              Text(
                languageService
                    .tr("verification.documentUpload.uploadArea.uploadFile"),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Color(0xff9ca3ae),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploaded() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(0xfff9fafb),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Color(0xffe2e5ea),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Obx(() => controller.uploadedFile.value != null
                ? Image.file(
                    controller.uploadedFile.value!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.image,
                          color: Color(0xff9ca3ae),
                          size: 24,
                        ),
                      );
                    },
                  )
                : Container(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.image,
                      color: Color(0xff9ca3ae),
                      size: 24,
                    ),
                  )),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                controller.uploadedFileName.value.isNotEmpty 
                    ? controller.uploadedFileName.value 
                    : "image.jpg",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff414751),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
              GestureDetector(
                onTap: () => _showFileOptions(),
                child: Text(
                  languageService
                      .tr("verification.documentUpload.uploadArea.changeFile"),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Color(0xff9ca3ae),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xffffeded),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GestureDetector(
            onTap: () => controller.removeFile(),
            child: SvgPicture.asset(
              'images/icons/delete.svg',
              width: 18,
              height: 18,
            ),
          ),
        ),
      ],
    );
  }

  void _showFileOptions() {
    showModalBottomSheet(
      backgroundColor: Color(0xffffffff),
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xffffeded),
                child: const Icon(Icons.camera_alt, color: Color(0xffef5050), size: 20),
              ),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                controller.uploadFile('camera');
              },
            ),
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xffffeded),
                child: const Icon(Icons.photo_library, color: Color(0xffef5050), size: 20),
              ),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                controller.uploadFile('gallery');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Hesap doğrulanmışsa logout modal tasarımını kullanarak uyar ve geri dön
  void _guardVerifiedUser() {
    final p = profileController.profile.value;
    if (p == null) return;

    final isVerified = (p.accountVerified ?? false) ||
        (p.verified ?? false) ||
        (p.isVerified ?? false) ||
        (p.verificationStatus?.toLowerCase() == 'verified');

    if (!isVerified) return;

    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            width: Get.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Color(0xfffff4ed),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xffef5050),
                      size: 36,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Account already verified",
                  style: GoogleFonts.inter(
                    fontSize: 17.28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF414751),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "Your account is already verified.",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff9ca3ae),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.back(); // dialog
                          Get.back(); // önceki sayfa
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          margin: EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFFEF5050),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "OK",
                            style: TextStyle(
                              fontSize: 13.28,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
