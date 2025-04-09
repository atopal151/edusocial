// lib/components/input_fields/custom_multiline_text_field.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomMultilineTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Color backgroundColor;
  final Color textColor;
  final int count;

  const CustomMultilineTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.backgroundColor,
    required this.textColor, required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              hintText,
              style: TextStyle(
                fontSize: 13.28,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            Text(
            '$count/500',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            style: GoogleFonts.inter(fontSize: 13.28),
            controller: controller,
            maxLines: null,
            minLines: 5,
            maxLength: 500,
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: "", // Karakter sayacını gizlemek istersen
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }
}
