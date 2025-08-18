import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:edusocial/components/snackbars/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/user_appbar/back_appbar.dart';
import '../../services/language_service.dart';

class VerificationUploadScreen extends StatefulWidget {
  const VerificationUploadScreen({super.key});

  @override
  State<VerificationUploadScreen> createState() =>
      _VerificationUploadScreenState();
}

class _VerificationUploadScreenState extends State<VerificationUploadScreen> {
  String? uploadedFileName;
  final Map<String, String> documentTypeNames = {
    'passport': 'passport',
    'id_card': 'id_card',
    'driverLicense': 'driverLicense',
  };

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    final String documentType = Get.arguments['documentType'] ?? 'passport';
    final String documentTypeKey =
        documentTypeNames[documentType] ?? 'passport';
    final bool hasFile = uploadedFileName != null;

    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(
        title: languageService.tr("verification.title"),
        iconBackgroundColor: Color(0xffffffff),
      ),
      body: Container(
        color: Color(0xfffafafa),
        child: Stack(
          children: [
            // Main card
            Center(
              child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 60), // Icon için yer açıyoruz
                    
                    // Title
                    Text(
                      languageService
                          .tr("verification.documentUpload.$documentTypeKey"),
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff414751),
                      ),
                    ),
                    SizedBox(height: 8),

                    // Description
                    Text(
                      languageService
                          .tr("verification.documentUpload.description"),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Color(0xff6b7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),

                    // Divider
                    Divider(
                      color: Color(0xffe5e7eb),
                      height: 1,
                    ),
                    SizedBox(height: 2),

                    // Upload area
                    GestureDetector(
                      onTap: () => _showFileOptions(),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                       
                        child: hasFile
                            ? _buildFileUploaded()
                            : _buildUploadPrompt(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Icon positioned half inside the card
            Positioned(
              top: 210, // Container'ın üstünden 40px aşağıda
              left: 0,
              right: 0,
              child: Center(
                child: Container(
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
              ),
            ),

            // Verify button
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: languageService.tr("verification.actions.verify"),
                    height: 50,
                    borderRadius: 16,
                    isLoading: false.obs,
                    backgroundColor: Color(0xffef5050),
                    textColor: Colors.white,
                    onPressed: uploadedFileName != null
                        ? () {
                            CustomSnackbar.show(
                              title: languageService
                                  .tr("verification.snackbar.success"),
                              message: languageService.tr(
                                  "verification.messages.verificationSuccess"),
                              type: SnackbarType.success,
                            );
                          }
                        : () {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPrompt() {
    final LanguageService languageService = Get.find<LanguageService>();
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
            width: 24,
            height: 24,
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
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff374151),
                ),
              ),
              Text(
                languageService
                    .tr("verification.documentUpload.uploadArea.uploadFile"),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Color(0xff6b7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploaded() {
    final LanguageService languageService = Get.find<LanguageService>();

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xfff9fafb),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.image,
            color: Color(0xff9ca3ae),
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                uploadedFileName ?? "whatsapp33.435-392.png",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff414751),
                ),
              ),
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
            onTap: () => _removeFile(),
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
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _uploadFile('camera');
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _uploadFile('gallery');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _uploadFile(String source) {
    setState(() {
      uploadedFileName =
          "uploaded_file_${DateTime.now().millisecondsSinceEpoch}.jpg";
    });

    final LanguageService languageService = Get.find<LanguageService>();
    CustomSnackbar.show(
      title: languageService.tr("verification.snackbar.success"),
      message: languageService.tr("verification.messages.fileUploadSuccess"),
      type: SnackbarType.success,
    );
  }

  void _removeFile() {
    setState(() {
      uploadedFileName = null;
    });

    final LanguageService languageService = Get.find<LanguageService>();
    CustomSnackbar.show(
      title: languageService.tr("verification.snackbar.success"),
      message: languageService.tr("verification.messages.fileRemoved"),
      type: SnackbarType.success,
    );
  }
}
