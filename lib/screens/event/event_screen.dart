// 5. event_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/user_appbar/back_appbar.dart';
import '../../components/widgets/general_loading_indicator.dart';
import '../../controllers/event_controller.dart';
import '../../components/cards/event_card.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  @override
  Widget build(BuildContext context) {
    final EventController controller = Get.find();

    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: GeneralLoadingIndicator(
              size: 32,
              color: Color(0xFF4CAF50),
              icon: Icons.event,
              showText: true,
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: controller.eventList.length,
          itemBuilder: (context, index) {
            final event = controller.eventList[index];
            return EventCard(
              eventTitle: event.title,
              eventDescription: event.description,
              eventDate: event.endTime,
              eventImage: event.bannerUrl,
              onShare: () => controller.shareEvent(event.title),
              onLocation: () => controller.showLocation(event.title),
            );
          },
        );
      }),
    );
  }
}
