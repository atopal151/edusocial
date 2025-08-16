// 5. event_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/user_appbar/back_appbar.dart';
import '../../components/widgets/general_loading_indicator.dart';
import '../../controllers/event_controller.dart';
import '../../components/cards/event_card.dart';
import '../../services/language_service.dart';
import '../../utils/date_format.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  @override
  Widget build(BuildContext context) {
    final EventController controller = Get.find();
    final LanguageService languageService = Get.find<LanguageService>();

    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(iconBackgroundColor: Color(0xffffffff),),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: GeneralLoadingIndicator(
                size: 32,
                color: Color(0xFFef5050),
                showText: true,
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: Color(0xFFef5050),
          backgroundColor: Color(0xfffafafa),
          elevation: 0,
          onRefresh: () async {
            await controller.fetchTopEvents();
          },
          child: controller.topEventList.isEmpty
              ? SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: Get.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            languageService.tr("event.eventScreen.emptyState.title"),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            languageService.tr("event.eventScreen.emptyState.subtitle"),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: controller.topEventList.length,
                  itemBuilder: (context, index) {
                    final event = controller.topEventList[index];
                    // Debug tarih formatı
                    final formattedDate = formatEventDate(event.startTime, event.endTime);
                    debugPrint("📅 Event ${event.id} - Start: ${event.startTime}, End: ${event.endTime}, Formatted: $formattedDate");
                    
                    return EventCard(
                      eventId: event.id,
                      eventTitle: event.title,
                      eventDescription: event.description,
                      eventDate: formattedDate,
                      eventEndTime: event.endTime,
                      eventImage: event.bannerUrl,
                      onShare: () => controller.shareEvent(event.title),
                      onLocation: () => controller.showLocation(event.title),
                    );
                  },
                ),
        );
      }),
    );
  }
}
