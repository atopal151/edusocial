import 'package:edusocial/models/chat_models/chat_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:edusocial/components/widgets/chat_widget/link_media_text_message_widget.dart';
import 'package:edusocial/components/widgets/chat_widget/text_message_widget.dart';
import 'package:edusocial/components/widgets/chat_widget/link_messaje_widget.dart';
import 'package:edusocial/components/widgets/chat_widget/document_message_widget.dart';


class MessageWidgetFactory {
  static Widget buildMessageWidget(MessageModel message) {
         // Media içinde document vs image ayrımı
     bool hasDocumentInMedia = false;
     bool hasImageInMedia = false;
     
     if (message.messageMedia.isNotEmpty) {
       for (var media in message.messageMedia) {
         final mediaPath = media.path.toLowerCase();
         
         // Document kontrolü
         if (mediaPath.endsWith('.pdf') ||
             mediaPath.endsWith('.doc') ||
             mediaPath.endsWith('.docx') ||
             mediaPath.endsWith('.txt')) {
           hasDocumentInMedia = true;
         }
         // Image kontrolü  
         else if (mediaPath.endsWith('.jpg') ||
                  mediaPath.endsWith('.jpeg') ||
                  mediaPath.endsWith('.png') ||
                  mediaPath.endsWith('.gif') ||
                  mediaPath.endsWith('.webp') ||
                  mediaPath.contains('image_picker') ||
                  mediaPath.contains('user-chats/')) {
           hasImageInMedia = true;
         }
       }
     }
     
     // Document mesajları (messageDocument field'ında veya messageMedia'da document)
     if ((message.messageDocument?.isNotEmpty ?? false) || hasDocumentInMedia) {
       return DocumentMessageWidget(message: message);
     }
     // Image mesajları (messageMedia'da image var ama document yok)
     else if (hasImageInMedia && !hasDocumentInMedia) {
       return LinkMediaTextMessageWidget(message: message);
     }
     // Media + Link + Text mesajları
     else if (message.messageMedia.isNotEmpty && message.messageLink.isNotEmpty) {
       return LinkMediaTextMessageWidget(message: message);
     }
     // Sadece media mesajları
     else if (message.messageMedia.isNotEmpty) {
       return LinkMediaTextMessageWidget(message: message);
     }
    // Sadece link mesajları
    else if (message.messageLink.isNotEmpty) {
      return LinkMessageWidget(message: message);
    }
    
    // Normal text mesajları (URL içeren)
    else if (message.message.isNotEmpty) {
      // Check if the message content contains a URL
      final urlRegex = RegExp(
        r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
        caseSensitive: false,
      );
      
      if (urlRegex.hasMatch(message.message)) {
        // URL içeren text mesajları için LinkMessageWidget kullan
        return LinkMessageWidget(message: message);
      }
      
      // Normal text mesajları için TextMessageWidget kullan
      return TextMessageWidget(message: message);
    }
    
    // Fallback
    return TextMessageWidget(message: message);
  }
}
