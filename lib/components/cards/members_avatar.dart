import 'package:flutter/material.dart';

Widget buildMemberAvatars(List<String> imageUrls) {
  int displayCount = 5;
  double overlap = 20;

  return SizedBox(
    height: 40,
    child: Stack(
      children: [
        for (int i = 0; i < imageUrls.length && i < displayCount; i++)
          Positioned(
            left: i * overlap,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(imageUrls[i]),
              ),
            ),
          ),
        if (imageUrls.length > displayCount)
          Positioned(
            left: displayCount * overlap,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  '+${imageUrls.length - displayCount}',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700,color: Color(0xff414751)),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}