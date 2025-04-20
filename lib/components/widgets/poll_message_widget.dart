import 'package:flutter/material.dart';
import '../../models/chat_detail_model.dart';

class PollMessageWidget extends StatelessWidget {
  final MessageModel message;

  const PollMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 250,
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
            topLeft:
                message.isSentByMe ? Radius.circular(15) : Radius.circular(0),
            topRight:
                message.isSentByMe ? Radius.circular(0) : Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.content,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    color: Color(0xff414751))),
            SizedBox(height: 10),
            ...?message.pollOptions?.map((option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffe2e5ea), // 👈 burada rengi veriyoruz
                        width: 1, // opsiyonel: kalınlık
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle_outlined,
                            size: 17,
                            color: Color(0xffe2e5ea),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                              child: Text(
                            option,
                            style: TextStyle(color: Color(0xff9ca3ae),fontSize: 10,fontWeight: FontWeight.w400),
                          )),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
