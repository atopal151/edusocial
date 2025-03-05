import 'package:flutter/material.dart';

class CustomDropDown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String selectedItem;
  final ValueChanged<String?> onChanged;

  const CustomDropDown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400, color: Color(0xff9CA3AE)),
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
              value: selectedItem,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Color(0xff414751)),
              onChanged: onChanged,
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 13.28,fontWeight: FontWeight.w600, color: Colors.black)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}