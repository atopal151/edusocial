import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Function(String)? onChanged;

  const SearchTextField({
    super.key,
    required this.controller,
    this.onChanged, required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xffffffff),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xff414751),
        ),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Color(0xff9CA3AE), size: 19),
          hintText: label,
          hintStyle: GoogleFonts.inter(
            color: Color(0xff9CA3AE),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
