import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'api_service.dart';
import 'auth_service.dart';
import 'socket_services.dart';
import '../controllers/chat_controllers/group_chat_detail_controller.dart';
import '../models/chat_models/group_message_model.dart';

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

  /// Pin or unpin a group message using socket events
  /// Returns true if successful, false otherwise
  Future<bool> pinGroupMessage(int messageId, String groupId) async {
    try {
      print('📌 [PinMessageService] Starting pin/unpin operation for message: $messageId, group: $groupId');
      
      // Get current message to determine if it's pinned or not
      // This will help us decide whether to pin or unpin
      final currentMessage = await _getCurrentMessageStatus(messageId, groupId);
      final isCurrentlyPinned = currentMessage?['is_pinned'] ?? false;
      
      print('📌 [PinMessageService] Current pin status: $isCurrentlyPinned');
      
      // Send appropriate socket event based on current status
      if (isCurrentlyPinned) {
        // Message is currently pinned, so unpin it
        print('📌 [PinMessageService] Sending group:unpin_message event');
        _socketService.sendMessage('group:unpin_message', {
          'message_id': messageId,
          'group_id': groupId,
          'is_pinned': false,
          'action': 'unpin',
        });
      } else {
        // Message is not pinned, so pin it
        print('📌 [PinMessageService] Sending group:pin_message event');
        _socketService.sendMessage('group:pin_message', {
          'message_id': messageId,
          'group_id': groupId,
          'is_pinned': true,
          'action': 'pin',
        });
      }
      
      print('✅ [PinMessageService] Socket event sent successfully');
      return true;
      
    } catch (e) {
      print('❌ [PinMessageService] Pin Group Message Error: $e');
      return false;
    }
  }

  /// Get current message status to determine if it's pinned
  Future<Map<String, dynamic>?> _getCurrentMessageStatus(int messageId, String groupId) async {
    try {
      // Try to get the message from the group chat controller
      final controller = Get.find<GroupChatDetailController>();
      
      // Find the message with the given ID
      GroupMessageModel? foundMessage;
      try {
        foundMessage = controller.messages.firstWhere(
          (msg) => msg.id == messageId.toString(),
        );
      } catch (e) {
        // Message not found
        foundMessage = null;
      }
      
      if (foundMessage != null) {
        return {
          'is_pinned': foundMessage.isPinned,
          'id': foundMessage.id,
        };
      }
      
      return null;
    } catch (e) {
      print('❌ [PinMessageService] Error getting current message status: $e');
      return null;
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
