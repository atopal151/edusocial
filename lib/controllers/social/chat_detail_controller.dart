import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/chat_detail_model.dart';
class ChatDetailController extends GetxController {
  RxList<MessageModel> messages = <MessageModel>[].obs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    simulateIncomingMessages();
  }

  void sendMessage(String text) {
    messages.add(MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: "me",
      receiverId: "user123",
      content: text,
      messageType: MessageType.text,
      timestamp: DateTime.now(),
      isSentByMe: true,
    ));
      scrollToBottom();
  }

 void scrollToBottom() {
  if (scrollController.hasClients) {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}


  void simulateIncomingMessages() {
    Timer.periodic(Duration(seconds: 10), (timer) {
      messages.add(MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: "user123",
        receiverId: "me",
        content: "Bu otomatik gelen bir mesajdır.",
        messageType: MessageType.text,
        timestamp: DateTime.now(),
        isSentByMe: false,
      ));
      scrollToBottom();
    });
    
  }
  
}
