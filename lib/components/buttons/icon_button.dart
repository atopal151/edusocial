import 'package:flutter/material.dart';

Widget buildIconButton(Widget? icon, {required VoidCallback onPressed}) {
  return Container(
    height: 40,
    width: 40,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: icon!,
      onPressed: onPressed,
    ),
  );
}
