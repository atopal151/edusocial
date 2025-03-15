// lib/components/buttons/custom_button.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final RxBool isLoading;
  final Color backgroundColor;
  final Color textColor;

  const CustomButton({super.key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    required this.backgroundColor, required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: isLoading.value ? null : onPressed,
        child: isLoading.value
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style: TextStyle(color: textColor, fontSize: 13.28, fontWeight: FontWeight.bold),
              ),
      )),
    );
  }
}