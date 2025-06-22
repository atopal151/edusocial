import 'package:edusocial/models/chat_models/chat_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edusocial/components/widgets/chat_widget/link_media_text_message_widget.dart';
import 'package:edusocial/components/widgets/chat_widget/text_message_widget.dart';
import 'package:edusocial/components/widgets/chat_widget/link_messaje_widget.dart';
import 'package:edusocial/components/widgets/chat_widget/document_message_widget.dart';
import 'package:edusocial/components/widgets/chat_widget/poll_message_widget.dart';

class MessageWidgetFactory {
  static Widget buildMessageWidget(MessageModel message) {
    // Media + Link + Text mesajları
    if (message.messageMedia.isNotEmpty && message.messageLink.isNotEmpty) {
      return LinkMediaTextMessageWidget(message: message);
    }
    // Sadece media mesajları
    else if (message.messageMedia.isNotEmpty) {
      return LinkMediaTextMessageWidget(message: message);
    }
    // Document mesajları
    else if (message.messageDocument?.isNotEmpty ?? false) {
      return DocumentMessageWidget(message: message);
    }
    // Sadece link mesajları
    else if (message.messageLink.isNotEmpty) {
      return LinkMessageWidget(message: message);
    }
    // Poll mesajları (mesaj içeriğinde [POLL] varsa)
    else if (message.message.contains('[POLL]')) {
      return PollMessageWidget(message: message);
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
