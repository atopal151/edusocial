import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/chat_detail_model.dart';
import '../../models/document_model.dart';
import '../../models/link_model.dart';
import '../../models/user_chat_detail_model.dart';

class ChatDetailController extends GetxController {
  RxList<MessageModel> messages = <MessageModel>[].obs;
  final ScrollController scrollController = ScrollController();

  var userChatDetail = Rxn<UserChatDetailModel>();

  @override
  void onInit() {
    super.onInit();
    simulateIncomingMessages();
    loadMockGroupData();
  }

  void loadMockGroupData() {
    userChatDetail.value = UserChatDetailModel(
      id: "user_001",
      name: "Roger Carscraad",
      imageUrl: "https://randomuser.me/api/portraits/men/1.jpg",
      memberImageUrls: [
        "https://randomuser.me/api/portraits/men/1.jpg",
        "https://randomuser.me/api/portraits/men/2.jpg",
        "https://randomuser.me/api/portraits/men/3.jpg",
        "https://randomuser.me/api/portraits/men/4.jpg",
        "https://randomuser.me/api/portraits/men/5.jpg",
        "https://randomuser.me/api/portraits/men/7.jpg",
        "https://randomuser.me/api/portraits/men/6.jpg",
        "https://randomuser.me/api/portraits/men/2.jpg",
        "https://randomuser.me/api/portraits/men/8.jpg",
        "https://randomuser.me/api/portraits/men/9.jpg",
        "https://randomuser.me/api/portraits/men/10.jpg",
        "https://randomuser.me/api/portraits/men/13.jpg",
      ],
       documents: [
        DocumentModel(
          name: "Edusocial.png",
          sizeMb: 3.72,
          date: DateTime(2025, 1, 27),
          url: "https://randomuser.me/api/portraits/men/4.jpg",
        ),
        DocumentModel(
          name: "Edusocial.png",
          sizeMb: 3.72,
          date: DateTime(2025, 1, 27),
          url: "https://randomuser.me/api/portraits/men/4.jpg",
        ),
        DocumentModel(
          name: "Edusocial.png",
          sizeMb: 3.72,
          date: DateTime(2025, 1, 27),
          url: "https://randomuser.me/api/portraits/men/4.jpg",
        ),
        DocumentModel(
          name: "Edusocial.png",
          sizeMb: 3.72,
          date: DateTime(2025, 1, 27),
          url: "https://randomuser.me/api/portraits/men/4.jpg",
        ),
        DocumentModel(
          name: "Edusocial.png",
          sizeMb: 3.72,
          date: DateTime(2025, 1, 27),
          url: "https://randomuser.me/api/portraits/men/4.jpg",
        ),
        DocumentModel(
          name: "Edusocial.png",
          sizeMb: 3.72,
          date: DateTime(2025, 1, 27),
          url: "https://randomuser.me/api/portraits/men/4.jpg",
        ),
      ],
      links: [
        LinkModel(
          title: "github.com",
          url: "https://github.com/monegonllc",
        ),
        LinkModel(
          title: "github.com",
          url: "https://github.com/monegonllc",
        ),
        LinkModel(
          title: "github.com",
          url: "https://github.com/monegonllc",
        ),
        LinkModel(
          title: "github.com",
          url: "https://github.com/monegonllc",
        ),
        LinkModel(
          title: "github.com",
          url: "https://github.com/monegonllc",
        ),
        LinkModel(
          title: "github.com",
          url: "https://github.com/monegonllc",
        ),
      ],
      photoUrls: [
        "https://randomuser.me/api/portraits/men/1.jpg",
        "https://randomuser.me/api/portraits/men/2.jpg",
        "https://randomuser.me/api/portraits/men/3.jpg",
        "https://randomuser.me/api/portraits/men/4.jpg",
        "https://randomuser.me/api/portraits/men/5.jpg",
        "https://randomuser.me/api/portraits/men/6.jpg",
        "https://randomuser.me/api/portraits/men/7.jpg",
        "https://randomuser.me/api/portraits/men/8.jpg",
        "https://randomuser.me/api/portraits/men/9.jpg",
        "https://randomuser.me/api/portraits/men/10.jpg",
        "https://randomuser.me/api/portraits/men/11.jpg",
        "https://randomuser.me/api/portraits/men/12.jpg",
        "https://randomuser.me/api/portraits/men/13.jpg",
        "https://randomuser.me/api/portraits/men/14.jpg",
      ], follower: '500',
      following: '459'
    );
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
