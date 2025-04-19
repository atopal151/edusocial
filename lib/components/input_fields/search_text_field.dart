import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          icon: SvgPicture.asset(
                        "images/icons/search_icon.svg",
                        colorFilter: ColorFilter.mode(
                          Color(0xff9ca3ae),
                          BlendMode.srcIn,
                        ),
                      ),
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
