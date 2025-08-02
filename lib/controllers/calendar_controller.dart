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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xffef5050), // Seçili tarih rengi
              onPrimary: Colors.white, // Seçili tarih üzerindeki yazı rengi
              onSurface: Colors.black, // Diğer yazılar
            ),
            dialogBackgroundColor: Colors.white, // Modal arka planı
          ),
          child: child!,
        );
      },
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
    Rx<DateTime> selectedDateTime =
        (existing != null ? DateTime.parse(existing.dateTime) : DateTime.now()).obs;
    RxBool sendNotification = (existing?.sendNotification ?? true).obs;
    Rx<Color> selectedColor =
        (existing != null ? HexColor.fromHex(existing.color) : Color(0xff2196F3)).obs; // Varsayılan olarak Normal (mavi)

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
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "${languageService.tr("calendar.reminderForm.dateLabel")} ${DateFormat('dd MMM yyyy').format(selectedDateTime.value)}"),
                  SizedBox(
                    width: 120,
                    child: CustomButton(
                      height: 40,
                      borderRadius: 15,
                      text: languageService.tr("calendar.reminderForm.selectDate"),
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: Get.context!,
                          initialDate: selectedDateTime.value,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Color(0xffef5050), // Seçili tarih rengi
                                  onPrimary: Colors.white, // Seçili tarih üzerindeki yazı rengi
                                  onSurface: Colors.black, // Diğer yazılar
                                ),
                                dialogBackgroundColor: Colors.white, // Modal arka planı
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          selectedDateTime.value = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            selectedDateTime.value.hour,
                            selectedDateTime.value.minute,
                          );
                        }
                      },
                      isLoading: false.obs,
                      backgroundColor: Color(0xffef5050),
                      textColor: Colors.white,
                    ),
                  ),
                ],
              )),
              SizedBox(height: 10),
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${languageService.tr("calendar.reminderForm.timeLabel")} ${DateFormat('HH:mm').format(selectedDateTime.value)}"),
                  SizedBox(
                    width: 120,
                    child: CustomButton(
                      height: 40,
                      borderRadius: 15,
                      text: languageService.tr("calendar.reminderForm.selectTime"),
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: Get.context!,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime.value),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Color(0xffef5050), // Seçili saat rengi
                                  onPrimary: Colors.white, // Seçili saat üzerindeki yazı rengi
                                  onSurface: Colors.black, // Diğer yazılar
                                ),
                                dialogBackgroundColor: Colors.white, // Modal arka planı
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedTime != null) {
                          selectedDateTime.value = DateTime(
                            selectedDateTime.value.year,
                            selectedDateTime.value.month,
                            selectedDateTime.value.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        }
                      },
                      isLoading: false.obs,
                      backgroundColor: Color(0xffef5050),
                      textColor: Colors.white,
                    ),
                  ),
                ],
              )),
              SizedBox(height: 20),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            languageService.tr("calendar.reminderForm.sendNotification"),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.28,
                              color: const Color(0xff414751),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => sendNotification.value = !sendNotification.value,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 36,
                            height: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            alignment: sendNotification.value ? Alignment.centerRight : Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: sendNotification.value
                                    ? const Color(0xFFEF5050)
                                    : const Color(0xFFD3D3D3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: 10),
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${languageService.tr("calendar.reminderForm.colorLabel")} "),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Düşük Önem - Yeşil
                          GestureDetector(
                            onTap: () => selectedColor.value = Color(0xff4CAF50),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xff4CAF50),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: selectedColor.value == Color(0xff4CAF50) 
                                    ? Color(0xffef5050) 
                                    : Colors.grey,
                                  width: selectedColor.value == Color(0xff4CAF50) ? 3 : 1,
                                ),
                              ),
                              child: selectedColor.value == Color(0xff4CAF50)
                                ? Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                            ),
                          ),
                          // Normal Önem - Mavi
                          GestureDetector(
                            onTap: () => selectedColor.value = Color(0xff2196F3),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xff2196F3),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: selectedColor.value == Color(0xff2196F3) 
                                    ? Color(0xffef5050) 
                                    : Colors.grey,
                                  width: selectedColor.value == Color(0xff2196F3) ? 3 : 1,
                                ),
                              ),
                              child: selectedColor.value == Color(0xff2196F3)
                                ? Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                            ),
                          ),
                          // Yüksek Önem - Turuncu
                          GestureDetector(
                            onTap: () => selectedColor.value = Color(0xffFF9800),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xffFF9800),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: selectedColor.value == Color(0xffFF9800) 
                                    ? Color(0xffef5050) 
                                    : Colors.grey,
                                  width: selectedColor.value == Color(0xffFF9800) ? 3 : 1,
                                ),
                              ),
                              child: selectedColor.value == Color(0xffFF9800)
                                ? Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                            ),
                          ),
                          // Acil Önem - Kırmızı
                          GestureDetector(
                            onTap: () => selectedColor.value = Color(0xffef5050),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xffef5050),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: selectedColor.value == Color(0xffef5050) 
                                    ? Colors.black 
                                    : Colors.grey,
                                  width: selectedColor.value == Color(0xffef5050) ? 3 : 1,
                                ),
                              ),
                              child: selectedColor.value == Color(0xffef5050)
                                ? Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                            ),
                          ),
                        ],
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
                        .format(selectedDateTime.value);
                    final colorHex = selectedColor.value.toHex();
                    print("🎨 Seçilen renk: $colorHex"); // Debug için
                    print("🎨 Seçilen renk RGB: ${selectedColor.value.red}, ${selectedColor.value.green}, ${selectedColor.value.blue}"); // Debug için
                    
                    final reminder = Reminder(
                      id: existing?.id ?? 0,
                      title: titleController.text,
                      dateTime: formatted,
                      sendNotification: sendNotification.value,
                      color: colorHex, // renk hex olarak gönderilecek
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
