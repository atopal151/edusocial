import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDropDown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String selectedItem;
  final ValueChanged<String?> onChanged;
  final Color? color;

  const CustomDropDown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItem,
    required this.onChanged,  this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 13.28,
              fontWeight: FontWeight.w400,
              color: color ?? Color(0xff9CA3AE)),
        ),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Color(0xffffffff),
              borderRadius: BorderRadius.circular(15),
              value: selectedItem,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Color(0xff414751)),
              onChanged: onChanged,
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,
                      style: GoogleFonts.inter(
                          fontSize: 13.28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff414751))),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
