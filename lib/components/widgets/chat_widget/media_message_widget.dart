import 'dart:io';
import 'package:edusocial/utils/date_format.dart';
import 'package:flutter/material.dart';
import '../../../models/chat_models/chat_detail_model.dart';
import '../../dialogs/image_preview_dialog.dart';

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

  void _openImagePreview(BuildContext context, String imageUrl) {
    final heroTag = 'private_image_${message.id}';
    
    showImagePreview(
      imageUrl: imageUrl,
      heroTag: heroTag,
      userName: message.sender.name.isNotEmpty ? '${message.sender.name} ${message.sender.surname}' : null,
      timestamp: DateTime.tryParse(message.createdAt),
    );
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

    final heroTag = 'private_image_${message.id}';

    Widget imageWidget;
    if (mediaUrl.startsWith('file://')) {
      final file = File(Uri.parse(mediaUrl).path);
      if (isImageFile(mediaUrl)) {
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: () => _openImagePreview(context, mediaUrl),
            child: Hero(
              tag: heroTag,
              child: Stack(
                children: [
                  Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image, color: Colors.grey[600]),
                        ),
                  ),
                  // Zoom hint overlay
                  Positioned(
                    top: 8,
                    right: 8,
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
              child: GestureDetector(
                onTap: () => _openImagePreview(context, mediaUrl),
                child: Hero(
                  tag: heroTag,
                  child: Stack(
                    children: [
                      Image.network(
                        mediaUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 150,
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
                              height: 150,
                              color: Colors.grey[300],
                              child: Icon(Icons.broken_image, color: Colors.grey[600]),
                            ),
                      ),
                      // Zoom hint overlay
                      Positioned(
                        top: 8,
                        right: 8,
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
             child: Row(
         mainAxisAlignment: message.isMe
             ? MainAxisAlignment.end
             : MainAxisAlignment.start,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           if (!message.isMe) ...[
             // Karşı tarafın profil resmi
             Padding(
               padding: const EdgeInsets.only(right: 8.0, top: 16.0),
               child: CircleAvatar(
                 radius: 16,
                 backgroundColor: Colors.grey[300],
                 backgroundImage: (message.senderAvatarUrl?.isNotEmpty == true &&
                         !message.senderAvatarUrl!.endsWith('/0'))
                     ? NetworkImage(message.senderAvatarUrl!)
                     : null,
                 child: (message.senderAvatarUrl?.isEmpty != false ||
                         message.senderAvatarUrl?.endsWith('/0') == true)
                     ? const Icon(Icons.person, color: Colors.white, size: 18)
                     : null,
               ),
             ),
           ],
           
           // Mesaj balonu
           Flexible(
             child: Container(
               constraints: BoxConstraints(
                 maxWidth: MediaQuery.of(context).size.width * 0.7,
               ),
               decoration: BoxDecoration(
                 color: message.isMe
                     ? const Color(0xFFff7c7c)
                     : Colors.white,
                 borderRadius: BorderRadius.only(
                   topLeft: const Radius.circular(18),
                   topRight: const Radius.circular(18),
                   bottomLeft: message.isMe
                       ? const Radius.circular(18)
                       : const Radius.circular(4),
                   bottomRight: message.isMe
                       ? const Radius.circular(4)
                       : const Radius.circular(18),
                 ),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.1),
                     blurRadius: 4,
                     offset: const Offset(0, 2),
                   ),
                 ],
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   // Media content
                   imageWidget,
                   
                   // Timestamp
                   Padding(
                     padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         Text(
                           formatSimpleDateClock(message.createdAt),
                           style: TextStyle(
                             fontSize: 10,
                             color: message.isMe
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
           
           if (message.isMe) ...[
             // Kendi profil resmimiz
             Padding(
               padding: const EdgeInsets.only(left: 8.0, top: 16.0),
               child: CircleAvatar(
                 radius: 16,
                 backgroundColor: Colors.grey[300],
                 backgroundImage: (message.senderAvatarUrl?.isNotEmpty == true &&
                         !message.senderAvatarUrl!.endsWith('/0'))
                     ? NetworkImage(message.senderAvatarUrl!)
                     : null,
                 child: (message.senderAvatarUrl?.isEmpty != false ||
                         message.senderAvatarUrl?.endsWith('/0') == true)
                     ? const Icon(Icons.person, color: Colors.white, size: 18)
                     : null,
               ),
             ),
           ],
         ],
       ),
    );
  }
}
