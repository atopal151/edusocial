import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/input_fields/costum_textfield.dart';
import '../../controllers/reset_password_controller.dart';
import '../../services/language_service.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String? token;
  final String? email;
  
  const ResetPasswordScreen({
    super.key, 
    this.token, 
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    final ResetPasswordController controller = Get.find();
    final LanguageService languageService = Get.find<LanguageService>();

    // Token veya email'i controller'a set et
    if (token != null) controller.token = token!;
    if (email != null) controller.email = email!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF414751)),
          onPressed: () => Get.back(),
        ),
      ),
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
                  Icons.lock_open,
                  size: 60,
                  color: Color(0xFFE55050),
                ),
              ),
              SizedBox(height: 30),
              // Başlık
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  languageService.tr("resetPassword.title"),
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
                  languageService.tr("resetPassword.subtitle"),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withAlpha(90),
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageService.tr("resetPassword.form.title"),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF414751),
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      textColor: Color(0xFF9CA3AE),
                      hintText: languageService.tr("resetPassword.form.newPassword"),
                      controller: controller.newPasswordController,
                      backgroundColor: Color(0xFFF5F5F5),
                      isPassword: true,
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      textColor: Color(0xFF9CA3AE),
                      hintText: languageService.tr("resetPassword.form.confirmPassword"),
                      controller: controller.confirmPasswordController,
                      backgroundColor: Color(0xFFF5F5F5),
                      isPassword: true,
                    ),
                    SizedBox(height: 25),
                    CustomButton(
                      height: 50,
                      borderRadius: 15,
                      backgroundColor: Color(0xFFE55050),
                      text: languageService.tr("resetPassword.form.resetButton"),
                      isLoading: controller.isLoading,
                      textColor: Colors.white,
                      onPressed: () => controller.resetPassword(),
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
