import 'package:flutter/material.dart';
import '../../models/hot_topics_model.dart';

Widget buildHotTopicsCard(HotTopicsModel topic) {
  return Container(
    width: 230,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
                  colors: [
                    Color(0xffffab1b),
                    Color(0xFFffb427)
                  ], // Linear gradient renkleri
                  begin: Alignment.topRight,
                  end: Alignment.topLeft,
                ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: Color(0xfffffce6), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            topic.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}
