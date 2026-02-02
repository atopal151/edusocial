import 'package:edusocial/utils/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../components/input_fields/costum_textfield.dart';
import '../components/dropdowns/custom_dropdown.dart';
import '../components/snackbars/custom_snackbar.dart';
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
            scaffoldBackgroundColor: Colors.white, // Modal arka planı
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
        (existing != null ? DateTime.parse(existing.dateTime) : DateTime.now())
            .obs;
    RxBool sendNotification = (existing?.sendNotification ?? true).obs;
    Rx<Color> selectedColor = (existing != null
            ? HexColor.fromHex(existing.color)
            : Color(0xff2196F3))
        .obs; // Varsayılan olarak Normal (mavi)
    
    // Renk seçenekleri
    final colorOptions = [
      {'name': languageService.tr("calendar.colors.green"), 'color': Color(0xff4CAF50)},
      {'name': languageService.tr("calendar.colors.blue"), 'color': Color(0xff2196F3)},
      {'name': languageService.tr("calendar.colors.orange"), 'color': Color(0xffFF9800)},
      {'name': languageService.tr("calendar.colors.red"), 'color': Color(0xffef5050)},
    ];
    
    // Seçili rengin adını bul
    String getSelectedColorName() {
      final selected = colorOptions.firstWhere(
        (option) => option['color'] == selectedColor.value,
        orElse: () => colorOptions[1], // Varsayılan olarak mavi
      );
      return selected['name'] as String;
    }
    
    RxString selectedColorName = getSelectedColorName().obs;
    RxBool isSaving = false.obs;

    // Debug: Dil servisinin çalışıp çalışmadığını kontrol et
    debugPrint("🔍 Dil Servisi Debug:");
    debugPrint("  - createTitle: ${languageService.tr("calendar.reminderForm.createTitle")}");
    debugPrint("  - editTitle: ${languageService.tr("calendar.reminderForm.editTitle")}");
    debugPrint("  - titleLabel: ${languageService.tr("calendar.reminderForm.titleLabel")}");

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                existing != null
                    ? languageService.tr("calendar.reminderForm.editTitle")
                    : languageService.tr("calendar.reminderForm.createTitle"),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 24),

              // Başlık Input
              Text(
                languageService.tr("calendar.reminderForm.titleLabel"),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              SizedBox(height: 8),
              CustomTextField(
                textColor: Color(0xFF374151),
                controller: titleController,
                hintText: languageService.tr("calendar.reminderForm.titleHint"),
                isPassword: false,
                backgroundColor: Color(0xFFF9FAFB),
              ),
              SizedBox(height: 24),
              // Tarih ve Saat Seçimi
              Row(
                children: [
                  // Tarih
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languageService.tr("calendar.reminderForm.dateLabel"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        SizedBox(height: 8),
                        Obx(() => GestureDetector(
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: Get.context!,
                                  initialDate: selectedDateTime.value,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Color(0xffef5050),
                                          onPrimary: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                        scaffoldBackgroundColor: Colors.white,
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
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(selectedDateTime.value),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  // Saat
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languageService.tr("calendar.reminderForm.timeLabel"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        SizedBox(height: 8),
                        Obx(() => GestureDetector(
                              onTap: () async {
                                TimeOfDay? pickedTime = await showTimePicker(
                                  context: Get.context!,
                                  initialTime: TimeOfDay.fromDateTime(
                                      selectedDateTime.value),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Color(0xffef5050),
                                          onPrimary: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                        scaffoldBackgroundColor: Colors.white,
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
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('HH:mm')
                                          .format(selectedDateTime.value),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              // Bildirim Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    languageService
                        .tr("calendar.reminderForm.sendNotification"),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  Obx(() => GestureDetector(
                        onTap: () =>
                            sendNotification.value = !sendNotification.value,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 24,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          alignment: sendNotification.value
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: sendNotification.value
                                ? Color(0xffef5050)
                                : Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(10),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                ],
              ),
              SizedBox(height: 24),
              // Renk Seçimi
              Obx(() => Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomDropDown(
                    label: languageService.tr("calendar.reminderForm.colorLabel"),
                    items: colorOptions.map((option) => option['name'] as String).toList(),
                    selectedItem: selectedColorName.value,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        selectedColorName.value = newValue;
                        // Seçilen rengi bul ve selectedColor'ı güncelle
                        final selectedOption = colorOptions.firstWhere(
                          (option) => option['name'] == newValue,
                        );
                        selectedColor.value = selectedOption['color'] as Color;
                      }
                    },
                  ),
                ),
              )),
              SizedBox(height: 32),
              // Butonlar
              Row(
                children: [
                  // İptal Butonu
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            languageService.tr("common.cancel"),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Kaydet/Güncelle Butonu
                  Expanded(
                    child: Obx(() {
                      final saving = isSaving.value;
                      return GestureDetector(
                        onTap: saving
                            ? null
                            : () async {
                                final formatted = DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(selectedDateTime.value);
                                final colorHex = selectedColor.value.toHex();

                                debugPrint("🎨 Seçilen Renk Debug:");
                                debugPrint("  - Seçilen Color: ${selectedColor.value}");
                                debugPrint("  - Hex Kodu: $colorHex");

                                final reminder = Reminder(
                                  id: existing?.id ?? 0,
                                  title: titleController.text,
                                  dateTime: formatted,
                                  sendNotification: sendNotification.value,
                                  color: colorHex,
                                );
                                isSaving.value = true;
                                await Future.delayed(const Duration(milliseconds: 100));
                                try {
                                  if (existing != null) {
                                    await CalendarService.updateReminder(reminder);
                                  } else {
                                    await CalendarService.createReminder(reminder);
                                  }
                                  if (Get.isBottomSheetOpen == true) {
                                    Get.back(closeOverlays: false);
                                  }
                                  CustomSnackbar.show(
                                    title: languageService.tr("common.success"),
                                    message: existing != null
                                        ? languageService.tr("calendar.success.reminderUpdated")
                                        : languageService.tr("calendar.success.reminderAdded"),
                                    type: SnackbarType.success,
                                  );
                                  await loadReminders();
                                } catch (e) {
                                  CustomSnackbar.show(
                                    title: languageService.tr("common.error"),
                                    message: "${languageService.tr("calendar.errors.operationFailed")}: $e",
                                    type: SnackbarType.error,
                                  );
                                } finally {
                                  isSaving.value = false;
                                }
                              },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: saving ? Color(0xffef5050).withAlpha(180) : Color(0xffef5050),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: saving
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    existing != null
                                        ? languageService.tr("calendar.reminderForm.update")
                                        : languageService.tr("calendar.reminderForm.save"),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 24),
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
      CustomSnackbar.show(
        title: languageService.tr("common.success"),
        message: languageService.tr("calendar.success.reminderDeleted"),
        type: SnackbarType.success,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: "${languageService.tr("calendar.errors.reminderDeleteFailed")}: $e",
        type: SnackbarType.error,
      );
    }
  }
}
