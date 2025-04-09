import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/input_fields/costum_textfield.dart';
import '../../controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find();

    return Scaffold(
      backgroundColor: Color(0xffffffff),
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
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height *
                          0.28, // Yükseklik biraz düşürüldü

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50.0),
                          child: Image.asset(
                            'images/login_image.png',
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Benzer İlgi Alanlarına\n Sahip Kişilerle Tanış!",
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "EduSocial, Polonya’daki uluslararası okullarda eğitim gören öğrenciler için tasarlanmış yenilikçi bir sosyal platformdur.",
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
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Giriş Yap",
                                style: GoogleFonts.inter(
                                  fontSize: 18.72,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF414751),
                                ),
                              ),
                              SizedBox(height: 10),
                              CustomTextField(
                                  textColor: Color(0xFF9CA3AF),
                                  hintText: "Kullanıcı adı veya e-posta",
                                  controller: controller
                                      .emailController, // Controller dışarıdan verildi!,
                                  backgroundColor: Color(0xfff5f5f5)),
                              CustomTextField(
                                  textColor: Color(0xFF9CA3AF),
                                  hintText: "Şifre",
                                  isPassword: true,
                                  controller: controller
                                      .passwordController, // Controller dışarıdan verildi!,
                                  backgroundColor: Color(0xfff5f5f5)),
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () {
                                    controller.loginPasswordUpgrade();
                                  },
                                  child: Text(
                                    "Şifrenizi mi unuttunuz?",
                                    style: GoogleFonts.inter(
                                      fontSize: 13.28,
                                      color: Color(0xFF414751),
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xFF414751),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              CustomButton(

                        height: 50,
                        borderRadius: 15,
                                backgroundColor: Color(0xffE75454),
                                text: "Giriş Yap",
                                isLoading: controller.isLoading,
                                textColor: Colors.white,
                                onPressed: () {
                                  controller.login();
                                },
                              ),
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    Get.toNamed('/signup');
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Hesabınız yok mu? ",
                                        style: GoogleFonts.inter(
                                            color: Color(0xFF414751),
                                            fontSize: 13.28,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        "Kayıt Ol.",
                                        style: GoogleFonts.inter(
                                            color: Color(0xFFE55050),
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Color(0xFFE55050),
                                            fontSize: 13.28,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
