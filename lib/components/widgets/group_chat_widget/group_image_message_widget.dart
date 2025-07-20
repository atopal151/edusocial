import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../models/chat_models/group_message_model.dart';
import '../../dialogs/image_preview_dialog.dart';

class GroupImageMessageWidget extends StatelessWidget {
  final GroupMessageModel message;

  const GroupImageMessageWidget({super.key, required this.message});

  bool isLocalFile(String imagePath) {
    return imagePath.startsWith('/') || imagePath.startsWith('file://');
  }

  void _openImagePreview(BuildContext context) {
    final heroTag = 'group_image_${message.id}';
    
    showImagePreview(
      imageUrl: message.content,
      heroTag: heroTag,
      userName: message.username.isNotEmpty ? '@${message.username}' : null,
      timestamp: message.timestamp,
    );
  }

  @override
  Widget build(BuildContext context) {
    final heroTag = 'group_image_${message.id}';
    
    return Column(
      crossAxisAlignment: message.isSentByMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // 🔹 Kullanıcı Bilgileri (Saat kaldırıldı)
        Row(
          mainAxisAlignment: message.isSentByMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!message.isSentByMe)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 6.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: (message.profileImage.isNotEmpty &&
                          !message.profileImage.endsWith('/0'))
                      ? NetworkImage(message.profileImage)
                      : null,
                  child: (message.profileImage.isEmpty ||
                          message.profileImage.endsWith('/0'))
                      ? const Icon(Icons.person, color: Colors.white, size: 14)
                      : null,
                ),
              ),
           
            Text(
              '@${message.username}',
              style: const TextStyle(fontSize: 10, color: Color(0xff414751)),
            ),
            if (message.isSentByMe)
              Padding(
                padding: const EdgeInsets.only(left: 6.0, right: 8.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: (message.profileImage.isNotEmpty &&
                          !message.profileImage.endsWith('/0'))
                      ? NetworkImage(message.profileImage)
                      : null,
                  child: (message.profileImage.isEmpty ||
                          message.profileImage.endsWith('/0'))
                      ? const Icon(Icons.person, color: Colors.white, size: 14)
                      : null,
                ),
              ),
          ],
        ),

        // 🔹 Mesaj Balonu
        Padding(
          padding: EdgeInsets.only(
            left: message.isSentByMe ? 48.0 : 30.0,
            right: message.isSentByMe ? 30.0 : 48.0,
            top: 2.0,
            bottom: 4.0,
          ),
          child: Align(
            alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: message.isSentByMe 
                    ? const Color(0xFFff7c7c) // Kırmızı
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(18),
                  bottomRight: const Radius.circular(18),
                  topLeft: message.isSentByMe 
                      ? const Radius.circular(18) 
                      : const Radius.circular(4),
                  topRight: message.isSentByMe 
                      ? const Radius.circular(4) 
                      : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // UPDATED: Tappable image with hero animation
                  GestureDetector(
                    onTap: () => _openImagePreview(context),
                    child: Hero(
                      tag: heroTag,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: message.isSentByMe 
                              ? const Radius.circular(18) 
                              : const Radius.circular(4),
                          topRight: message.isSentByMe 
                              ? const Radius.circular(4) 
                              : const Radius.circular(18),
                          bottomLeft: const Radius.circular(12),
                          bottomRight: const Radius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            isLocalFile(message.content)
                                ? Image.file(
                                    File(message.content),
                                    width: 200,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                          width: 200,
                                          height: 150,
                                          color: Colors.grey[300],
                                          child: Icon(Icons.broken_image, color: Colors.grey[600]),
                                        ),
                                  )
                                :                                 Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                        message.content,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            color: Colors.grey[100],
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes!
                                                    : null,
                                                strokeWidth: 2,
                                                color: Color(0xFFff7c7c),
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) =>
                                            Container(
                                              width: 200,
                                              height: 150,
                                              color: Colors.grey[300],
                                              child: Icon(Icons.broken_image, color: Colors.grey[600]),
                                            ),
                                      ),
                                  ),
                                ),
                            
                            // Overlay hint for tap to view
                            Positioned(
                              top: 25,
                              right: 25,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Saat bilgisi mesaj balonunun içinde sağ altta
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0, top: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(message.timestamp),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: message.isSentByMe 
                                ? Colors.white.withValues(alpha: 0.7) 
                                : const Color(0xff9ca3ae),
                          ),
                        ),
                      ],
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
