import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/search_text_controller.dart';
import '../buttons/icon_button.dart';
import '../widgets/share_bottom_sheet.dart';
import '../widgets/tree_point_bottom_sheet.dart';

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
    return Card(
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
                    buildIconButton(
                        SvgPicture.asset(
                          "images/icons/notification_group.svg",
                          colorFilter: ColorFilter.mode(
                            Color(0xff9ca3ae),
                            BlendMode.srcIn,
                          ),
                        ), onPressed: () {
                      Get.snackbar("Bildirim", "Etkinlik bildirimi ayarlandı.");
                    }),
                    SizedBox(width: 8),
                    buildIconButton(
                        SvgPicture.asset(
                          "images/icons/tree_dot_column.svg",
                          colorFilter: ColorFilter.mode(
                            Color(0xff9ca3ae),
                            BlendMode.srcIn,
                          ),
                        ), onPressed: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.white,
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        builder: (context) => const TreePointBottomSheet(),
                      );
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
                   SvgPicture.asset(
                          "images/icons/calendar_icon.svg",
                          colorFilter: ColorFilter.mode(
                            Color(0xff9ca3ae),
                            BlendMode.srcIn,
                          ),
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
                        height: 40,
                        borderRadius: 15,
                        text: "Paylaş",
                        onPressed: () {
                          final String shareText =
                              "$eventTitle : \n\n$eventDescription";
                          showModalBottomSheet(
                            backgroundColor: Colors.white,
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25)),
                            ),
                            builder: (_) =>
                                ShareOptionsBottomSheet(postText: shareText),
                          );
                        },
                        icon: SvgPicture.asset(
                          "images/icons/share.svg",
                          colorFilter: const ColorFilter.mode(
                            Color(0xffed7474),
                            BlendMode.srcIn,
                          ),
                        ),
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
                          height: 40,
                          borderRadius: 15,
                          text: "Konumu Gör",
                          icon: SvgPicture.asset(
                            "images/icons/location.svg",
                            colorFilter: const ColorFilter.mode(
                              Color(0xfffff6f6),
                              BlendMode.srcIn,
                            ),
                          ),
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
    );
  }
}
