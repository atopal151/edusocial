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

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Reminder(
        id: e['id'],
        title: e['description'] ?? '',
        dateTime: e['notification_time'] ?? '',
      )).toList();
    } else {
      throw Exception("Takvim verileri alınamadı");
    }
  }

  /// Yeni hatırlatıcı ekle
  static Future<void> createReminder(Reminder reminder) async {
    final token = _box.read('token');
    final uri = Uri.parse("${AppConstants.baseUrl}/calendars");

    final body = jsonEncode({
      "description": reminder.title,
      "color": "#36C897",
      "send_notification": true,
      "notification_time": reminder.dateTime,
    });

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
      "color": "#36C897",
      "send_notification": true,
      "notification_time": reminder.dateTime,
    });

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
      final data = jsonDecode(response.body);
      return Reminder(
        id: data['id'],
        title: data['description'] ?? '',
        dateTime: data['notification_time'] ?? '',
        sendNotification: data['send_notification'] ?? true,
      );
    } else {
      throw Exception("Hatırlatıcı bulunamadı");
    }
  }
}