import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final RxBool isLoading;
  final Color backgroundColor;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: isLoading.value ? null : onPressed,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isLoading.value ? Colors.grey : backgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: isLoading.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: textColor,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13.28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ));
  }
}
