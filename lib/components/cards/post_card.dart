import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String profileImage;
  final String userName;
  final String postDate;
  final String postDescription;
  final String? postImage;
  final int likeCount;
  final int commentCount;

  const PostCard({
    super.key,
    required this.profileImage,
    required this.userName,
    required this.postDate,
    required this.postDescription,
    this.postImage,
    required this.likeCount,
    required this.commentCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: BorderRadius.circular(20),
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Üst Kısım (Profil Bilgileri ve Menü İkonu)
          Row(
            children: [
              // Profil Fotoğrafı
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(profileImage),
              ),
              const SizedBox(width: 10),
              
              // Kullanıcı Adı ve Tarih
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xff414751)
                      ),
                      overflow: TextOverflow.ellipsis, // Uzun isimler taşmaz
                    ),
                    Text(
                      postDate,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xff9CA3AE),
                      ),
                    ),
                  ],
                ),
              ),

              // Menü (Üç Nokta) İkonu
              const Icon(Icons.more_horiz, color: Color(0xff414751)),
            ],
          ),
          const SizedBox(height: 8),

          // 🔹 Gönderi Açıklaması
          Text(
            postDescription,
            style: const TextStyle(fontSize: 10,fontWeight: FontWeight.w400,color: Color(0xff414751)),
            maxLines: 10, // Uzun açıklamaları sınırlandır
            overflow: TextOverflow.ellipsis, // Fazlasını "..." olarak göster
          ),
          const SizedBox(height: 8),

          // 🔹 Gönderi Fotoğrafı (Eğer varsa göster)
          if (postImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                postImage!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),

          // 🔹 Beğeni, Yorum, Paylaş
          Row(
            children: [
              // Beğeni Butonu
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red,size: 20,),
                onPressed: () {},
              ),
              Text(
                likeCount.toString(),
                style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w600,color: Color(0xff414751)),
              ),

              const SizedBox(width: 16),

              // Yorum Butonu
              IconButton(
                icon: const Icon(Icons.chat_bubble, color: Colors.grey,size: 20,),
                onPressed: () {},
              ),
              Text(
                commentCount.toString(),
                style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w600,color: Color(0xff414751)),
              ),

              const Spacer(),

              // Paylaşım Butonu
              IconButton(
                icon: const Icon(Icons.share, color: Colors.grey),
                onPressed: () {},
              ),
              const Text(
                "Paylaş",
                style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: Color(0xff414751)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
