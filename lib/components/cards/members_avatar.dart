import 'package:flutter/material.dart';

Widget buildMemberAvatars(List<String> imageUrls) {
  int displayCount = 5;
  double overlap = 20;

  // Boş olmayan avatar URL'lerini filtrele
  final validImageUrls = imageUrls.where((url) => url.isNotEmpty).toList();

  return SizedBox(
    height: 40,
    child: Stack(
      children: [
        for (int i = 0; i < validImageUrls.length && i < displayCount; i++)
          Positioned(
            left: i * overlap,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(validImageUrls[i]),
                onBackgroundImageError: (exception, stackTrace) {
                  // Hata durumunda varsayılan ikon göster
                },
                child: validImageUrls[i].isEmpty 
                    ? Icon(Icons.person, size: 16, color: Color(0xff9ca3ae))
                    : null,
              ),
            ),
          ),
        if (validImageUrls.length > displayCount)
          Positioned(
            left: displayCount * overlap,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  '+${validImageUrls.length - displayCount}',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700,color: Color(0xff414751)),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}