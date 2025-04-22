import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/chat_detail_model.dart';

class PollMessageWidget extends StatelessWidget {
  final MessageModel message;
  final RxMap<String, int> pollVotes;
  final RxString selectedOption;
  final Function(String) onVote;

  const PollMessageWidget({
    super.key,
    required this.message,
    required this.pollVotes,
    required this.selectedOption,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 250,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: const Radius.circular(15),
            bottomRight: const Radius.circular(15),
            topLeft:
                message.isSentByMe ? const Radius.circular(15) : Radius.zero,
            topRight:
                message.isSentByMe ? Radius.zero : const Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.content,
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    color: Color(0xff414751))),
            const SizedBox(height: 10),
            ...?message.pollOptions?.map((option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Obx(() => GestureDetector(
                        onTap: () {
                          if (selectedOption.value.isEmpty) {
                            onVote(option);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedOption.value == option
                                ? const Color(0xffd1f2eb)
                                : Colors.white,
                            border: Border.all(color: selectedOption.value == option
                                          ? const Color.fromARGB(255, 184, 237, 206)
                                          : const Color(0xffe2e5ea),),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      selectedOption.value == option
                                          ? Icons.circle
                                          : Icons.circle_outlined,
                                      size: 17,
                                      color: selectedOption.value == option
                                          ? const Color(0xff2ecc71)
                                          : const Color(0xff9ca3ae),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(option,
                                        style: const TextStyle(
                                            color: Color(0xff9ca3ae))),
                                  ],
                                ),
                                Text(
                                  '${pollVotes[option] ?? 0} oy',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                )),
          ],
        ),
      ),
    );
  }
}
