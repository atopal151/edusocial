import 'package:flutter/material.dart';


Widget buildIconButton(
  Widget? icon, {
  required VoidCallback onPressed,
 Color iconColor = const Color(0xff414751),
}) {
  return Container(
    height: 40,
    width: 40,
    decoration: BoxDecoration(
      color: Color(0xffffeeee), // <== burada kullandık
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: icon!,
      color: iconColor,
      onPressed: onPressed,
    ),
  );
}
