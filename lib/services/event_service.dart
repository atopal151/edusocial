import 'dart:convert';
import 'dart:io';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:edusocial/models/event_model.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class EventServices {
  
  // Helper method to print long strings without truncation
  void _printLongString(String prefix, String text) {
    const int maxLength = 800; // Flutter debugPrint limit is around 1000 chars
    
    if (text.length <= maxLength) {
      debugPrint("$prefix: $text");
      return;
    }
    
    debugPrint("$prefix (PART 1/${(text.length / maxLength).ceil()}): ${text.substring(0, maxLength)}");
    
    for (int i = maxLength; i < text.length; i += maxLength) {
      int end = (i + maxLength < text.length) ? i + maxLength : text.length;
      int partNumber = (i / maxLength).round() + 1;
      int totalParts = (text.length / maxLength).ceil();
      debugPrint("$prefix (PART $partNumber/$totalParts): ${text.substring(i, end)}");
    }
  }
  Future<List<EventModel>> fetchEvents() async {
    try {
      final token = GetStorage().read("token");

      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/events"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint("📥 Events Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'];
        return data.map((e) => EventModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      /*debugPrint("❗ Events çekilirken hata: $e", wrapWidth: 1024);*/
      return [];
    }
  }

  Future<bool> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
    required int groupId,
    File? banner,
  }) async {
    try {
      final token = GetStorage().read("token");
      
      debugPrint("🚀 Creating event with:");
      debugPrint("  - Title: $title");
      debugPrint("  - Description: $description");
      debugPrint("  - Location: $location");
      debugPrint("  - Start Time: $startTime");
      debugPrint("  - End Time: $endTime");
      debugPrint("  - Group ID: $groupId");
      debugPrint("  - Banner: ${banner?.path ?? 'No banner'}");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${AppConstants.baseUrl}/events"),
      );

      // Headers
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      // Form fields
      request.fields.addAll({
        'title': title,
        'description': description,
        'location': location,
        'start_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(startTime),
        'end_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(endTime),
        'group_id': groupId.toString(),
      });

      // Banner file
      if (banner != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'banner',
            banner.path,
          ),
        );
      }

      debugPrint("📤 Sending event creation request...");
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("📥 Create Event Response: ${response.statusCode}");
      debugPrint("📥 Create Event Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Event created successfully");
        return true;
      } else {
        debugPrint("❌ Event creation failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("💥 Event creation error: $e");
      debugPrint("📛 Stack trace: $stackTrace");
      return false;
    }
  }

  // Top 5 events
  Future<List<EventModel>> fetchTopEvents() async {
    try {
      final token = GetStorage().read("token");

      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/top-events"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint("📥 Top Events Response: ${response.statusCode}");
      _printLongString("📥 Top Events Body", response.body);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'];
        return data.map((e) => EventModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❗ Top Events çekilirken hata: $e");
      return [];
    }
  }

  // Event detail
  Future<EventModel?> fetchEventDetail(int eventId) async {
    try {
      final token = GetStorage().read("token");

      // Önce POST /events/{id} dene
      var response = await http.post(
        Uri.parse("${AppConstants.baseUrl}/events/$eventId"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({}),
      );

      debugPrint("📥 Event Detail Response (POST /events/$eventId): ${response.statusCode}");

      // Eğer 405 (Method Not Allowed) alırsan GET dene
      if (response.statusCode == 405) {
        debugPrint("🔄 Trying GET method instead...");
        response = await http.get(
          Uri.parse("${AppConstants.baseUrl}/events/$eventId"),
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        );
        debugPrint("📥 Event Detail Response (GET /events/$eventId): ${response.statusCode}");
      }

      // Eğer hala başarısız ise /event/{id} dene
      if (response.statusCode != 200) {
        debugPrint("🔄 Trying /event/$eventId endpoint...");
        response = await http.get(
          Uri.parse("${AppConstants.baseUrl}/event/$eventId"),
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        );
        debugPrint("📥 Event Detail Response (GET /event/$eventId): ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        _printLongString("📥 Event Detail Body", response.body);
        
        // Alternative: Use dart:developer log for better viewing
        if (kDebugMode) {
          print("=== FULL EVENT DETAIL JSON START ===");
          print("=== FULL EVENT DETAIL JSON END ===");
        }

        return EventModel.fromJson(body['data']);
      } else {
        debugPrint("❌ Event detail failed with status: ${response.statusCode}");
        debugPrint("❌ Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❗ Event detayı çekilirken hata: $e");
      return null;
    }
  }

  // Event update
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
    try {
      final token = GetStorage().read("token");
      
      debugPrint("🔄 Updating event $eventId with:");
      debugPrint("  - Title: $title");
      debugPrint("  - Description: $description");
      debugPrint("  - Location: $location");
      debugPrint("  - Start Time: $startTime");
      debugPrint("  - End Time: $endTime");
      debugPrint("  - Group ID: $groupId");
      debugPrint("  - Banner: ${banner?.path ?? 'No banner'}");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${AppConstants.baseUrl}/event/$eventId"),
      );

      // Headers
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      // Form fields
      request.fields.addAll({
        'title': title,
        'description': description,
        'location': location,
        'start_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(startTime),
        'end_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(endTime),
        'group_id': groupId.toString(),
        '_method': 'PUT', // Laravel method spoofing
      });

      // Banner file
      if (banner != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'banner',
            banner.path,
          ),
        );
      }

      debugPrint("📤 Sending event update request...");
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("📥 Update Event Response: ${response.statusCode}");
      debugPrint("📥 Update Event Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Event updated successfully");
        return true;
      } else {
        debugPrint("❌ Event update failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("💥 Event update error: $e");
      debugPrint("📛 Stack trace: $stackTrace");
      return false;
    }
  }

  // Event reminder
  Future<bool> setEventReminder(int eventId) async {
    try {
      final token = GetStorage().read("token");

      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}/event_reminders"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'event_id': eventId,
        }),
      );

      debugPrint("📥 Event Reminder Response: ${response.statusCode}");
      debugPrint("📥 Event Reminder Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Event reminder set successfully");
        return true;
      } else {
        debugPrint("❌ Event reminder failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("💥 Event reminder error: $e");
      return false;
    }
  }

  // Respond to event invitation
  Future<bool> respondToEventInvitation(int eventId, int groupId, bool accept) async {
    try {
      final token = GetStorage().read("token");
      final profileController = Get.find<ProfileController>();
      final userId = profileController.userId.value;
      
      debugPrint("🎯 Responding to event invitation:");
      debugPrint("  - Event ID: $eventId");
      debugPrint("  - Group ID: $groupId");
      debugPrint("  - User ID: $userId");
      debugPrint("  - Decision: ${accept ? 'accept' : 'decline'}");
      
      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}/event-invitation"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "user_id": userId,
          "group_id": groupId,
          "event_id": eventId,
          "decision": accept ? "accept" : "decline",
        }),
      );

      debugPrint("📥 Event Invitation Response: ${response.statusCode}");
      debugPrint("📥 Event Invitation Body: ${response.body}");

      if (response.statusCode == 422) {
        final body = jsonDecode(response.body);
        if (body['message']?.toString().contains('already responded') == true) {
          throw Exception('already_responded');
        }
      }

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❗ Event invitation yanıtlanırken hata: $e");
      rethrow; // Re-throw to handle specific exceptions in controller
    }
  }
}
