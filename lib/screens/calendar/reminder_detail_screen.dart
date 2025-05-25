import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/calendar_model.dart';
import '../../services/calendar_service.dart';

class ReminderDetailScreen extends StatefulWidget {
  final int reminderId;

  const ReminderDetailScreen({Key? key, required this.reminderId}) : super(key: key);

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  Reminder? reminder;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReminder();
  }

  Future<void> fetchReminder() async {
    try {
      final data = await CalendarService.getReminderById(widget.reminderId);
      setState(() {
        reminder = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar("Hata", "Hatırlatıcı getirilemedi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hatırlatıcı Detayı")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reminder == null
              ? const Center(child: Text("Hatırlatıcı bulunamadı."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📝 Başlık: ${reminder!.title}",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      SizedBox(height: 10),
                      Text("⏰ Zaman: ${reminder!.dateTime}",
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text("🔔 Bildirim: ${reminder!.sendNotification ? 'Açık' : 'Kapalı'}",
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
    );
  }
}
