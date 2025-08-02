import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Function(String)? onChanged;

  const SearchTextField({
    super.key,
    required this.controller,
    this.onChanged, 
    required this.label,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  @override
  void dispose() {
    // Controller'ın listener'larını temizle
    widget.controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xffffffff),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        enableSuggestions: true,
        autocorrect: false, // Search için autocorrect kapalı
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
          hintText: widget.label,
          hintStyle: GoogleFonts.inter(
            color: Color(0xff9CA3AE),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
