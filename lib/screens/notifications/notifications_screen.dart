import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/notification_tile.dart';
import '../../controllers/notification_controller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController controller = Get.put(NotificationController());

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xfffafafa),
    appBar: BackAppBar(iconBackgroundColor: Color(0xffffffff),backgroundColor: Color(0xfffafafa),title: "Bildirimler",),
    body: Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      final grouped = controller.groupNotificationsByDate(controller.notifications);

      return ListView.builder(
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final group = grouped[index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  group.label,
                  style: TextStyle(fontSize: 13.28, fontWeight: FontWeight.w600,color: Color(0xff414751)),
                ),
              ),
            ...group.notifications.map((n) => buildNotificationTile(n)),

            ],
          );
        },
      );
    }),
  );
}

}
