import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final double width;
  final bool isLoading;
  final IconData? icon;
  final double? iconSize;
  final EdgeInsets? padding;
  final bool isDisabled;

  const NotificationActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = const Color(0xfffb535c),
    this.textColor = const Color(0xfffff6f6),
    this.height = 32,
    this.borderRadius = 15,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w500,
    this.width = 100,
    this.isLoading = false,
    this.icon,
    this.iconSize,
    this.padding,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            height: height,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey[300] : backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: isDisabled 
                  ? Border.all(color: Colors.grey[400]!, width: 1)
                  : null,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: iconSize ?? 14,
                            color: isDisabled ? Colors.grey[600] : textColor,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: fontWeight,
                              color: isDisabled ? Colors.grey[600] : textColor,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// Önceden tanımlanmış stiller için factory constructor'lar
class NotificationActionButtonStyles {
  // Onayla butonu stili
  static NotificationActionButton accept({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return NotificationActionButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: const Color(0xfffb535c),
      textColor: const Color(0xfffff6f6),
      height: 32,
      borderRadius: 15,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      width: 100,
      isLoading: isLoading,
      isDisabled: isDisabled,
    );
  }

  // Reddet butonu stili
  static NotificationActionButton decline({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return NotificationActionButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: const Color(0xffffd6d6),
      textColor: const Color(0xfffb535c),
      height: 32,
      borderRadius: 15,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      width: 100,
      isLoading: isLoading,
      isDisabled: isDisabled,
    );
  }

  // Onaylandı butonu stili (disabled)
  static NotificationActionButton accepted({
    required String text,
  }) {
    return NotificationActionButton(
      text: text,
      onPressed: null,
      backgroundColor: Colors.grey[300]!,
      textColor: Colors.grey[600]!,
      height: 32,
      borderRadius: 15,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      width: 100,
      isDisabled: true,
    );
  }

  // Reddedildi butonu stili (disabled)
  static NotificationActionButton rejected({
    required String text,
  }) {
    return NotificationActionButton(
      text: text,
      onPressed: null,
      backgroundColor: const Color(0xffffd6d6),
      textColor: const Color(0xfffb535c),
      height: 32,
      borderRadius: 15,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      width: 100,
      isDisabled: true,
    );
  }


} 