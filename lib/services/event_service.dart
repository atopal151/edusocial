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


      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'];
        return data.map((e) => EventModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❗ Events çekilirken hata: $e", wrapWidth: 1024);
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

      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);


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
      }

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        
      

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
      

      // Try multiple endpoints since server returns 405
      String updateUrl = "${AppConstants.baseUrl}/event/$eventId";
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(updateUrl),
      );
      

      // Headers
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      // Form fields - try without _method first
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

      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);


      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Event updated successfully");
        return true;
      } else if (response.statusCode == 405) {
        debugPrint("🔄 405 error, trying alternative endpoint /events/$eventId");
        
        // Try alternative endpoint
        var alternativeRequest = http.MultipartRequest(
          'POST',
          Uri.parse("${AppConstants.baseUrl}/events/$eventId"),
        );
        
        alternativeRequest.headers.addAll({
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        });
        
        alternativeRequest.fields.addAll({
          'title': title,
          'description': description,
          'location': location,
          'start_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(startTime),
          'end_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(endTime),
          'group_id': groupId.toString(),
          // Try without _method first
        });
        
        if (banner != null) {
          alternativeRequest.files.add(
            await http.MultipartFile.fromPath(
              'banner',
              banner.path,
            ),
          );
        }
        
        var alternativeResponse = await alternativeRequest.send();
   
        
        if (alternativeResponse.statusCode == 200 || alternativeResponse.statusCode == 201) {
          debugPrint("✅ Event updated successfully via alternative endpoint");
          return true;
        } else {
          debugPrint("❌ Event update failed on both endpoints");
          return false;
        }
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
