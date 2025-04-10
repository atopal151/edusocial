import 'package:flutter/material.dart';

import '../../models/grup_suggestion_model.dart';

Widget buildGroupSuggestionCard(GroupSuggestionModel group) {
  return Container(
    width: 150,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      image: DecorationImage(
        image: NetworkImage(group.groupImage),
        fit: BoxFit.cover,
      ),
    ),
    child: Stack(
      children: [
        // 🔹 Siyah degrade efekti (Alttan üste şeffaflaşan siyah)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withAlpha(153), // En altta yoğun siyah
                  Colors.black.withAlpha(77), // Ortalarda daha hafif siyah
                  Colors.transparent, // Üstte tamamen şeffaf
                ],
              ),
            ),
          ),
        ),

        // 🔹 Grup Profili (Yuvarlak Avatar)
        Positioned(
          top: 5,
          left: 10,
          child: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(group.groupAvatar),
          ),
        ),

        // 🔹 Grup İsmi (Alt kısımda, siyah degrade sayesinde okunaklı)
        Positioned(
          bottom: 110,
          left: 8,
          right: 8,
          child: Text(
            group.groupName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Positioned(
          bottom: 53,
          left: 8,
          right: 8,
          child: Text(
            group.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        // 🔹 Üye Sayısı (Sağ üstte, okunaklı olacak şekilde)
        Positioned(
          top: 10,
          right: 10,
          child: Row(
            children: [
              const Icon(Icons.group, color: Color(0xffEF5050), size: 16),
              const SizedBox(width: 3),
              Text(
                group.memberCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
