import 'package:edusocial/models/chat_models/chat_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:edusocial/components/widgets/chat_widget/universal_message_widget.dart';
import 'package:edusocial/controllers/chat_controllers/chat_detail_controller.dart';


class MessageWidgetFactory {
  static Widget buildMessageWidget(MessageModel message, ChatDetailController controller) {
    // Tüm mesaj tipleri için UniversalMessageWidget kullan
    return UniversalMessageWidget(message: message, controller: controller);
  }
}
