import 'package:edusocial/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/entry_model.dart';
import '../../models/user_model.dart';
import '../../services/language_service.dart';
import 'package:get/get.dart';

/// PersonEntryCard - Profil ekranları için özel entry kartı
/// 
/// Bu component, kullanıcı bilgilerini dışarıdan alır ve profil ekranlarında
/// kullanılmak üzere tasarlanmıştır. Normal EntryCard'dan farklı olarak,
/// kullanıcı bilgileri (UserModel) zorunlu parametre olarak alınır.
/// 
/// Kullanım örneği:
/// ```dart
/// PersonEntryCard(
///   entry: entryModel,
///   user: userModel, // Kullanıcı bilgileri dışarıdan verilir
///   onPressed: () => print('Entry tıklandı'),
///   onUpvote: () => print('Beğenildi'),
///   onDownvote: () => print('Beğenilmedi'),
///   onShare: () => print('Paylaşıldı'),
/// )
/// ```

class PersonEntryCard extends StatelessWidget {
  final EntryModel entry;
  final UserModel user; // Kullanıcı bilgileri dışarıdan alınacak
  final String? topicName;
  final String? categoryTitle;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onShare;
  final VoidCallback onPressed;
  final VoidCallback? onPressedProfile;

  const PersonEntryCard({
    super.key,
    required this.entry,
    required this.user, // Kullanıcı bilgileri zorunlu
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
    // Debug: Avatar bilgilerini kontrol et
    //debugPrint("🖼️ PersonEntryCard - Avatar Debug:");
    //debugPrint("  - User ID: ${user.id}");
    //debugPrint("  - User Name: ${user.name} ${user.surname}");
    //debugPrint("  - Avatar URL: '${user.avatarUrl}'");
    //debugPrint("  - Avatar URL boş mu: ${user.avatarUrl.isEmpty}");
    //debugPrint("  - Avatar URL uzunluğu: ${user.avatarUrl.length}");
    
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
                        radius: 20,
                        backgroundColor: Color(0xfffafafa),
                        backgroundImage: user.avatarUrl.isNotEmpty
                            ? NetworkImage(user.avatarUrl)
                            : null,
                        onBackgroundImageError: user.avatarUrl.isNotEmpty
                            ? (exception, stackTrace) {
                                debugPrint("❌ Profil resmi yüklenemedi: ${user.avatarUrl}");
                                debugPrint("❌ Hata: $exception");
                              }
                            : null,
                        child: user.avatarUrl.isEmpty
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
                          color: user.isOnline
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

                // Kullanıcı Adı ve Tarih
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: onPressedProfile,
                      child: Text(
                        "${user.name} ${user.surname}",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Color(0xff414751)),
                      ),
                    ),
                    InkWell(
                      onTap: onPressedProfile,
                      child: Text(
                        "@${user.username}",
                        style: GoogleFonts.inter(
                            color: Color(0xff9ca3ae), fontSize: 10),
                      ),
                    ),
                    Text(
                      formatSimpleDateClock(entry.humancreatedat),
                      style: GoogleFonts.inter(
                          color: Color(0xff9ca3ae), fontSize: 10),
                    ),
                  ],
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
          ],
        ),
      ),
    );
  }
} 