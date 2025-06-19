import 'package:edusocial/models/chat_models/chat_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edusocial/components/widgets/chat_widget/link_media_text_message_widget.dart';

class MessageWidgetFactory {
  static Widget buildMessageWidget(MessageModel message) {
    if (message.messageMedia.isNotEmpty) {
      return LinkMediaTextMessageWidget(message: message);
    } else if (message.messageDocument?.isNotEmpty ?? false) {
      return LinkMediaTextMessageWidget(message: message);
    } else if (message.messageLink.isNotEmpty) {
      return LinkMediaTextMessageWidget(message: message);
    } else {
      // Check if the message content contains a URL
      final urlRegex = RegExp(
        r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
        caseSensitive: false,
      );
      
      if (urlRegex.hasMatch(message.message)) {
        // Convert text message with URL to link message
        final urlMatch = urlRegex.firstMatch(message.message)!;
        final url = urlMatch.group(0)!;
        
        return InkWell(
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
          child: LinkMediaTextMessageWidget(message: message),
        );
      }
      
      return LinkMediaTextMessageWidget(message: message);
    }
  }
}
