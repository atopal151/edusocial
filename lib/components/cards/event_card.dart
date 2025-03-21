import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/search_text_controller.dart';

class EventCard extends StatelessWidget {
  final String eventTitle;
  final String eventDescription;
  final String eventDate;
  final String eventImage;
  final VoidCallback onShare;
  final VoidCallback onLocation;

  const EventCard(
      {super.key,
      required this.eventTitle,
      required this.eventDescription,
      required this.eventDate,
      required this.eventImage,
      required this.onShare,
      required this.onLocation});

  @override
  Widget build(BuildContext context) {
    final SearchTextController controller = Get.find();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0,
        color: Color(0xffffffff),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Image.asset(eventImage),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 10,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Text(eventDate,
                          style: TextStyle(
                              fontSize: 10, color: Color(0xff9ca3ae))),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(eventTitle,
                      style:
                          TextStyle(fontSize: 13.28, fontWeight: FontWeight.w600)),
                  Text(eventDescription,
                      style: TextStyle(fontSize: 10, color: Color(0xff414751),fontWeight: FontWeight.w500)),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: "Paylaş",
                          onPressed: onShare,
                          icon: Icons.share,
                          textColor: Color(0xffed7474),
                          iconColor: Color(0xffef8181),
                          isLoading: controller.isSeLoading,
                          backgroundColor: Color(0xfffff6f6),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: CustomButton(
                            text: "Konumu Gör",
                            icon: Icons.location_pin,
                            iconColor: Color(0xfffff6f6),
                            onPressed: onLocation,
                            isLoading: controller.isSeLoading,
                            textColor: Color(0xfffff6f6),
                            backgroundColor: Color(0xfffb535c)),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
