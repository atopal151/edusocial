

// 5. event_screen.dart
import 'package:edusocial/components/user_appbar/user_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      appBar: UserAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: controller.eventList.length,
          itemBuilder: (context, index) {
            final event = controller.eventList[index];
            return EventCard(
              eventTitle: event.title,
              eventDescription: event.description,
              eventDate: event.date,
              eventImage: event.image,
              onShare: () => controller.shareEvent(event.title),
              onLocation: () => controller.showLocation(event.title),
            );
          },
        );
      }),
    );
  }
}
