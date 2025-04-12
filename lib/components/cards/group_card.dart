import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupCard extends StatelessWidget {
  final String imageUrl;
  final String groupName;
  final String groupDescription;
  final int memberCount;
  final int? chatNotification;
  final List<String>? category; // opsiyonel olsun

  final VoidCallback onJoinPressed;
  final String action;

  const GroupCard({
    super.key,
    required this.imageUrl,
    required this.groupName,
    required this.groupDescription,
    required this.memberCount,
    this.chatNotification,
    required this.onJoinPressed,
    required this.action,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      width: 200,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          ///ARKA PLAN GÖRSELİ
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),

          ///MESAJ SAYISI BADGE
          if (chatNotification != null)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, size: 12, color: Color(0xff414751)),
                    SizedBox(
                      width: 1,
                    ),
                    Text(
                      "$chatNotification Mesaj",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff414751),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ///ÜYE SAYISI BADGE
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, size: 14, color: Color(0xffEF5050)),
                  SizedBox(width: 4),
                  Text(
                    memberCount.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff414751),
                    ),
                  ),
                ],
              ),
            ),
          ),

          ///BEYAZ İÇERİK KARTI
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category != null && category!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: category!
                            .map((label) => Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Color(0xffd0d4db)),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    label,
                                    style: GoogleFonts.inter(
                                        fontSize: 10, color: Color(0xff9ca3ae),fontWeight: FontWeight.w600),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  Text(
                    groupName,
                    style: GoogleFonts.inter(
                      fontSize: 13.28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff414751),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    groupDescription,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff9ca3ae),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      onJoinPressed(); // joinGroup fonksiyonunu çalıştır
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Color(0xffFFF6F6),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          action,
                          style: GoogleFonts.inter(
                            color: Color(0xffED7474),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
