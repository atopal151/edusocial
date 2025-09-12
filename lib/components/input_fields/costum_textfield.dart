// lib/components/input_fields/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;
  final Color backgroundColor;
  final Color textColor;
  final TextInputType? keyboardType;

  const CustomTextField({super.key, 
    required this.hintText,
    this.isPassword = false,
    required this.controller, 
    required this.backgroundColor, 
    required this.textColor,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hintText,
          style: TextStyle(
            fontSize: 13.28,
            fontWeight: FontWeight.w600,
            color: textColor, // Gri tonu
          ),
        ),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor, // Arka plan rengi
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            style: GoogleFonts.inter(fontSize: 13.28),
            controller: controller,
            obscureText: isPassword,
            enableSuggestions: !isPassword,
            autocorrect: !isPassword,
            keyboardType: keyboardType,
            textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
            // TextField'ı her zaman aktif bırak, controller dispose kontrolü parent'ta yapılacak
          ),
        ),
      ],
    );
  }
}