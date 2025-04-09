import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomChipList extends StatelessWidget {
  final List<String> items;
  final Function(String) onRemove;
  final Color textColor;
  final Color backgroundColor;
  final Color iconColor;
  final Color iconbackColor;

  const CustomChipList(
      {super.key, required this.items, required this.onRemove, required this.textColor, required this.backgroundColor, required this.iconColor, required this.iconbackColor});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: GestureDetector(
                  onTap: () => onRemove(item),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      color: iconbackColor,
                    ),
                    padding: EdgeInsets.all(3),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                item,
                style:
                    GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w600,fontSize: 13.28),
              ),
            ],
          ),
        );
      }).toList(),
    ));
  }
}
