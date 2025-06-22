import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFieldStep2 extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;

  const CustomTextFieldStep2({
    super.key,
    required this.controller,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffffffff),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: controller,
            style: GoogleFonts.inter(
              // Kullanıcı yazı yazarkenki stil
              color: Color(0xff000000),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              border: InputBorder.none,
              labelStyle: GoogleFonts.inter(
                color: Color(0xff414751),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              hintText: "Ders adı giriniz",
              hintStyle: GoogleFonts.inter(
                color: Color(0xff414751),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
          InkWell(
            onTap: () {
              onAdd();
            },
            child: Container(
                margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Color(0xFFef5050),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16, top: 8, bottom: 8),
                  child: Text(
                    "Ekle",
                    style: GoogleFonts.inter(
                        color: Color(0xffffffff),
                        fontWeight: FontWeight.w600,
                        fontSize: 10),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
