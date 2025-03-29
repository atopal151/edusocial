import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final RxBool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final Color? iconColor;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: isLoading.value ? null : onPressed,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isLoading.value ? Colors.grey : backgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white, // Text rengi ile uyumlu olacak şekilde
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min, // Buton içinde sıkışmaması için
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: iconColor ?? textColor,size: 16,),
                        const SizedBox(width: 8), // İkon ile metin arasındaki boşluk
                      ],
                      Text(
                        text,
                        style: GoogleFonts.inter(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }
}
