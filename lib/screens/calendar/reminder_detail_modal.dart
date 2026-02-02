import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/snackbars/custom_snackbar.dart';
import '../../controllers/calendar_controller.dart';
import '../../models/calendar_model.dart';
import '../../services/calendar_service.dart';
import '../../services/language_service.dart';
import '../../utils/date_format.dart';
import '../../utils/hex_color.dart';

Future<void> showReminderDetailDialog(BuildContext context, int reminderId) async {
  final LanguageService languageService = Get.find<LanguageService>();
  
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
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
          return _ReminderDetailDialogContent(
            reminder: reminder,
            dialogContext: dialogContext,
            languageService: languageService,
          );
        },
      );
    },
  );
}

class _ReminderDetailDialogContent extends StatefulWidget {
  final Reminder reminder;
  final BuildContext dialogContext;
  final LanguageService languageService;

  const _ReminderDetailDialogContent({
    required this.reminder,
    required this.dialogContext,
    required this.languageService,
  });

  @override
  State<_ReminderDetailDialogContent> createState() => _ReminderDetailDialogContentState();
}

class _ReminderDetailDialogContentState extends State<_ReminderDetailDialogContent> {
  bool _isSaving = false;

  Future<void> _onSave() async {
    setState(() => _isSaving = true);
    // Loading'in ekranda görünmesi için bir frame bekle
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    try {
      await CalendarService.updateReminder(widget.reminder);
      try {
        Get.find<CalendarController>().loadReminders();
      } catch (_) {}
      if (widget.dialogContext.mounted) {
        Navigator.of(widget.dialogContext).pop();
      }
    } catch (e) {
      CustomSnackbar.show(
        title: widget.languageService.tr("common.error"),
        message: "${widget.languageService.tr("calendar.errors.operationFailed")}: $e",
        type: SnackbarType.error,
      );
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminder = widget.reminder;
    final lang = widget.languageService;
    return AlertDialog(
      backgroundColor: const Color(0xffffffff),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('dsdsds'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: HexColor.fromHex(reminder.color),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
              ),
              const SizedBox(width: 8),
              Text("🎨 ${lang.tr("calendar.reminderDetail.colorLabel")}: ${reminder.color}",
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          Text("📝 ${lang.tr("calendar.reminderDetail.titleLabel")}: ${reminder.title}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text("⏰ ${lang.tr("calendar.reminderDetail.timeLabel")}: ${formatSimpleDateClock(reminder.dateTime)}",
              style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
          Text("🔔 ${lang.tr("calendar.reminderDetail.notificationLabel")}: ${reminder.sendNotification ? lang.tr("calendar.reminderDetail.notificationOn") : lang.tr("calendar.reminderDetail.notificationOff")}",
              style: const TextStyle(fontSize: 14)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(widget.dialogContext).pop(),
          child: Text(
            lang.tr("calendar.reminderDetail.close"),
            style: const TextStyle(color: Color(0xffef5050)),
          ),
        ),
        TextButton(
          onPressed: _isSaving ? null : _onSave,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xffef5050),
                  ),
                )
              : Text(
                  lang.tr("calendar.reminderForm.save"),
                  style: const TextStyle(color: Color(0xffef5050), fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }
}
