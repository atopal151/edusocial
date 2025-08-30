import 'package:flutter/material.dart';

class VerificationBadge extends StatelessWidget {
  final bool isVerified;
  final double size;
  final Color? color;
  final EdgeInsets? margin;

  const VerificationBadge({
    super.key,
    required this.isVerified,
    this.size = 16.0,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: margin ?? const EdgeInsets.only(left: 4),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? const Color(0xFF1DA1F2), // Twitter/Instagram mavi rengi
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          Icons.verified,
          size: size * 0.7,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// İsim ve kullanıcı adı ile birlikte doğrulama rozeti gösteren widget
class VerifiedNameDisplay extends StatelessWidget {
  final String name;
  final String? username;
  final bool isVerified;
  final TextStyle? nameStyle;
  final TextStyle? usernameStyle;
  final double badgeSize;
  final Color? badgeColor;
  final bool showUsername;
  final CrossAxisAlignment crossAxisAlignment;

  const VerifiedNameDisplay({
    super.key,
    required this.name,
    this.username,
    required this.isVerified,
    this.nameStyle,
    this.usernameStyle,
    this.badgeSize = 16.0,
    this.badgeColor,
    this.showUsername = true,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        // İsim ve doğrulama rozeti
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                name,
                style: nameStyle ?? const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff272727),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            VerificationBadge(
              isVerified: isVerified,
              size: badgeSize,
              color: badgeColor,
            ),
          ],
        ),
        
        // Kullanıcı adı (opsiyonel)
        if (showUsername && username != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              username!,
              style: usernameStyle ?? const TextStyle(
                fontSize: 13.28,
                fontWeight: FontWeight.w500,
                color: Color(0xff9ca3ae),
              ),
            ),
          ),
      ],
    );
  }
}
