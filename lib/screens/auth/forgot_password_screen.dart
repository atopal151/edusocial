import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/input_fields/costum_textfield.dart';
import '../../controllers/forgot_password_controller.dart';
import '../../services/language_service.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller = Get.find();
    final LanguageService languageService = Get.find<LanguageService>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BackAppBar(backgroundColor: Color(0xFFF26B6B)),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF26B6B), Color(0xFFE55050)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50),
              // Logo veya resim
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset,
                  size: 60,
                  color: Color(0xFFF26B6B),
                ),
              ),
              SizedBox(height: 30),
              // Başlık
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  languageService.tr("forgotPassword.title"),
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 15),
              // Alt başlık
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  languageService.tr("forgotPassword.subtitle"),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withAlpha(150),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 50),
              // Form
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageService.tr("forgotPassword.form.title"),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF414751),
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      textColor: Color(0xFF9CA3AE),
                      hintText: languageService.tr("forgotPassword.form.email"),
                      controller: controller.emailController,
                      backgroundColor: Color(0xFFF5F5F5),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 25),
                    CustomButton(
                      height: 50,
                      borderRadius: 15,
                      backgroundColor: Color(0xFFE55050),
                      text: languageService.tr("forgotPassword.form.sendButton"),
                      isLoading: controller.isLoading,
                      textColor: Colors.white,
                      onPressed: () => controller.sendResetEmail(),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          languageService.tr("forgotPassword.backToLogin"),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Color(0xFFE55050),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
