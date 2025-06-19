import 'dart:io';
import 'package:edusocial/utils/date_format.dart';
import 'package:flutter/material.dart';
import '../../../models/chat_models/chat_detail_model.dart';

class MediaMessageWidget extends StatelessWidget {
  final MessageModel message;

  const MediaMessageWidget({super.key, required this.message});

  // Dosya türünü kontrol et
  bool isImageFile(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final lowerUrl = url.toLowerCase();
    return imageExtensions.any((ext) => lowerUrl.endsWith(ext));
  }

  bool isPdfFile(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final rawMediaPath = message.messageMedia.first.path;
    debugPrint('MediaURL: $rawMediaPath');

    // Server'dan gelen URL'leri tamamla
    String mediaUrl;
    if (rawMediaPath.startsWith('http') || rawMediaPath.startsWith('https')) {
      mediaUrl = rawMediaPath;
    } else if (rawMediaPath.startsWith('file://')) {
      mediaUrl = rawMediaPath;
    } else {
      // Server'dan gelen relative path
      mediaUrl = 'https://stageapi.edusocial.pl/storage/$rawMediaPath';
    }

    Widget imageWidget;
    if (mediaUrl.startsWith('file://')) {
      final file = File(Uri.parse(mediaUrl).path);
      if (isImageFile(mediaUrl)) {
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image),
          ),
        );
      } else {
        // Dosya türü resim değilse dosya ikonu göster
        imageWidget = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                isPdfFile(mediaUrl) ? Icons.picture_as_pdf : Icons.insert_drive_file,
                size: 32,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                mediaUrl.split('/').last,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
    } else {
      if (isImageFile(mediaUrl)) {
        imageWidget = Padding(
          padding: const EdgeInsets.all(3.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.network(
                mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              ),
            ),
          ),
        );
      } else {
        // Dosya türü resim değilse dosya ikonu göster
        imageWidget = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                isPdfFile(mediaUrl) ? Icons.picture_as_pdf : Icons.insert_drive_file,
                size: 32,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                mediaUrl.split('/').last,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
    }

    return Column(
      children: [
        if (message.isMe == true)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 🔹 **Mesaj Saati**
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  formatSimpleDateClock(
                      message.createdAt), // Buraya mesaj saatini ekliyoruz
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
              Text(
                '${message.sender.name} ${message.sender.surname}', // Buraya mesaj saatini ekliyoruz
                style: TextStyle(fontSize: 10, color: Color(0xff414751)),
              ),
              SizedBox(
                width: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: (message.senderAvatarUrl != null &&
                          message.senderAvatarUrl!.isNotEmpty &&
                          !message.senderAvatarUrl!.endsWith('/0'))
                      ? NetworkImage(message.senderAvatarUrl!)
                      : null,
                  child: (message.senderAvatarUrl == null ||
                          message.senderAvatarUrl!.isEmpty ||
                          message.senderAvatarUrl!.endsWith('/0'))
                      ? const Icon(Icons.person, color: Colors.white, size: 14)
                      : null,
                ),
              ),
            ],
          ),
        if (message.isMe == false)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: (message.senderAvatarUrl != null &&
                          message.senderAvatarUrl!.isNotEmpty &&
                          !message.senderAvatarUrl!.endsWith('/0'))
                      ? NetworkImage(message.senderAvatarUrl!)
                      : null,
                  child: (message.senderAvatarUrl == null ||
                          message.senderAvatarUrl!.isEmpty ||
                          message.senderAvatarUrl!.endsWith('/0'))
                      ? const Icon(Icons.person, color: Colors.white, size: 14)
                      : null,
                ),
              ),
              Text(
                '${message.sender.name} ${message.sender.surname}', // Buraya mesaj saatini ekliyoruz
                style: TextStyle(fontSize: 10, color: Color(0xff414751)),
              ),
              SizedBox(
                width: 5,
              ),

              // 🔹 **Mesaj Saati**
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  formatSimpleDateClock(
                      message.createdAt), // Buraya mesaj saatini ekliyoruz
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 35),
          child: Align(
            alignment:
                message.isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: message.isMe ? Color(0xFFFF7C7C) : Color(0xffffffff),
                borderRadius: message.isMe
                    ? BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16))
                    : BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageWidget,
                  if (message.message.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        message.message,
                        style:  TextStyle(fontSize: 12,color: message.isMe ? Color(0xffffffff) : Color(0xff414751),),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
