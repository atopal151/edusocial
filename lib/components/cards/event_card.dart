import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/search_text_controller.dart';
import '../buttons/custom_button.dart';
import '../buttons/icon_button.dart';
import '../widgets/tree_point_bottom_sheet.dart';
import '../../services/language_service.dart';

class EventCard extends StatelessWidget {
  final String eventTitle;
  final String eventDescription;
  final String eventDate;
  final String eventImage;
  final VoidCallback onShare;
  final VoidCallback onLocation;

  const EventCard({
    super.key,
    required this.eventTitle,
    required this.eventDescription,
    required this.eventDate,
    required this.eventImage,
    required this.onShare,
    required this.onLocation,
  });

  @override
  Widget build(BuildContext context) {
    final SearchTextController controller = Get.find();
    final LanguageService languageService = Get.find<LanguageService>();

    return Card(
      elevation: 0,
      color: const Color(0xffffffff),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etkinlik görseli ve üst ikonlar
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
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
                        colorFilter: const ColorFilter.mode(
                          Color(0xff9ca3ae),
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        Get.snackbar(
                            languageService.tr("events.notification.title"),
                            languageService.tr("events.notification.message"));
                      },
                    ),
                    const SizedBox(width: 8),
                    buildIconButton(
                      SvgPicture.asset(
                        "images/icons/tree_dot_column.svg",
                        colorFilter: const ColorFilter.mode(
                          Color(0xff9ca3ae),
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(25)),
                          ),
                          builder: (context) => const TreePointBottomSheet(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Etkinlik Detayları
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      "images/icons/calendar_icon.svg",
                      colorFilter: const ColorFilter.mode(
                        Color(0xff9ca3ae),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      eventDate,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xff9ca3ae),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  eventTitle,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff414751),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  eventDescription,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff9ca3ae),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CustomButton(
                        height: 40,
                        borderRadius: 15,
                        text: languageService.tr("common.buttons.share"),
                        onPressed: () {
                          final String shareText = """
$eventTitle

$eventDescription

📱 EduSocial Uygulamasını İndir:
🔗 Uygulamayı Aç: edusocial://app
📲 App Store: https://apps.apple.com/app/edusocial/id123456789
📱 Play Store: https://play.google.com/store/apps/details?id=com.edusocial.app

#EduSocial #Eğitim
""";
                          Share.share(shareText);
                        },
                        icon: SvgPicture.asset(
                          "images/icons/share.svg",
                          colorFilter: const ColorFilter.mode(
                            Color(0xffed7474),
                            BlendMode.srcIn,
                          ),
                        ),
                        textColor: const Color(0xffed7474),
                        iconColor: const Color(0xffef8181),
                        isLoading: controller.isSeLoading,
                        backgroundColor: const Color(0xfffff6f6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        height: 40,
                        borderRadius: 15,
                        text:
                            languageService.tr("event.eventCard.viewLocation"),
                        onPressed: onLocation,
                        icon: SvgPicture.asset(
                          "images/icons/location.svg",
                          colorFilter: const ColorFilter.mode(
                            Color(0xfffff6f6),
                            BlendMode.srcIn,
                          ),
                        ),
                        textColor: const Color(0xfffff6f6),
                        iconColor: const Color(0xfffff6f6),
                        isLoading: controller.isSeLoading,
                        backgroundColor: const Color(0xfffb535c),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
