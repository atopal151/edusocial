import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TreePointBottomSheet extends StatelessWidget {
  const TreePointBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Color(0xff9ca3ae),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xfffff5f5),
                child: const Icon(Icons.person, color: Color(0xffef5050), size: 20),
              ),
              title:  Text(
                "Hakkında",
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff272727)),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xfffff5f5),
                child: const Icon(Icons.warning_rounded, color: Color(0xffef5050), size: 20),
              ),
              title:  Text("Şikayet Et",
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff272727))),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
