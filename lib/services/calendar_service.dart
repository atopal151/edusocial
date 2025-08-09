import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/calendar_model.dart';
import '../utils/constants.dart';

class CalendarService {
  static final _box = GetStorage();

  /// Tüm hatırlatmaları getir
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

      /*debugPrint("📥 Calendar Response: ${response.statusCode}",wrapWidth: 1024);
      debugPrint("📥 Calendar Body: ${response.body}",wrapWidth: 1024);*/

          if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final List data = jsonBody['data'] ?? [];
      
      //print("📥 API'den gelen response: ${response.body}"); // Debug için

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

  /// Yeni hatırlatıcı ekle
  static Future<void> createReminder(Reminder reminder) async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/calendars");

    final body = jsonEncode({
      "description": reminder.title,
      "color": reminder.color,
      "send_notification": true,
      "notification_time": reminder.dateTime,
    });
    
    //print("📤 API'ye gönderilen body: $body"); // Debug için

    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Hatırlatıcı eklenemedi");
    }
  }

  /// Hatırlatıcı güncelle
  static Future<void> updateReminder(Reminder reminder) async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/calendars/${reminder.id}");

    final body = jsonEncode({
      "description": reminder.title,
      "color": reminder.color,
      "send_notification": true,
      "notification_time": reminder.dateTime,
    });
    
    //print("📤 API'ye gönderilen body (update): $body"); // Debug için

    final response = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception("Hatırlatıcı güncellenemedi");
    }
  }

  /// Hatırlatıcı sil
  static Future<void> deleteReminder(int id) async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/calendars/$id");

    final response = await http.delete(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Hatırlatıcı silinemedi");
    }
  }

 static Future<Reminder> getReminderById(int id) async {
  final token = _box.read('token');
  final uri = Uri.parse("${AppConstants.baseUrl}/calendars/$id");

  final response = await http.get(
    uri,
    headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final jsonBody = jsonDecode(response.body);
    final data = jsonBody['data'];

    return Reminder(
      id: data['id'],
      title: data['description'] ?? '',
      dateTime: data['notification_time'] ?? '',
      sendNotification: data['send_notification'] ?? true,
      color: data['color'] ?? '#36C897', // ✅ yeni alan burada
    );
  } else {
    throw Exception("Hatırlatıcı bulunamadı");
  }
}

}
