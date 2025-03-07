import 'package:flutter/material.dart';

class WarningBox extends StatelessWidget {
  final String message;

  const WarningBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 13.28,fontWeight: FontWeight.w500, color: Color(0xFFEF5050)),
        textAlign: TextAlign.center,
      ),
    );
  }
}