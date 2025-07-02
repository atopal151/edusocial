import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/calendar_model.dart';
import '../../services/calendar_service.dart';
import '../../services/language_service.dart';
import '../../utils/date_format.dart';

Future<void> showReminderDetailDialog(BuildContext context, int reminderId) async {
  final LanguageService languageService = Get.find<LanguageService>();
  
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return FutureBuilder<Reminder>(
        future: CalendarService.getReminderById(reminderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(

            backgroundColor: Color(0xffffffff),
              content: SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator(color: Color(0xffef5050),)),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return AlertDialog(
              title: Text(languageService.tr("calendar.reminderDetail.error.title")),
              content: Text(languageService.tr("calendar.reminderDetail.error.message")),
            );
          }

          final reminder = snapshot.data!;
          return AlertDialog(
            backgroundColor: Color(0xffffffff),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(languageService.tr("calendar.reminderDetail.title")),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📝 ${languageService.tr("calendar.reminderDetail.titleLabel")}: ${reminder.title}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                Text("⏰ ${languageService.tr("calendar.reminderDetail.timeLabel")}: ${formatSimpleDateClock(reminder.dateTime)}",
                    style: TextStyle(fontSize: 14)),
                SizedBox(height: 10),
                Text("🔔 ${languageService.tr("calendar.reminderDetail.notificationLabel")}: ${reminder.sendNotification ? languageService.tr("calendar.reminderDetail.notificationOn") : languageService.tr("calendar.reminderDetail.notificationOff")}",
                    style: TextStyle(fontSize: 14)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(languageService.tr("calendar.reminderDetail.close"), style: TextStyle(color: Color(0xffef5050))),
              ),
            ],
          );
        },
      );
    },
  );
}
