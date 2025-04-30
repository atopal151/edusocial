import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../models/group_message_model.dart';

class GroupPollMessageWidget extends StatelessWidget {
  final GroupMessageModel message;
  final RxMap<String, int> pollVotes;
  final RxString selectedOption;
  final Function(String) onVote;

  const GroupPollMessageWidget({
    super.key,
    required this.message,
    required this.pollVotes,
    required this.selectedOption,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('HH:mm').format(message.timestamp);
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
            SizedBox(
              height: 4,
            ),
            if(message.isSentByMe==false)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(message.profileImage),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${message.name} ${message.surname}",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF414751),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formattedTime, // Buraya mesaj saatini ekliyoruz
                  style: GoogleFonts.inter(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(message.content,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: Color(0xff414751))),
            ),
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
                            border: Border.all(
                              color: selectedOption.value == option
                                  ? const Color.fromARGB(255, 184, 237, 206)
                                  : const Color(0xffe2e5ea),
                            ),
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
