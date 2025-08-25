import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'api_service.dart';
import 'auth_service.dart';

class PinMessageService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();

  /// Pin or unpin a message
  /// Returns true if successful, false otherwise
  Future<bool> pinMessage(int messageId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        print('❌ Pin Message Error: No token available');
        return false;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final data = {
        'message_id': messageId,
      };

      final response = await _apiService.post(
        '/conversation-pin',
        data,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Message pinned/unpinned successfully');
        return true;
      } else {
        print('❌ Pin Message Error: ${response.statusCode} - ${response.data}');
        return false;
      }
    } catch (e) {
      print('❌ Pin Message Error: $e');
      return false;
    }
  }

  /// Get pinned messages for a conversation
  Future<List<Map<String, dynamic>>?> getPinnedMessages(int conversationId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        print('❌ Get Pinned Messages Error: No token available');
        return null;
      }

      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await _apiService.get(
        '/conversation-pin/$conversationId',
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        return [];
      } else {
        print('❌ Get Pinned Messages Error: ${response.statusCode} - ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Get Pinned Messages Error: $e');
      return null;
    }
  }
}
