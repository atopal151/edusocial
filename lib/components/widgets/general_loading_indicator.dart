import 'package:flutter/material.dart';

class GeneralLoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final IconData? icon;
  final String? text;
  final bool showText;
  final bool showIcon;

  const GeneralLoadingIndicator({
    super.key,
    this.size = 24,
    this.color = const Color(0xFFFF7743),
    this.strokeWidth = 2.5,
    this.icon,
    this.text,
    this.showText = false,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              if (showIcon && icon != null)
                Icon(
                  icon,
                  size: size * 0.45,
                  color: color.withAlpha(150),
                ),
            ],
          ),
        ),
        if (showText && text != null) ...[
          SizedBox(height: 8),
          Text(
            text!,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// Önceden tanımlanmış stiller için extension
extension GeneralLoadingStyles on GeneralLoadingIndicator {
  // Grup loading için
  static GeneralLoadingIndicator group({
    double size = 24,
    Color color = const Color(0xFFFF7C7C),
    String? text,
  }) {
    return GeneralLoadingIndicator(
      size: size,
      color: color,
      icon: Icons.group,
      text: text,
      showText: text != null,
    );
  }

  // Chat loading için
  static GeneralLoadingIndicator chat({
    double size = 24,
    Color color = const Color(0xFF4CAF50),
    String? text,
  }) {
    return GeneralLoadingIndicator(
      size: size,
      color: color,
      icon: Icons.chat_bubble_outline,
      text: text,
      showText: text != null,
    );
  }

  // Profil loading için
  static GeneralLoadingIndicator profile({
    double size = 24,
    Color color = const Color(0xFF2196F3),
    String? text,
  }) {
    return GeneralLoadingIndicator(
      size: size,
      color: color,
      icon: Icons.person,
      text: text,
      showText: text != null,
    );
  }

  // Genel loading için (icon olmadan)
  static GeneralLoadingIndicator simple({
    double size = 24,
    Color color = const Color(0xFFFF7743),
    String? text,
  }) {
    return GeneralLoadingIndicator(
      size: size,
      color: color,
      showIcon: false,
      text: text,
      showText: text != null,
    );
  }

  // Küçük loading için
  static GeneralLoadingIndicator small({
    Color color = const Color(0xFFFF7743),
    IconData? icon,
  }) {
    return GeneralLoadingIndicator(
      size: 16,
      color: color,
      icon: icon,
      showIcon: icon != null,
    );
  }

  // Büyük loading için
  static GeneralLoadingIndicator large({
    Color color = const Color(0xFFFF7743),
    IconData? icon,
    String? text,
  }) {
    return GeneralLoadingIndicator(
      size: 48,
      color: color,
      icon: icon,
      text: text,
      showIcon: icon != null,
      showText: text != null,
    );
  }
} 