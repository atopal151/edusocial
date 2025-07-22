import 'package:edusocial/utils/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../components/buttons/custom_button.dart';
import '../components/input_fields/costum_textfield.dart';
import '../models/calendar_model.dart';
import '../services/calendar_service.dart';
import '../services/language_service.dart';

class CalendarController extends GetxController {
  var selectedDate = DateFormat('dd MMM yyyy').format(DateTime.now()).obs;
  var allReminders = <Reminder>[].obs;
  var reminders = <Reminder>[].obs;
  final LanguageService languageService = Get.find<LanguageService>();

  @override
  void onInit() {
    super.onInit();
    loadReminders();
  }

  Future<void> loadReminders() async {
    try {
      final fetched = await CalendarService.getReminders();
      allReminders.value = fetched;
      filterReminders();
    } catch (e) {
      debugPrint('Hata: $e');
    }
  }

  void filterReminders() {
    reminders.value = allReminders.where((reminder) {
      try {
        final reminderDate = DateTime.parse(reminder.dateTime);
        final formattedReminderDate =
            DateFormat('dd MMM yyyy').format(reminderDate);
        return formattedReminderDate == selectedDate.value;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  void selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      selectedDate.value = DateFormat('dd MMM yyyy').format(pickedDate);
      filterReminders();
    }
  }

  void previousDay() {
    DateTime currentDate = DateFormat('dd MMM yyyy').parse(selectedDate.value);
    selectedDate.value = DateFormat('dd MMM yyyy')
        .format(currentDate.subtract(Duration(days: 1)));
    filterReminders();
  }

  void nextDay() {
    DateTime currentDate = DateFormat('dd MMM yyyy').parse(selectedDate.value);
    selectedDate.value =
        DateFormat('dd MMM yyyy').format(currentDate.add(Duration(days: 1)));
    filterReminders();
  }

  void addOrUpdateReminder({Reminder? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? "");
    DateTime selectedDateTime =
        existing != null ? DateTime.parse(existing.dateTime) : DateTime.now();
    RxBool sendNotification = (existing?.sendNotification ?? true).obs;
    Rx<Color> selectedColor =
        (existing != null ? HexColor.fromHex(existing.color) : Colors.blue).obs;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              CustomTextField(
                textColor: Color(0xFF9CA3AF),
                controller: titleController,
                hintText: languageService.tr("calendar.reminderForm.titleHint"),
                isPassword: false,
                backgroundColor: Color(0xfff5f5f5),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "${languageService.tr("calendar.reminderForm.dateLabel")} ${DateFormat('dd MMM yyyy').format(selectedDateTime)}"),
                  SizedBox(
                    width: 120,
                    child: CustomButton(
                      height: 50,
                      borderRadius: 15,
                      text: languageService.tr("calendar.reminderForm.selectDate"),
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: Get.context!,
                          initialDate: selectedDateTime,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          selectedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            selectedDateTime.hour,
                            selectedDateTime.minute,
                          );
                        }
                      },
                      isLoading: false.obs,
                      backgroundColor: Color(0xff414751),
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${languageService.tr("calendar.reminderForm.timeLabel")} ${DateFormat('HH:mm').format(selectedDateTime)}"),
                  SizedBox(
                    width: 120,
                    child: CustomButton(
                      height: 50,
                      borderRadius: 15,
                      text: languageService.tr("calendar.reminderForm.selectTime"),
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: Get.context!,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                        );
                        if (pickedTime != null) {
                          selectedDateTime = DateTime(
                            selectedDateTime.year,
                            selectedDateTime.month,
                            selectedDateTime.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        }
                      },
                      isLoading: false.obs,
                      backgroundColor: Color(0xff414751),
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Obx(() => SwitchListTile(
                    title: Text(languageService.tr("calendar.reminderForm.sendNotification")),
                    value: sendNotification.value,
                    onChanged: (val) => sendNotification.value = val,
                  )),
              SizedBox(height: 10),
              Obx(() => Row(
                    children: [
                      Text("${languageService.tr("calendar.reminderForm.colorLabel")} "),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Get.dialog(
                            AlertDialog(
                              title: Text(languageService.tr("calendar.reminderForm.selectColor")),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: selectedColor.value,
                                  onColorChanged: (color) {
                                    selectedColor.value = color;
                                  },
                                  labelTypes: [],
                                  pickerAreaHeightPercent: 0.8,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(languageService.tr("calendar.reminderForm.ok")),
                                  onPressed: () {
                                    Get.back(); // renk seçimi tamamlandı
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: selectedColor.value,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  height: 50,
                  borderRadius: 15,
                  text: existing != null ? languageService.tr("calendar.reminderForm.update") : languageService.tr("calendar.reminderForm.save"),
                  onPressed: () async {
                    final formatted = DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format(selectedDateTime);
                    final reminder = Reminder(
                      id: existing?.id ?? 0,
                      title: titleController.text,
                      dateTime: formatted,
                      sendNotification: sendNotification.value,
                      color: selectedColor.value
                          .toHex(), // renk hex olarak gönderilecek
                    );
                    try {
                      if (existing != null) {
                        await CalendarService.updateReminder(reminder);
                        Get.snackbar(languageService.tr("common.success"), languageService.tr("calendar.success.reminderUpdated"));
                      } else {
                        await CalendarService.createReminder(reminder);
                        Get.snackbar(
                          "✅ ${languageService.tr("common.success")}", // Başlık
                          languageService.tr("calendar.success.reminderAdded"), // Mesaj
                          snackPosition:
                              SnackPosition.TOP, // Konum: TOP / BOTTOM
                          backgroundColor: Colors.green, // Arka plan rengi
                          colorText: Colors.white, // Yazı rengi
                          icon: Icon(Icons.check, color: Colors.white), // İkon
                          duration: Duration(seconds: 3), // Görünme süresi
                          margin: EdgeInsets.all(12), // Etraf boşluğu
                          borderRadius: 10, // Köşe yumuşaklığı
                        );
                      }
                      await loadReminders();
                      Get.back();
                    } catch (e) {
                      Get.snackbar(languageService.tr("common.error"), "${languageService.tr("calendar.errors.operationFailed")}: $e");
                    }
                  },
                  isLoading: false.obs,
                  backgroundColor: Color(0xffFFF6F6),
                  textColor: Color(0xffED7474),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> deleteReminder(int id) async {
    try {
      await CalendarService.deleteReminder(id);
      await loadReminders();
      Get.snackbar(
        languageService.tr("common.success"), // Başlık
        languageService.tr("calendar.success.reminderDeleted"), // Mesaj
        snackPosition: SnackPosition.TOP, // Konum: TOP / BOTTOM
        backgroundColor: Color(0xffef5050), // Arka plan rengi
        colorText: Colors.white, // Yazı rengi
        icon: Icon(Icons.check, color: Colors.white), // İkon
        duration: Duration(seconds: 3), // Görünme süresi
        margin: EdgeInsets.all(12), // Etraf boşluğu
        borderRadius: 10, // Köşe yumuşaklığı
      );
    } catch (e) {
      Get.snackbar(languageService.tr("common.error"), "${languageService.tr("calendar.errors.reminderDeleteFailed")}: $e");
    }
  }
}
