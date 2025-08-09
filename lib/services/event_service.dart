import 'dart:convert';
import 'dart:io';
import 'package:edusocial/models/event_model.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class EventServices {
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

      /*debugPrint("📥 Events Response: ${response.statusCode}", wrapWidth: 1024);
      debugPrint("📥 Events Body: ${response.body}", wrapWidth: 1024);*/

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

      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/event/$eventId"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint("📥 Event Detail Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return EventModel.fromJson(body['data']);
      } else {
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

  // Event invitation response (accept/decline)
  Future<bool> respondToEventInvitation(int eventId, bool accept) async {
    try {
      final token = GetStorage().read("token");

      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}/event-invitation"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'event_id': eventId,
          'status': accept ? 'accepted' : 'declined',
        }),
      );

      debugPrint("📥 Event Invitation Response: ${response.statusCode}");
      debugPrint("📥 Event Invitation Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Event invitation response sent successfully");
        return true;
      } else {
        debugPrint("❌ Event invitation response failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("💥 Event invitation response error: $e");
      return false;
    }
  }
}
