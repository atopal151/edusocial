import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? height;
  final double? borderRadius;
  final RxBool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final Color? iconColor;
  final Color? borderColor;
  final double? borderWidth;
  final Widget? icon;


  const CustomButton({
    super.key,
    required this.text,
    required this.height,
    required this.borderRadius,
    required this.onPressed,
    required this.isLoading,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.iconColor,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: isLoading.value ? null : onPressed,
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isLoading.value ? Colors.grey : backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius!),
              border: borderColor != null && borderWidth != null
                  ? Border.all(color: borderColor!, width: borderWidth!)
                  : null,
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          style: GoogleFonts.inter(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }
}
