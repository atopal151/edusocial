
// 3. event_controller.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../components/snackbars/custom_snackbar.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../services/language_service.dart';

class EventController extends GetxController {
  var isLoading = false.obs;
  var eventList = <EventModel>[].obs;
  var topEventList = <EventModel>[].obs;
  var selectedEvent = Rxn<EventModel>();

  final EventServices _eventServices = EventServices();
  final LanguageService languageService = Get.find<LanguageService>();

  @override
  void onInit() {
    super.onInit();
    fetchTopEvents();
  }

  Future<void> fetchEvents() async {
    debugPrint("🚀 EventController - fetchEvents started");
    isLoading.value = true;
    eventList.value = await _eventServices.fetchEvents();
    debugPrint("🚀 EventController - eventList count: ${eventList.length}");
    isLoading.value = false;
  }

  Future<void> fetchTopEvents() async {
    debugPrint("🚀 EventController - fetchTopEvents started");
    isLoading.value = true;
    topEventList.value = await _eventServices.fetchTopEvents();
    debugPrint("🚀 EventController - topEventList count: ${topEventList.length}");
    isLoading.value = false;
  }

  Future<void> fetchEventDetail(int eventId) async {
    debugPrint("🚀 EventController - fetchEventDetail called with ID: $eventId");
    isLoading.value = true;
    
    // Önce mevcut event listesinde bu ID var mı kontrol edelim
    final existingEvent = eventList.firstWhereOrNull((e) => e.id == eventId);
    if (existingEvent != null) {
      debugPrint("✅ EventController - Found event in local list: ${existingEvent.title}");
      selectedEvent.value = existingEvent;
      isLoading.value = false;
      return;
    }
    
    // API'den fetch et
    selectedEvent.value = await _eventServices.fetchEventDetail(eventId);
    debugPrint("📥 EventController - Event fetched from API: ${selectedEvent.value?.title ?? 'null'}");
    isLoading.value = false;
  }

  Future<bool> updateEvent({
    required int eventId,
    required String title,
    required String description,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
    required int groupId,
    File? banner,
  }) async {
    isLoading.value = true;
    final success = await _eventServices.updateEvent(
      eventId: eventId,
      title: title,
      description: description,
      location: location,
      startTime: startTime,
      endTime: endTime,
      groupId: groupId,
      banner: banner,
    );
    isLoading.value = false;
    
    if (success) {
      // Refresh events after update
      await fetchEvents();
      await fetchTopEvents();
    }
    
    return success;
  }

  Future<bool> setEventReminder(int eventId) async {
    final success = await _eventServices.setEventReminder(eventId);
    if (success) {
      // Update current event's reminder status locally
      if (selectedEvent.value?.id == eventId) {
        selectedEvent.value = selectedEvent.value?.copyWith(hasReminder: true);
      }
      
      // Update in event list as well
      final index = eventList.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        eventList[index] = eventList[index].copyWith(hasReminder: true);
      }
      
      CustomSnackbar.show(
        title: languageService.tr("event.notifications.reminder.success"),
        message: "",
        type: SnackbarType.success,
      );
    } else {
      CustomSnackbar.show(
        title: languageService.tr("event.notifications.reminder.error"),
        message: "",
        type: SnackbarType.error,
      );
    }
    return success;
  }

  // Event invitation functionality
  Future<bool> respondToEventInvitation(int eventId, int groupId, bool accept) async {
    debugPrint("🎯 Event Invitation - Event ID: $eventId, Group ID: $groupId, Accept: $accept");
    
    try {
      final success = await _eventServices.respondToEventInvitation(eventId, groupId, accept);
      
      if (success) {
        // Update local event state if available
        if (selectedEvent.value?.id == eventId) {
          // Note: We don't have specific event participation fields from API
          // This is just for local state management
          debugPrint("✅ Event invitation response successful");
        }
        
        CustomSnackbar.show(
          title: accept 
            ? languageService.tr("event.invitation.accepted")
            : languageService.tr("event.invitation.declined"),
          message: "",
          type: SnackbarType.success,
        );
      } else {
        CustomSnackbar.show(
          title: languageService.tr("event.invitation.error"),
          message: "",
          type: SnackbarType.error,
        );
      }
      
      return success;
    } catch (e) {
      debugPrint("❌ Event invitation error: $e");
      
      // Handle specific "already responded" error
      if (e.toString().contains('already_responded')) {
        CustomSnackbar.show(
          title: languageService.tr("event.invitation.alreadyResponded"),
          message: "",
          type: SnackbarType.warning,
        );
      } else {
        CustomSnackbar.show(
          title: languageService.tr("event.invitation.error"),
          message: "",
          type: SnackbarType.error,
        );
      }
      
      return false;
    }
  }

  void shareEvent(String title) {
    CustomSnackbar.show(
      title: languageService.tr("event.notifications.share.success"),
      message: "",
      type: SnackbarType.success,
    );
  }

  void showLocation(String title) {
    CustomSnackbar.show(
      title: languageService.tr("event.notifications.location.viewing"),
      message: "",
      type: SnackbarType.info,
    );
  }
}

