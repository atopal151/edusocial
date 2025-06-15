import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSnackbar {
  static void show({
    required String title,
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      '',
      '',
      titleText: Text(
        title,
        style: GoogleFonts.inter(
          color: const Color(0xFF414751),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.inter(
          color: const Color(0xFF414751).withOpacity(0.8),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 12,
      icon: _getIcon(type),
      duration: duration,
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
     
    );
  }

  static Widget _getIcon(SnackbarType type) {
    IconData iconData;
    Color iconColor;
    
    switch (type) {
      case SnackbarType.success:
        iconData = Icons.check_circle_outline;
        iconColor = const Color(0xFF4CAF50);
        break;
      case SnackbarType.error:
        iconData = Icons.error_outline;
        iconColor = const Color(0xFFF26B6B);
        break;
      case SnackbarType.warning:
        iconData = Icons.warning_amber_outlined;
        iconColor = const Color(0xFFFFA726);
        break;
      case SnackbarType.info:
        iconData = Icons.info_outline;
        iconColor = const Color(0xFF2196F3);
        break;
    }
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          iconData,
          color: iconColor,
          size: 24,
        ),
      ),
    );
  }
}

enum SnackbarType {
  success,
  error,
  warning,
  info,
} 