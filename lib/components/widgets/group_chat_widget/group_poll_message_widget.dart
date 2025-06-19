import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../models/chat_models/group_message_model.dart';

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
    // 📌 `DateTime` → `String` formatına çeviriyoruz
    String formattedTime = DateFormat('dd.MM.yyyy HH:mm').format(message.timestamp);
    
    return Column(
      crossAxisAlignment: message.isSentByMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // 🔹 Kullanıcı Bilgileri ve Saat
        Row(
          mainAxisAlignment:
              message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!message.isSentByMe)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: (message.profileImage.isNotEmpty &&
                          !message.profileImage.endsWith('/0'))
                      ? NetworkImage(message.profileImage)
                      : null,
                  child: (message.profileImage.isEmpty ||
                          message.profileImage.endsWith('/0'))
                      ? const Icon(Icons.person, color: Colors.white, size: 14)
                      : null,
                ),
              ),
            Text(
              '${message.name} ${message.surname}',
              style: const TextStyle(fontSize: 10, color: Color(0xff414751)),
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                formattedTime,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
            if (message.isSentByMe)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: (message.profileImage.isNotEmpty &&
                          !message.profileImage.endsWith('/0'))
                      ? NetworkImage(message.profileImage)
                      : null,
                  child: (message.profileImage.isEmpty ||
                          message.profileImage.endsWith('/0'))
                      ? const Icon(Icons.person, color: Colors.white, size: 14)
                      : null,
                ),
              ),
          ],
        ),
        // 🔹 Mesaj Balonu
        Align(
          alignment: message.isSentByMe
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isSentByMe ? const Color(0xFFFF7C7C) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: message.isSentByMe
                    ? const Radius.circular(20)
                    : const Radius.circular(0),
                topRight: message.isSentByMe
                    ? const Radius.circular(0)
                    : const Radius.circular(20),
                bottomLeft: const Radius.circular(20),
                bottomRight: const Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    color: message.isSentByMe ? Colors.white : const Color(0xff414751),
                  ),
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
                                        Text(
                                          option,
                                          style: const TextStyle(
                                            color: Color(0xff9ca3ae),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${pollVotes[option] ?? 0} oy',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
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
        ),
      ],
    );
  }
}
