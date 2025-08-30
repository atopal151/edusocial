import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../components/snackbars/custom_snackbar.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../services/language_service.dart';

class EventEditController extends GetxController {
  var isLoading = false.obs;
  
  // Current event data
  var currentEvent = Rxn<EventModel>();
  var currentBannerUrl = ''.obs;
  
  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  
  // Selected values
  var selectedBanner = Rxn<File>();
  var selectedStartDate = Rxn<DateTime>();
  var selectedStartTime = Rxn<TimeOfDay>();
  var selectedEndDate = Rxn<DateTime>();
  var selectedEndTime = Rxn<TimeOfDay>();
  
  // Location
  var selectedLocationAddress = ''.obs;
  var selectedLatitude = 0.0.obs;
  var selectedLongitude = 0.0.obs;
  var selectedGoogleMapsUrl = ''.obs;

  final EventServices _eventServices = EventServices();
  final LanguageService languageService = Get.find<LanguageService>();

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Load existing event data
  Future<void> loadEventData(int eventId) async {
    try {
      isLoading.value = true;
      debugPrint("🔄 Loading event data for ID: $eventId");
      
      final event = await _eventServices.fetchEventDetail(eventId);
      if (event != null) {
        currentEvent.value = event;
        
        // Populate form fields
        titleController.text = event.title;
        descriptionController.text = event.description;
        currentBannerUrl.value = event.bannerUrl;
        
        // Parse location if it's a Google Maps URL
        if (event.location.isNotEmpty) {
          selectedGoogleMapsUrl.value = event.location;
          selectedLocationAddress.value = event.location; // Can be improved with reverse geocoding
        }
        
        // Parse start date/time
        try {
          final startDateTime = DateTime.parse(event.startTime);
          selectedStartDate.value = startDateTime;
          selectedStartTime.value = TimeOfDay.fromDateTime(startDateTime);
        } catch (e) {
          debugPrint("❌ Error parsing start time: $e");
        }
        
        // Parse end date/time
        try {
          final endDateTime = DateTime.parse(event.endTime);
          selectedEndDate.value = endDateTime;
          selectedEndTime.value = TimeOfDay.fromDateTime(endDateTime);
        } catch (e) {
          debugPrint("❌ Error parsing end time: $e");
        }
        
        debugPrint("✅ Event data loaded successfully");
      } else {
        debugPrint("❌ Failed to load event data");
        CustomSnackbar.show(
          title: "Error",
          message: "Failed to load event data",
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      debugPrint("❌ Error loading event data: $e");
      CustomSnackbar.show(
        title: "Error",
        message: "Error loading event: $e",
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Pick banner image
  Future<void> pickBanner() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        selectedBanner.value = File(image.path);
        debugPrint("🖼️ Banner selected: ${image.path}");
      }
    } catch (e) {
      debugPrint("❌ Error picking banner: $e");
      CustomSnackbar.show(
        title: "Error",
        message: "Error selecting image: $e",
        type: SnackbarType.error,
      );
    }
  }

  // Open location picker
  void openLocationPicker() {
    Get.toNamed('/locationPicker')?.then((result) {
      if (result != null && result is Map<String, dynamic>) {
        selectedLocationAddress.value = result['address'] ?? '';
        selectedLatitude.value = result['latitude'] ?? 0.0;
        selectedLongitude.value = result['longitude'] ?? 0.0;
        selectedGoogleMapsUrl.value = result['googleMapsUrl'] ?? '';
        debugPrint("📍 Location updated: ${selectedLocationAddress.value}");
      }
    });
  }

  // Set location data
  void setSelectedLocation(String address, double latitude, double longitude, String googleMapsUrl) {
    selectedLocationAddress.value = address;
    selectedLatitude.value = latitude;
    selectedLongitude.value = longitude;
    selectedGoogleMapsUrl.value = googleMapsUrl;
  }

  // Update event
  Future<void> updateEvent() async {
    if (!_validateForm()) {
      return;
    }

    try {
      isLoading.value = true;
      debugPrint("🔄 Updating event ID: ${currentEvent.value?.id}");

      final startDateTime = _combineDateTime(selectedStartDate.value!, selectedStartTime.value!);
      final endDateTime = _combineDateTime(selectedEndDate.value!, selectedEndTime.value!);

      final success = await _eventServices.updateEvent(
        eventId: currentEvent.value!.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        location: selectedGoogleMapsUrl.value.isNotEmpty 
            ? selectedGoogleMapsUrl.value 
            : selectedLocationAddress.value,
        startTime: startDateTime,
        endTime: endDateTime,
        groupId: currentEvent.value!.groupId,
        banner: selectedBanner.value,
      );

      if (success) {
        debugPrint("✅ Event updated successfully");
        CustomSnackbar.show(
          title: languageService.tr("event.editEvent.success.updated"),
          message: "",
          type: SnackbarType.success,
        );
        
        // Refresh event detail with updated data
        final eventController = Get.find<EventController>();
        await eventController.fetchEventDetail(currentEvent.value!.id);
        
        // Go back with success result
        Get.back(result: {'success': true, 'eventId': currentEvent.value!.id});
      } else {
        debugPrint("❌ Event update failed");
        CustomSnackbar.show(
          title: languageService.tr("event.editEvent.error.updateFailed"),
          message: "",
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      debugPrint("❌ Error updating event: $e");
      CustomSnackbar.show(
        title: languageService.tr("event.editEvent.error.updateFailed"),
        message: "$e",
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Validate form
  bool _validateForm() {
    if (titleController.text.trim().isEmpty) {
      CustomSnackbar.show(
        title: languageService.tr("event.createEvent.validation.titleRequired"),
        message: "",
        type: SnackbarType.error,
      );
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      CustomSnackbar.show(
        title: languageService.tr("event.createEvent.validation.descriptionRequired"),
        message: "",
        type: SnackbarType.error,
      );
      return false;
    }

    if (selectedStartDate.value == null || selectedStartTime.value == null) {
      CustomSnackbar.show(
        title: languageService.tr("event.createEvent.validation.startDateRequired"),
        message: "",
        type: SnackbarType.error,
      );
      return false;
    }

    if (selectedEndDate.value == null || selectedEndTime.value == null) {
      CustomSnackbar.show(
        title: languageService.tr("event.createEvent.validation.endDateRequired"),
        message: "",
        type: SnackbarType.error,
      );
      return false;
    }

    final startDateTime = _combineDateTime(selectedStartDate.value!, selectedStartTime.value!);
    final endDateTime = _combineDateTime(selectedEndDate.value!, selectedEndTime.value!);

    if (endDateTime.isBefore(startDateTime)) {
      CustomSnackbar.show(
        title: languageService.tr("event.createEvent.validation.endBeforeStart"),
        message: "",
        type: SnackbarType.error,
      );
      return false;
    }

    return true;
  }

  // Combine date and time
  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}
