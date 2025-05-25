import 'package:flutter/material.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    final hex = hexColor.replaceAll("#", "");
    return int.parse("FF$hex", radix: 16);
  }

  HexColor.fromHex(String hexColor) : super(_getColorFromHex(hexColor));
}

extension ColorExtension on Color {
  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
