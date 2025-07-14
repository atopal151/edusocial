import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class ApiHelper {
  static final _box = GetStorage();
  static const Duration _defaultTimeout = Duration(seconds: 10);

  static Map<String, String> get _defaultHeaders => {
    'Authorization': 'Bearer ${_box.read('token')}',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// 🔒 Güvenli GET isteği
  static Future<http.Response?> safeGet(
    String endpoint, {
    Duration? timeout,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final headers = {..._defaultHeaders, ...?additionalHeaders};
      final response = await http
          .get(Uri.parse('${AppConstants.baseUrl}$endpoint'), headers: headers)
          .timeout(timeout ?? _defaultTimeout);
      
      debugPrint('📥 API GET $endpoint - Status: ${response.statusCode}');
      return response;
    } on SocketException {
      debugPrint('❌ Network error for $endpoint');
      return null;
    } on TimeoutException {
      debugPrint('⏰ Timeout for $endpoint');
      return null;
    } catch (e) {
      debugPrint('❌ Unexpected error for $endpoint: $e');
      return null;
    }
  }

  /// 🔒 Güvenli POST isteği
  static Future<http.Response?> safePost(
    String endpoint,
    Map<String, dynamic> body, {
    Duration? timeout,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final headers = {..._defaultHeaders, ...?additionalHeaders};
      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(timeout ?? _defaultTimeout);
      
      debugPrint('📤 API POST $endpoint - Status: ${response.statusCode}');
      return response;
    } on SocketException {
      debugPrint('❌ Network error for $endpoint');
      return null;
    } on TimeoutException {
      debugPrint('⏰ Timeout for $endpoint');
      return null;
    } catch (e) {
      debugPrint('❌ Unexpected error for $endpoint: $e');
      return null;
    }
  }

  /// 🔒 JSON parsing güvenliği
  static T? safeParse<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      if (json == null) return null;
      if (json is Map<String, dynamic>) {
        return fromJson(json);
      }
      return null;
    } catch (e) {
      debugPrint('❌ JSON parse error: $e');
      return null;
    }
  }

  /// 🔒 List parsing güvenliği
  static List<T> safeParseList<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      if (json == null || json is! List) return [];
      return json
          .map((item) => safeParse(item, fromJson))
          .where((item) => item != null)
          .cast<T>()
          .toList();
    } catch (e) {
      debugPrint('❌ List parse error: $e');
      return [];
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
} 