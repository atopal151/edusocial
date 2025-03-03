import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/input_fields/costum_textfield.dart';
import '../../controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF26B6B), Color(0xFFE55050)],
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.35,
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
                          padding: const EdgeInsets.only(top: 20.0),
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
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "EduSocial, Polonya’daki uluslararası okullarda eğitim gören öğrenciler için tasarlanmış yenilikçi bir sosyal platformdur.",
                          style: TextStyle(fontSize: 14, color: Colors.white),
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
                                style: TextStyle(
                                  fontSize: 18.72,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF414751),
                                ),
                              ),
                              SizedBox(height: 10),
                              CustomTextField(
                                hintText: "Kullanıcı adı veya e-posta",
                                controller: controller
                                    .emailController, // Controller dışarıdan verildi!
                              ),
                              CustomTextField(
                                hintText: "Şifre",
                                isPassword: true,
                                controller: controller
                                    .passwordController, // Controller dışarıdan verildi!
                              ),
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: (){
                                    controller.loginPasswordUpgrade();
                                  },
                                  child: Text(
                                    "Şifrenizi mi unuttunuz?",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF414751),
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xFF414751),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              CustomButton(
                                text: "Giriş Yap",
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
                                        style:
                                            TextStyle(color: Color(0xFF414751)),
                                      ),
                                      Text(
                                        "Kayıt Ol.",
                                        style: TextStyle(
                                          color: Color(0xFFE55050),
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xFFE55050),
                                        ),
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
            ),
          ],
        ),
      ),
    );
  }
}
