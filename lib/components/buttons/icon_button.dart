import 'package:flutter/material.dart';

Widget buildIconButton(IconData icon, {required VoidCallback onPressed}) {
  return Container(
    height: 40,
    width: 40,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: Icon(icon, size: 22, color: Color(0xffa5abb4)),
      onPressed: onPressed,
    ),
  );
}
