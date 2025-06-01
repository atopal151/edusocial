// entry_detail_screen.dart
import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/controllers/entry_detail_controller.dart';
import 'package:edusocial/models/entry_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/cards/entry_comment_card.dart';

class EntryDetailScreen extends StatefulWidget {
  const EntryDetailScreen({super.key});

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  final EntryDetailController entryDetailController =
      Get.find<EntryDetailController>();

  final EntryModel entry = Get.arguments as EntryModel; // Gelen entry
  // Gelen entry
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(),
      body: Column(
        children: [
          // Başlık kısmı
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    // Butona tıklanınca yapılacak işlemi buraya ekleyin
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "Okul İlişkileri",
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Color(0xff272727)),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                /*Text(entry.entryTitle,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff414751))),*/
              ],
            ),
          ),
          // Yorumlar Listesi
          Expanded(
              child: ListView.builder(
            itemCount: entryDetailController.entryComments.length,
            itemBuilder: (context, index) {
              final entry = entryDetailController.entryComments[index];
              return EntryCommentCard(
                entry: entry,
                onDownvote: () {},
                onPressed: () {},
                onShare: () {},
                onUpvote: () {},
              );
            },
          )),
          // Entry Paylaşım kısmı
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Entry paylaşım",
                        hintStyle: GoogleFonts.inter(
                            color: Color(0xff9ca3ae), fontSize: 13.28),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                        fillColor: Color(0xfffafafa),
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFF7743),
                            Color(0xFFEF5050)
                          ], // Linear gradient renkleri
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'images/icons/send_icon.svg',
                          width: 18,
                          height: 18,
                        ),
                      ),
                    ),
                    onPressed: () {
                    
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
