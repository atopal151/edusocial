import 'package:edusocial/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/entry_model.dart';
import 'package:get/get.dart';
import '../../services/language_service.dart';
import '../widgets/verification_badge.dart';

class EntryCard extends StatelessWidget {
  final EntryModel entry;
  final String? topicName;
  final String? categoryTitle;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onShare;
  final VoidCallback onPressed;
  final VoidCallback? onPressedProfile;

  const EntryCard({
    super.key,
    required this.entry,
    this.topicName,
    this.categoryTitle,
    required this.onUpvote,
    required this.onDownvote,
    required this.onShare,
    required this.onPressed,
    this.onPressedProfile,
  });

  @override
  Widget build(BuildContext context) {
    // En son oy verme zamanını bul (created_at bazlı)
    final DateTime? lastVoteCreatedAt = entry.votes.isNotEmpty
        ? entry.votes
            .where((v) => v.createdat != null)
            .map((v) => v.createdat!)
            .fold<DateTime?>(null, (prev, dt) => prev == null ? dt : (dt.isAfter(prev) ? dt : prev))
        : null;

    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Kısım (Profil Bilgileri)
            Row(
              children: [
                // Profil Fotoğrafı + Çevrimiçi Durumu
                Stack(
                  children: [
                    InkWell(
                      onTap: onPressedProfile,
                      child: CircleAvatar(
                        backgroundColor: Color(0xfffafafa),
                        radius: 20,
                        backgroundImage: entry.user.avatarUrl.isNotEmpty
                            ? NetworkImage(entry.user.avatarUrl)
                            : null,
                        onBackgroundImageError: entry.user.avatarUrl.isNotEmpty
                            ? (exception, stackTrace) {
                                debugPrint(
                                    "❌ Profil resmi yüklenemedi: ${entry.user.avatarUrl}");
                                debugPrint("❌ Hata: $exception");
                              }
                            : null,
                        child: entry.user.avatarUrl.isEmpty
                            ? const Icon(Icons.person, size: 20)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: entry.user.isOnline
                              ? Color(0xFF4CAF50)
                              : Color(0xFF9E9E9E),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),

                // İsim Soyisim ve Username
                InkWell(
                  onTap: onPressedProfile,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Surname (üstte)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              '${entry.user.name} ${entry.user.surname}',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: const Color(0xff414751),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                          VerificationBadge(
                            isVerified: entry.user.isVerified ?? false,
                            size: 14.0,
                          ),
                        ],
                      ),
                      // Username (altta)
                      Text(
                        '@${entry.user.username}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff9CA3AE),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),

            //  Entry Başlığı
            Text(
              topicName ?? entry.topic?.name ?? "Başlıksız",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.28,
                  color: Color(0xff414751)),
            ),
            const SizedBox(height: 6),

            //  Entry Açıklaması
            Text(
              entry.content,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Color(0xff9ca3ae),
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),

            //  Beğeni, Beğenmeme, Paylaş
            Row(
              children: [
                IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                        color: (entry.islike ?? false)
                            ? Colors.green.withAlpha(50)
                            : const Color(0xfff6f6f6),
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: (entry.islike ?? false)
                          ? Colors.green
                          : const Color(0xff414751),
                      size: 18,
                    ),
                  ),
                  onPressed: onUpvote,
                ),
                Text(
                  entry.upvotescount.toString(),
                  style: GoogleFonts.inter(fontSize: 10),
                ),
                IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                        color: (entry.isdislike ?? false)
                            ? Colors.red.withAlpha(50)
                            : const Color(0xfff6f6f6),
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: (entry.isdislike ?? false)
                          ? Colors.red
                          : const Color(0xff414751),
                      size: 18,
                    ),
                  ),
                  onPressed: onDownvote,
                ),
                Expanded(
                  child: Text(
                    entry.downvotescount.toString(),
                    style: GoogleFonts.inter(fontSize: 10),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                          color: Color(0xfff6f6f6),
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: SvgPicture.asset(
                        "images/icons/share.svg",
                        colorFilter: const ColorFilter.mode(
                          Color(0xff9ca3ae),
                          BlendMode.srcIn,
                        ),
                        height: 10,
                        width: 10,
                      ),
                    ),
                    onPressed: onShare,
                  ),
                ),
                Expanded(
                  child: Text(
                    Get.find<LanguageService>().tr("common.buttons.share"),
                    style: GoogleFonts.inter(
                        fontSize: 10, color: Color(0xff9ca3ae)),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),
                //  Kategori Butonu
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
                      categoryTitle ??
                          entry.topic?.category?.title ??
                          "Kategori Yok",
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Color(0xff9ca3ae)),
                    ),
                  ),
                )
              ],
            ),
            
            // 🔹 Paylaşım tarihi (oy verme butonlarının altında)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                lastVoteCreatedAt != null
                    ? formatSimpleDateClock(lastVoteCreatedAt.toIso8601String())
                    : '',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff9CA3AE),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
