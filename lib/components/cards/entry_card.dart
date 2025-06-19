import 'package:edusocial/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/entry_model.dart';

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
                        backgroundImage: entry.user.avatarUrl.isNotEmpty
                            ? NetworkImage(entry.user.avatarUrl)
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
                          color: entry.user.isOnline ? Colors.green : Colors.grey,
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
                    Text(
                      entry.user.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Color(0xff414751)),
                    ),
                    Text(
                      formatSimpleDateClock(entry.human_created_at),
                      style: const TextStyle(
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
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.28,
                  color: Color(0xff414751)),
            ),
            const SizedBox(height: 6),

            //  Entry Açıklaması
            Text(
              entry.content,
              style: const TextStyle(
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
                        color: (entry.is_like ?? false)
                            ? Colors.green.withAlpha(50)
                            : const Color(0xfff6f6f6),
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: (entry.is_like ?? false)
                          ? Colors.green
                          : const Color(0xff414751),
                      size: 18,
                    ),
                  ),
                  onPressed: onUpvote,
                ),
                Text(
                  entry.upvotes_count.toString(),
                  style: const TextStyle(fontSize: 10),
                ),
                IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                        color: (entry.is_dislike ?? false)
                            ? Colors.red.withAlpha(50)
                            : const Color(0xfff6f6f6),
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: (entry.is_dislike ?? false)
                          ? Colors.red
                          : const Color(0xff414751),
                      size: 18,
                    ),
                  ),
                  onPressed: onDownvote,
                ),
                Expanded(
                  child: Text(
                    entry.downvotes_count.toString(),
                    style: const TextStyle(fontSize: 10),
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
                  child: const Text(
                    "Paylaş",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
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
                      categoryTitle ?? entry.topic?.category?.title ?? "Kategori Yok",
                      style: TextStyle(fontSize: 12, color: Color(0xff9ca3ae)),
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
