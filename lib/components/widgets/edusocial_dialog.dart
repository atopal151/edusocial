import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EduSocialDialogs {
  static void showDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(20),
            width: Get.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// İKON
                Icon(
                  isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                  color: isSuccess ? Colors.green : Colors.redAccent,
                  size: 64,
                ),
                SizedBox(height: 20),

                /// BAŞLIK
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green : Colors.redAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),

                /// MESAJ
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff414751),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                /// BUTON
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSuccess ? Colors.green : Colors.redAccent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "Tamam",
                      style: TextStyle(
                        fontSize: 13.28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Kısayol fonksiyonlar
  static void showSuccess({required String title, required String message}) {
    showDialog(title: title, message: message, isSuccess: true);
  }

  static void showError({required String title, required String message}) {
    showDialog(title: title, message: message, isSuccess: false);
  }
}
