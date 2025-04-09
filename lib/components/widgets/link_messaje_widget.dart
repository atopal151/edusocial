import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/chat_detail_model.dart';

class LinkMessageWidget extends StatelessWidget {
  final MessageModel message;

  const LinkMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launch(message.content),
      child: Align(
        alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            message.content,
            style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          ),
        ),
      ),
    );
  }
}
