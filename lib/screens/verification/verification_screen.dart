import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:edusocial/components/snackbars/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/user_appbar/back_appbar.dart';
import '../../services/language_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String? selectedDocumentType;

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();

    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(
        iconBackgroundColor: Color(0xffffffff),
        title: languageService.tr("verification.title"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document type selection
            _buildDocumentOption(
              languageService.tr("verification.documentSelection.passport"),
              languageService
                  .tr("verification.documentSelection.passportSubtitle"),
              
              "passport",
            ),
            SizedBox(height: 12),

            _buildDocumentOption(
              languageService.tr("verification.documentSelection.idCard"),
              languageService
                  .tr("verification.documentSelection.idCardSubtitle"),
       
              "id_card",
            ),
            SizedBox(height: 12),

            _buildDocumentOption(
              languageService
                  .tr("verification.documentSelection.driverLicense"),
              languageService
                  .tr("verification.documentSelection.driverLicenseSubtitle"),
             
              "driverLicense",
            ),

            SizedBox(height: 20),

            // Verify button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: languageService.tr("verification.actions.verify"),
                height: 50,
                borderRadius: 16,
                isLoading: false.obs,
                backgroundColor: Color(0xffef5050),
                textColor: Colors.white,
                onPressed: () {
                  if (selectedDocumentType != null) {
                    Get.toNamed('/verification_upload', arguments: {
                      'documentType': selectedDocumentType,
                    });
                  } else {
                    final LanguageService languageService = Get.find<LanguageService>();
                    CustomSnackbar.show(
                      title: languageService.tr("verification.snackbar.warning"),
                      message: languageService.tr("verification.validation.documentTypeRequired"),
                      type: SnackbarType.warning,
                    );
                  }
                },
                               
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentOption(
      String title, String subtitle,  String documentType) {
    final isSelected = selectedDocumentType == documentType;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDocumentType = documentType;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xffef5050) : Color(0xffe5e7eb),
            width: isSelected ? 1 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(
                'images/icons/$documentType.svg',
                width: 25,
                height: 25,
                colorFilter: ColorFilter.mode(
                  Color(0xffef5050),
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff414751),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Color(0xff6b7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
