import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToggleTabBar extends StatelessWidget {
  final RxInt selectedIndex;
  final Function(int) onTabChanged;

  const ToggleTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          decoration: BoxDecoration(
            color: Color(0xffF2F2f2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              _buildToggleItem(0, "Gönderiler"),
              _buildToggleItem(1, "Entryler"),
            ],
          ),
        ));
  }

  Widget _buildToggleItem(int index, String label) {
    bool isSelected = selectedIndex.value == index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => onTabChanged(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Color(0xff414751) : Color(0xffa8adb4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
