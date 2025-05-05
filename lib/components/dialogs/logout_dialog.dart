import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';

class LogoutDialogs {
  static void showLogoutDialog() {
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
                  child: SvgPicture.asset(
                    "images/icons/logout.svg",
                    colorFilter: ColorFilter.mode(
                      Color(0xffef5050),
                      BlendMode.srcIn,
                    ),
                    width: 50,
                    height: 50,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Çıkış Yap",
                  style: GoogleFonts.inter(
                    fontSize: 17.28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF414751),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "Hesabınızdan çıkmak istediğinize emin misiniz?",
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
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Color(0xfffff6f6),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "Vazgeç",
                            style: GoogleFonts.inter(
                              fontSize: 13.28,
                              color: Color(0xffed7474),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          AuthService.logout();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          margin: EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFFEF5050),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "Çıkış Yap",
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
