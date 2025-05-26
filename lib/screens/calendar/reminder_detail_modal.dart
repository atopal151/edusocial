import 'package:flutter/material.dart';
import '../../models/calendar_model.dart';
import '../../services/calendar_service.dart';
import '../../utils/date_format.dart';

Future<void> showReminderDetailDialog(BuildContext context, int reminderId) async {
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
            return const AlertDialog(
              title: Text("Hata"),
              content: Text("Hatırlatıcı getirilemedi."),
            );
          }

          final reminder = snapshot.data!;
          return AlertDialog(
            backgroundColor: Color(0xffffffff),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Hatırlatıcı Detayı"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📝 Başlık: ${reminder.title}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                Text("⏰ Zaman: ${formatSimpleDateClock(reminder.dateTime)}",
                    style: TextStyle(fontSize: 14)),
                SizedBox(height: 10),
                Text("🔔 Bildirim: ${reminder.sendNotification ? 'Açık' : 'Kapalı'}",
                    style: TextStyle(fontSize: 14)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Kapat",style: TextStyle(color: Color(0xffef5050)),),
              ),
            ],
          );
        },
      );
    },
  );
}
