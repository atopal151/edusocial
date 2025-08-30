import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/buttons/custom_button.dart';

import '../../components/widgets/custom_loading_indicator.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../services/language_service.dart';
import '../../utils/date_format.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventController eventController = Get.find<EventController>();
  final LanguageService languageService = Get.find<LanguageService>();

  @override
  void initState() {
    super.initState();
    final eventId = Get.arguments?['eventId'];
    debugPrint("🔍 Event Detail Screen - Arguments: ${Get.arguments}");
    debugPrint("🔍 Event Detail Screen - Event ID: $eventId");

    if (eventId != null) {
      // Use addPostFrameCallback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint("📞 Calling fetchEventDetail with ID: $eventId");
        eventController.fetchEventDetail(eventId);
      });
    } else {
      debugPrint("❌ No event ID provided in arguments");
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    
    return Obx(() {
      final event = eventController.selectedEvent.value;
      final currentUserId = profileController.userId.value;
      final isEventCreator = event?.userId.toString() == currentUserId;
      
      // Debug logs
      if (event != null) {
        debugPrint("🔍 Event Creator Check:");
        debugPrint("  - Event User ID: ${event.userId} (${event.userId.runtimeType})");
        debugPrint("  - Current User ID: $currentUserId (${currentUserId.runtimeType})");
        debugPrint("  - Event User ID String: '${event.userId.toString()}'");
        debugPrint("  - Current User ID String: '$currentUserId'");
        debugPrint("  - Is Event Creator: $isEventCreator");
      }
      
      return Scaffold(
        backgroundColor: Color(0xfffafafa),
        appBar: AppBar(
          backgroundColor: Color(0xfffafafa),
          surfaceTintColor: Color(0xfffafafa),
          elevation: 0,
          title: Text(
            languageService.tr("event.eventDetail.title"),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xff272727),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xffffffff),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    'images/icons/back_icon.svg',
                  ),
                ),
              ),
            ),
          ),
          // Show edit button only if current user is the event creator
          actions: isEventCreator && event != null ? [
            Container(
              margin: EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () async {
                  // Navigate to edit event screen and wait for result
                  final result = await Get.toNamed('/editEvent', arguments: {'eventId': event.id});
                  
                  // If edit was successful, event detail is already refreshed by EventEditController
                  if (result != null && result['success'] == true) {
                    debugPrint("✅ Event edit completed successfully");
                  }
                },
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffffffff),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: SvgPicture.asset(
                      'images/icons/edit_icon.svg',
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        Color(0xff414751),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] : null,
        ),
      body: Obx(() {
        final event = eventController.selectedEvent.value;

        if (eventController.isLoading.value) {
          return Center(
            child: CustomLoadingIndicator(
              size: 48,
              color: Color(0xFFEF5050),
            ),
          );
        }

        if (event == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "images/icons/event.svg",
                  width: 64,
                  height: 64,
                  colorFilter: ColorFilter.mode(
                    Color(0xff9ca3ae),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  languageService.tr("event.eventDetail.notFound"),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Color(0xff9ca3ae),
                  ),
                ),
                SizedBox(height: 16),
                CustomButton(
                  text: languageService.tr("event.eventDetail.retry"),
                  height: 40,
                  borderRadius: 12,
                  onPressed: () {
                    final eventId = Get.arguments?['eventId'];
                    if (eventId != null) {
                      eventController.fetchEventDetail(eventId);
                    } else {
                      Get.back();
                    }
                  },
                  isLoading: RxBool(false),
                  backgroundColor: Color(0xffef5050),
                  textColor: Color(0xffffffff),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Banner
              if (event.bannerUrl.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(event.bannerUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: 16),

              // Event Title
              Text(
                event.title,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff414751),
                ),
              ),
              SizedBox(height: 8),

              // Event Date & Time
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xffffffff),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "images/icons/calendar_icon.svg",
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        Color(0xffef5050),
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatSimpleDateClock(event.startTime),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff414751),
                            ),
                          ),
                          Text(
                            "${languageService.tr("event.eventDetail.until")} ${formatSimpleDateClock(event.endTime)}",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Color(0xff9ca3ae),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Event Location
              if (event.location.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "images/icons/location.svg",
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          Color(0xffef5050),
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.location,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Color(0xff414751),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (event.location.startsWith('http')) {
                            final uri = Uri.parse(event.location);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            }
                          }
                        },
                        icon: Icon(
                          Icons.open_in_new,
                          size: 18,
                          color: Color(0xff9ca3ae),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 16),

              // Event Description
              Text(
                languageService.tr("event.eventDetail.description"),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff414751),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xffffffff),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Color(0xff414751),
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 32),

              // Action Buttons
              Column(
                children: [
                  Row(
                    children: [
                      // Set Reminder Button
                      Expanded(
                        child: CustomButton(
                          text: languageService
                              .tr("event.eventDetail.setReminder"),
                          height: 44,
                          borderRadius: 12,
                          onPressed: () =>
                              eventController.setEventReminder(event.id),
                          isLoading: RxBool(false),
                          backgroundColor: Color(0xffffffff),
                          textColor: Color(0xffef5050),
                          icon: SvgPicture.asset(
                            "images/icons/notification_icon.svg",
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(
                              Color(0xffef5050),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),

                      // Share Button
                      Expanded(
                        child: CustomButton(
                          text: languageService.tr("event.eventDetail.share"),
                          height: 44,
                          borderRadius: 12,
                          onPressed: () =>
                              eventController.shareEvent(event.title),
                          isLoading: RxBool(false),
                          backgroundColor: Color(0xffffffff),
                          textColor: Color(0xffef5050),
                          icon: SvgPicture.asset(
                            "images/icons/share.svg",
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(
                              Color(0xffef5050),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                                     SizedBox(
                     width: double.infinity,
                     child: CustomButton(
                       text: languageService.tr("event.eventDetail.joinEvent"),
                       height: 50,
                       borderRadius: 15,
                       onPressed: () {
                         eventController.respondToEventInvitation(
                           event.id, 
                           event.groupId, 
                           true  // accept = true for join
                         );
                       },
                       isLoading: RxBool(false),
                       backgroundColor: Color(0xffef5050),
                       textColor: Color(0xffffffff),
                       icon: SvgPicture.asset(
                         "images/icons/event.svg",
                         width: 18,
                         height: 18,
                         colorFilter: ColorFilter.mode(
                           Color(0xffffffff),
                           BlendMode.srcIn,
                         ),
                       ),
                     ),
                   ),
                ],
              ),
            ],
          ),
        );
      }),
      );
    });
  }
}
