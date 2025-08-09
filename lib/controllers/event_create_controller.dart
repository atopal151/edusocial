import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/event_service.dart';
import '../services/language_service.dart';
import '../components/snackbars/custom_snackbar.dart';

class EventCreateController extends GetxController {
  final LanguageService languageService = Get.find<LanguageService>();
  final EventServices _eventService = EventServices();

  // Form Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // Reactive Variables
  final RxBool isLoading = false.obs;
  final Rx<File?> bannerImage = Rx<File?>(null);
  final RxString startDate = ''.obs;
  final RxString startTime = ''.obs;
  final RxString endDate = ''.obs;
  final RxString endTime = ''.obs;
  final RxString groupId = ''.obs;
  
  // Location variables
  final RxString selectedLocationAddress = ''.obs;
  final RxDouble selectedLatitude = 0.0.obs;
  final RxDouble selectedLongitude = 0.0.obs;
  final RxString selectedGoogleMapsUrl = ''.obs;

  // Date/Time holders
  DateTime? selectedStartDate;
  TimeOfDay? selectedStartTime;
  DateTime? selectedEndDate;
  TimeOfDay? selectedEndTime;

  void setGroupId(String id) {
    groupId.value = id;
    debugPrint("📝 Event Create Controller - Group ID set: $id");
  }

  void setSelectedLocation({
    required double latitude,
    required double longitude,
    required String address,
    required String googleMapsUrl,
  }) {
    selectedLatitude.value = latitude;
    selectedLongitude.value = longitude;
    selectedLocationAddress.value = address;
    selectedGoogleMapsUrl.value = googleMapsUrl;
    
    // Update the location controller with the Google Maps URL
    locationController.text = googleMapsUrl;
    
    debugPrint("📍 Location selected: $address");
    debugPrint("🗺️ Coordinates: $latitude, $longitude");
    debugPrint("🔗 Maps URL: $googleMapsUrl");
  }

  Future<void> createEvent() async {
    if (!_validateForm()) {
      return;
    }

    isLoading.value = true;
    debugPrint("🚀 Starting event creation...");

    try {
      final startDateTime = _combineDateTime(selectedStartDate!, selectedStartTime!);
      final endDateTime = _combineDateTime(selectedEndDate!, selectedEndTime!);

      final success = await _eventService.createEvent(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        location: locationController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        groupId: int.parse(groupId.value),
        banner: bannerImage.value,
      );

      isLoading.value = false;

      if (success) {
        debugPrint("✅ Event created successfully");
        CustomSnackbar.show(
          title: languageService.tr("common.success"),
          message: languageService.tr("event.createEvent.success.created"),
          type: SnackbarType.success,
        );
        
        // Clear form and go back
        _clearForm();
        Get.back();
      } else {
        debugPrint("❌ Event creation failed");
        CustomSnackbar.show(
          title: languageService.tr("common.error"),
          message: languageService.tr("event.error.createFailed"),
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint("💥 Event creation error: $e");
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: "${languageService.tr("event.error.createFailed")}: $e",
        type: SnackbarType.error,
      );
    }
  }

  bool _validateForm() {
    if (titleController.text.trim().isEmpty) {
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: languageService.tr("event.validation.titleRequired"),
        type: SnackbarType.error,
      );
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: languageService.tr("event.validation.descriptionRequired"),
        type: SnackbarType.error,
      );
      return false;
    }

    if (locationController.text.trim().isEmpty) {
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: languageService.tr("event.validation.locationRequired"),
        type: SnackbarType.error,
      );
      return false;
    }

    if (selectedStartDate == null || selectedStartTime == null) {
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: languageService.tr("event.validation.startDateTimeRequired"),
        type: SnackbarType.error,
      );
      return false;
    }

    if (selectedEndDate == null || selectedEndTime == null) {
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: languageService.tr("event.validation.endDateTimeRequired"),
        type: SnackbarType.error,
      );
      return false;
    }

    final startDateTime = _combineDateTime(selectedStartDate!, selectedStartTime!);
    final endDateTime = _combineDateTime(selectedEndDate!, selectedEndTime!);

    if (endDateTime.isBefore(startDateTime)) {
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: languageService.tr("event.validation.endTimeAfterStart"),
        type: SnackbarType.error,
      );
      return false;
    }

    if (groupId.value.isEmpty) {
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: languageService.tr("event.validation.groupRequired"),
        type: SnackbarType.error,
      );
      return false;
    }

    return true;
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    bannerImage.value = null;
    startDate.value = '';
    startTime.value = '';
    endDate.value = '';
    endTime.value = '';
    selectedLocationAddress.value = '';
    selectedLatitude.value = 0.0;
    selectedLongitude.value = 0.0;
    selectedGoogleMapsUrl.value = '';
    selectedStartDate = null;
    selectedStartTime = null;
    selectedEndDate = null;
    selectedEndTime = null;
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.onClose();
  }
}
