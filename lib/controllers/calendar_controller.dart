import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../components/buttons/custom_button.dart';
import '../components/input_fields/costum_textfield.dart';
import '../models/calendar_model.dart';
import '../services/calendar_service.dart';

class CalendarController extends GetxController {
  var selectedDate = DateFormat('dd MMM yyyy').format(DateTime.now()).obs;
  var allReminders = <Reminder>[].obs;
  var reminders = <Reminder>[].obs;

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
      Get.snackbar("Hata", "Hatırlatıcılar alınamadı: $e");
    }
  }

  void filterReminders() {
    reminders.value = allReminders.where((reminder) =>
      reminder.dateTime.startsWith(selectedDate.value)).toList();
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
    DateTime selectedDateTime = existing != null
      ? DateFormat('yyyy-MM-dd HH:mm:ss').parse(existing.dateTime)
      : DateTime.now();
    RxBool sendNotification = true.obs;

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
                  hintText: "Hatırlatma Başlığı",
                  isPassword: false,
                  backgroundColor: Color(0xfff5f5f5)),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tarih: ${DateFormat('dd MMM yyyy').format(selectedDateTime)}"),
                  SizedBox(
                    width: 120,
                    child: CustomButton(
                      height: 50,
                      borderRadius: 15,
                      text: "Tarih Seç",
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
                      textColor: Color(0xffffffff),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Saat: ${DateFormat('HH:mm').format(selectedDateTime)}"),
                  SizedBox(
                    width: 120,
                    child: CustomButton(
                      height: 50,
                      borderRadius: 15,
                      text: "Saat Seç",
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
                      textColor: Color(0xffffffff),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Obx(() => SwitchListTile(
                title: Text("Bildirim gönder"),
                value: sendNotification.value,
                onChanged: (val) => sendNotification.value = val,
              )),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  height: 50,
                  borderRadius: 15,
                  text: existing != null ? "Güncelle" : "Kaydet",
                  onPressed: () async {
                    final formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateTime);
                    final reminder = Reminder(
                      id: existing?.id ?? 0,
                      title: titleController.text,
                      dateTime: formatted,
                      sendNotification: sendNotification.value,
                    );
                    try {
                      if (existing != null) {
                        await CalendarService.updateReminder(reminder);
                        Get.snackbar("Başarılı", "Hatırlatıcı güncellendi");
                      } else {
                        await CalendarService.createReminder(reminder);
                        Get.snackbar("Başarılı", "Hatırlatıcı eklendi");
                      }
                      await loadReminders();
                      Get.back();
                    } catch (e) {
                      Get.snackbar("Hata", "İşlem başarısız: $e");
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
      Get.snackbar("Silindi", "Hatırlatıcı başarıyla silindi");
    } catch (e) {
      Get.snackbar("Hata", "Silme başarısız: $e");
    }
  }
}

/*
class CalendarController extends GetxController {
  var selectedDate = DateFormat('dd MMM yyyy').format(DateTime.now()).obs;

  var allReminders = <Reminder>[].obs;
  var reminders = <Reminder>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMockData();
    filterReminders();
  }

  void loadMockData() {
    allReminders.addAll([
      Reminder(id: 1, title: "Tasarım Ödevi", dateTime: "14 Feb 2025, 16:34"),
      Reminder(id: 2, title: "Sunum Hazırlığı", dateTime: "20 Mar 2025, 10:00"),
      Reminder(
          id: 3, title: "Doktor Randevusu", dateTime: "16 Mar 2025, 14:00"),
    ]);
  }

  void filterReminders() {
    reminders.value = allReminders
        .where((reminder) => reminder.dateTime.startsWith(selectedDate.value))
        .toList();
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

  void addReminder() {
    TextEditingController titleController = TextEditingController();
    DateTime selectedDateTime = DateTime.now();

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
                  hintText: "Hatırlatma Başlığı",
                  isPassword: false,
                  backgroundColor: Color(0xfff5f5f5)),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "Tarih: ${DateFormat('dd MMM yyyy').format(selectedDateTime)}"),
                  SizedBox(
                    width: 120,
                    child: CustomButton(

                        height: 50,
                        borderRadius: 15,
                      text: "Tarih Seç",
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: Get.context!,
                          initialDate: selectedDateTime,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          selectedDateTime = pickedDate;
                        }
                      },
                      isLoading: false.obs,
                      backgroundColor: Color(0xff414751),
                      textColor: Color(0xffffffff),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Saat: ${DateFormat('HH:mm').format(selectedDateTime)}"),
                  SizedBox(
                    width: 120,
                    child: CustomButton(

                        height: 50,
                        borderRadius: 15,
                      text: "Saat Seç",
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
                      textColor: Color(0xffffffff),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: CustomButton(

                        height: 50,
                        borderRadius: 15,
                  text: "Kaydet",
                  onPressed: () {
                    allReminders.add(Reminder(
                      id: allReminders.length + 1,
                      title: titleController.text,
                      dateTime: DateFormat('dd MMM yyyy, HH:mm')
                          .format(selectedDateTime),
                    ));
                    filterReminders();
                    Get.back();
                    Get.snackbar("Başarılı", "Hatırlatıcı eklendi");
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
  
  void deleteReminder(int id) {
    allReminders.removeWhere((reminder) => reminder.id == id);
    filterReminders();
  }
}*/