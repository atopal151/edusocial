import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'api_service.dart';
import 'auth_service.dart';
import 'socket_services.dart';

class PinMessageService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();
  final SocketService _socketService = Get.find<SocketService>();

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
        print('✅ API Response: ${response.data}');
        
        // Determine if message was pinned or unpinned based on response
        final isPinned = response.data['is_pinned'] ?? response.data['isPinned'] ?? false;
        
        // Send socket event for real-time updates
        _socketService.sendMessage('conversation:pin_message', {
          'message_id': messageId,
          'conversation_id': response.data['conversation_id']?.toString() ?? response.data['conversationId']?.toString(),
          'is_pinned': isPinned,
          'action': isPinned ? 'pin' : 'unpin',
        });
        
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

  /// Pin or unpin a group message
  /// Returns true if successful, false otherwise
  Future<bool> pinGroupMessage(int messageId, String groupId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        print('❌ Pin Group Message Error: No token available');
        return false;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final data = {
        'message_id': messageId,
        'group_id': groupId,
      };

      final response = await _apiService.post(
        '/conversation-pin',
        data,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Group message pinned/unpinned successfully');
        print('✅ API Response: ${response.data}');
        
        // Determine if message was pinned or unpinned based on response
        final isPinned = response.data['is_pinned'] ?? response.data['isPinned'] ?? false;
        
        // Send socket event for real-time updates
        if (isPinned) {
          // Pin işlemi için group:pin_message event'i kullan
          _socketService.sendMessage('group:pin_message', {
            'message': {
              'id': messageId,
              'group_id': groupId,
              'is_pinned': true,
              'action': 'pin',
            }
          });
        } else {
          // Unpin işlemi için group:chat_message event'i kullan
          _socketService.sendMessage('group:chat_message', {
            'message': {
              'id': messageId,
              'group_id': groupId,
              'is_pinned': false,
              'action': 'unpin',
            }
          });
        }
        
        return true;
      } else {
        print('❌ Pin Group Message Error: ${response.statusCode} - ${response.data}');
        return false;
      }
    } catch (e) {
      print('❌ Pin Group Message Error: $e');
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
