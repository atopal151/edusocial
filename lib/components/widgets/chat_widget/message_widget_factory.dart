import 'package:edusocial/models/chat_models/chat_detail_model.dart';
import 'package:flutter/material.dart';
import 'poll_message_widget.dart';
import 'link_media_text_message_widget.dart';

class MessageWidgetFactory {
  static Widget buildMessageWidget(MessageModel message) {
    if (message.message.contains("poll")) {
      // Sadece örnek, anket için farklı alan veya type varsa oraya bağlayabilirsin
      return PollMessageWidget(message: message);
    } else {
      return LinkMediaTextMessageWidget(message: message);
    }
  }
}
