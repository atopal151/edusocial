import 'dart:convert';
import 'package:edusocial/components/print_full_text.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/calendar_model.dart';
import '../utils/constants.dart';

class CalendarService {
  static final _box = GetStorage();

  /// 📋 Tüm hatırlatmaları getir (Calendar Get)
  static Future<List<Reminder>> getReminders() async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/calendars");

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      // 🔍 API response'u debug print et
      printFullText("📦 Calendar Get Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final List data = jsonBody['data'] ?? [];
        
        return data.map((e) => Reminder.fromJson(e)).toList();
      } else {
        throw Exception(
            "Takvim verileri alınamadı. Status code: ${response.statusCode}");
      }
    } catch (e) {
      /*debugPrint("❗ getReminders hatası: $e");*/
      rethrow;
    }
  }

  /// ➕ Yeni hatırlatıcı ekle (Calendar Set)
  static Future<void> createReminder(Reminder reminder) async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/calendars");

    final body = jsonEncode({
      "description": reminder.title,
      "color": reminder.color,
      "send_notification": reminder.sendNotification,
      "notification_time": reminder.dateTime,
    });
    
    // 🔍 API request'ini debug print et
    printFullText("📤 Calendar Create Request Body: $body");

    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: body,
    );

    // 🔍 API response'u debug print et
    printFullText("📦 Calendar Create Response: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Hatırlatıcı eklenemedi. Status: ${response.statusCode}");
    }
  }

  /// ✏️ Hatırlatıcı güncelle (Calendar Update)
  static Future<void> updateReminder(Reminder reminder) async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/calendars/${reminder.id}");

    final body = jsonEncode({
      "description": reminder.title,
      "color": reminder.color,
      "send_notification": reminder.sendNotification,
      "notification_time": reminder.dateTime,
    });
    
    // 🔍 API request'ini debug print et
    printFullText("📤 Calendar Update Request Body: $body");

    final response = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: body,
    );

    // 🔍 API response'u debug print et
    printFullText("📦 Calendar Update Response: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Hatırlatıcı güncellenemedi. Status: ${response.statusCode}");
    }
  }

  /// 🗑️ Hatırlatıcı sil (Calendar Delete)
  static Future<void> deleteReminder(int id) async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/calendars/$id");

    // 🔍 API request'ini debug print et
    printFullText("📤 Calendar Delete Request - ID: $id");

    final response = await http.delete(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    // 🔍 API response'u debug print et
    printFullText("📦 Calendar Delete Response: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Hatırlatıcı silinemedi. Status: ${response.statusCode}");
    }
  }

  /// 🔍 Belirli hatırlatıcıyı getir (Calendar Show)
  static Future<Reminder> getReminderById(int id) async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/calendars/$id");

    // 🔍 API request'ini debug print et
    printFullText("📤 Calendar Show Request - ID: $id");

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    // 🔍 API response'u debug print et
    printFullText("📦 Calendar Show Response: ${response.body}");

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final data = jsonBody['data'];

      return Reminder(
        id: data['id'],
        title: data['description'] ?? '',
        dateTime: data['notification_time'] ?? '',
        sendNotification: data['send_notification'] ?? true,
        color: data['color'] ?? '#36C897',
      );
    } else {
      throw Exception("Hatırlatıcı bulunamadı. Status: ${response.statusCode}");
    }
  }

}
