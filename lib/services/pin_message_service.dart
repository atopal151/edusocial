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

  /// Pin or unpin a group message using API endpoint
  /// Returns true if successful, false otherwise
  Future<bool> pinGroupMessage(int messageId, String groupId) async {
    try {
      print('📌 [PinMessageService] Starting pin/unpin operation for message: $messageId, group: $groupId');
      
      final token = await _authService.getToken();
      if (token == null) {
        print('❌ Pin Group Message Error: No token available');
        return false;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Başarılı olan endpoint ve format
      final data = {
        'message_id': messageId,
        'group_id': int.tryParse(groupId) ?? groupId,
      };

      print('🔍 [PinMessageService] Using successful endpoint: /group-message-pin, format: $data');

      final response = await _apiService.post(
        '/group-message-pin',
        data,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [PinMessageService] Group message pinned/unpinned successfully');
        print('✅ [PinMessageService] API Response: ${response.data}');
        
        // API response'undan pin durumunu al
        bool isPinned = false;
        if (response.data is Map<String, dynamic>) {
          if (response.data.containsKey('data') && response.data['data'] is Map<String, dynamic>) {
            isPinned = response.data['data']['is_pinned'] ?? false;
          } else if (response.data.containsKey('is_pinned')) {
            isPinned = response.data['is_pinned'] ?? false;
          }
        }
        
        print('📌 [PinMessageService] Final pin status: $isPinned');

        // Send socket event for real-time updates
        _socketService.sendMessage('group:pin_message', {
          'message_id': messageId,
          'group_id': groupId,
          'is_pinned': isPinned,
          'action': isPinned ? 'pin' : 'unpin',
        });

        return true;
      } else {
        print('❌ [PinMessageService] Group message pin/unpin failed: ${response.statusCode} - ${response.data}');
        return false;
      }
      
    } catch (e) {
      print('❌ [PinMessageService] Pin Group Message Error: $e');
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
