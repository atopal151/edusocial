import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/search_text_controller.dart';
import '../buttons/icon_button.dart';

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
           
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    eventImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      buildIconButton(Icons.notifications, onPressed: () {
                        Get.snackbar(
                            "Bildirim", "Etkinlik bildirimi ayarlandı.");
                      }),
                      SizedBox(width: 8),
                      buildIconButton(Icons.more_vert, onPressed: () {
                        Get.snackbar("Aksiyon", "Daha fazla seçenek");
                      }),
                    ],
                  ),
                ),
              ],
            ),
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
                          style: GoogleFonts.inter(
                              fontSize: 10, color: Color(0xff9ca3ae))),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(eventTitle,
                      style: GoogleFonts.inter(
                          fontSize: 13.28, fontWeight: FontWeight.w600)),
                  Text(eventDescription,
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Color(0xff414751),
                          fontWeight: FontWeight.w500)),
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
