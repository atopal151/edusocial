import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class SurveyService {
  static final _box = GetStorage();

  /// Anket oluştur ve gönder
  static Future<bool> createSurvey({
    required int receiverId,
    required bool isGroup,
    required String title,
    required bool multipleChoice,
    required List<String> choices,
  }) async {
    final token = _box.read('token');
    
    try {
      final Map<String, dynamic> requestBody = {
        'title': title,
        'multiple_choice': multipleChoice,
        'choices': choices,
      };

      // Grup anketi ise group_id, bireysel anket ise receiver_id gönder
      if (isGroup) {
        requestBody['group_id'] = receiverId;
        requestBody['is_group'] = true;
      } else {
        requestBody['receiver_id'] = receiverId;
        requestBody['is_group'] = false;
      }

      debugPrint('📊 Survey API Request Body: $requestBody');

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/survey'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('❌ Survey creation failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Survey creation error: $e');
      return false;
    }
  }

  /// Ankete cevap ver
  static Future<bool> answerSurvey({
    required int surveyId,
    required List<int> answerIds,
  }) async {
    final token = _box.read('token');
    
    try {
      final requestBody = {
        'survey_id': surveyId,
        'answer_id': answerIds.isNotEmpty ? answerIds.first : 0,
      };
      
      debugPrint('📊 Survey Answer API Request Body: $requestBody');
      
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/survey-answer'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('❌ Survey answer failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Survey answer error: $e');
      return false;
    }
  }

  /// Grup anketlerini getir
  static Future<List<Map<String, dynamic>>> getGroupSurveys(String groupId) async {
    final token = _box.read('token');
    
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/group-surveys/$groupId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        debugPrint('❌ Get group surveys failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Get group surveys error: $e');
      return [];
    }
  }
}
