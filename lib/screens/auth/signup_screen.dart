// lib/views/register_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/input_fields/costum_textfield.dart';
import '../../controllers/signup_controller.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final SignupController controller = Get.find();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF26B6B), Color(0xFFE55050)],
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Benzer İlgi Alanlarına\nSahip Kişilerle Tanış! ",
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xffffffff),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "EduSocial, Polonya’daki uluslararası okullarda eğitim\ngören öğrenciler için tasarlanmış yenilikçi bir sosyal\nplatformdur.",
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Color(0xffffe4e4),
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Kayıt Ol",
                            style: GoogleFonts.inter(
                                fontSize: 18.72,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xff414751)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                              hintText: "Kullanıcı adı",
                              controller: controller.usernameSuController),
                          SizedBox(height: 10),
                          CustomTextField(
                              hintText: "E-posta",
                              controller: controller.emailSuController),
                          SizedBox(height: 10),
                          CustomTextField(
                              hintText: "Şifre",
                              isPassword: true,
                              controller: controller.passwordSuController),
                          SizedBox(height: 10),
                          CustomTextField(
                              hintText: "Şifre Tekrar",
                              isPassword: true,
                              controller:
                                  controller.confirmPasswordSuController),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Obx(() => GestureDetector(
                                    onTap: controller.toggleAcceptance,
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: controller.isAccepted.value
                                            ? Color(0xFFe75454)
                                            : Color(0xFFF5F5F5),
                                      ),
                                      child: controller.isAccepted.value
                                          ? Icon(Icons.check,
                                              color: Colors.white, size: 16)
                                          : null,
                                    ),
                                  )),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Gizlilik politikası ve kullanım koşullarını okudum anladım ve kabul ediyorum.",
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Color(0xff414751),
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          CustomButton(
                              backgroundColor: Color(0xffE75454),
                              text: "Kayıt Ol",
                              isLoading: controller.isSuLoading,
                              textColor: Colors.white,
                              onPressed: () {
                                controller.signup();
                              }),
                          SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Get.toNamed('/login');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Hesabınız var mı? ",
                                    style: GoogleFonts.inter(
                                        color: Color(0xFF414751),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.28)),
                                Text(
                                  "Giriş Yap.",
                                  style: GoogleFonts.inter(
                                      color: Color(0xFFEf5050),
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xFFEf5050),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.28),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
