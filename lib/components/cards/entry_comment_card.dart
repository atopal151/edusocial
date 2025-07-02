import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/entry_model.dart';
import '../../services/language_service.dart';
import 'package:get/get.dart';

class EntryCommentCard extends StatelessWidget {
  final EntryModel entry;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onShare;
  final VoidCallback onPressed;

  const EntryCommentCard(
      {super.key,
      required this.entry,
      required this.onUpvote,
      required this.onDownvote,
      required this.onShare,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.content,
              style: GoogleFonts.inter(fontSize: 12, color: Color(0xff9ca3ae)),
            ),
            const SizedBox(height: 10),
            //  Beğeni, Beğenmeme, Paylaş
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Oy verme butonları
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        onUpvote();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: (entry.islike ?? false)
                              ? Color(0xFF4CAF50).withAlpha(50)
                              : const Color(0xfff6f6f6),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: (entry.islike ?? false)
                              ? Color(0xFF4CAF50)
                              : const Color(0xff414751),
                          size: 18,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      entry.upvotescount.toString(),
                      style: GoogleFonts.inter(fontSize: 10, color: Color(0xff9ca3ae)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        onDownvote();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: (entry.isdislike ?? false)
                              ? Color(0xFFEF5050).withAlpha(50)
                              : const Color(0xfff6f6f6),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: (entry.isdislike ?? false)
                              ? Color(0xFFEF5050)
                              : const Color(0xff414751),
                          size: 18,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      entry.downvotescount.toString(), // downvotes_count kullanıldı
                      style: GoogleFonts.inter(fontSize: 10, color: Color(0xff9ca3ae)),
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                // Paylaş
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        onShare(); // Fonksiyon çağrısı eklendi
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xfff6f6f6),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: const Icon(Icons.share, color: Color(0xff9ca3ae), size: 15), // SvgPicture yerine Icon kullanıldı
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      Get.find<LanguageService>().tr("common.buttons.share"),
                      style: GoogleFonts.inter(fontSize: 10, color: Color(0xff9ca3ae)),
                    ),
                  ],
                ),

                // Kullanıcı bilgileri
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              entry.user.name,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xff414751)),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  entry.humancreatedat,
                                  style: GoogleFonts.inter(
                                      color: Color(0xff9ca3ae), fontSize: 10),
                                ),
                               
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 12,
                                        backgroundColor: Color(0xfffafafa),

                        backgroundImage: NetworkImage(entry.user.avatarUrl),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
