import 'package:flutter/material.dart';

import '../../components/user_appbar/user_appbar.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserAppBar(),
      backgroundColor: const Color(0xffFAFAFA),
      body: const Center(
        child: Text("Chat"),
      ),
    );
  }
}
