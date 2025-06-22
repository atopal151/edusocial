import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/group_models/grup_suggestion_model.dart';

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
            style:  GoogleFonts.inter(
              color: Color(0xffffffff),
              fontSize: 13.28,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Positioned(
          bottom: 53,
          left: 8,
          right: 8,
          child: Text(
            group.description,
            style:  GoogleFonts.inter(
              color: Color(0xffffffff),
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
              SvgPicture.asset(
                "images/icons/join_person.svg",
                colorFilter: ColorFilter.mode(
                  Color(0xffef5050),
                  BlendMode.srcIn,
                ),
                height: 13,
                width: 13,
              ),
              const SizedBox(width: 3),
              Text(
                group.memberCount.toString(),
                style: GoogleFonts.inter(
                  color: Color(0xffffffff),
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
