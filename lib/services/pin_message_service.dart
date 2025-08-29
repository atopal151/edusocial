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

      // Web'den gelen başarılı request'i analiz etmek için farklı data yapıları deneyelim
      List<Map<String, dynamic>> testDataList = [
        // Test 1: Sadece message_id (private chat gibi)
        {'message_id': messageId},
        
        // Test 2: message_id + group_id
        {'message_id': messageId, 'group_id': groupId},
        
        // Test 3: message_id + conversation_id (group_id'yi conversation_id olarak)
        {'message_id': messageId, 'conversation_id': groupId},
        
        // Test 4: message_id + group_id + conversation_id
        {'message_id': messageId, 'group_id': groupId, 'conversation_id': groupId},
      ];

      List<String> testEndpoints = [
        '/conversation-pin',
        '/group-pin', 
        '/group-conversation-pin',
        '/pin-message',
        '/message-pin'
      ];

      // Her endpoint ve data kombinasyonunu dene
      for (String endpoint in testEndpoints) {
        for (Map<String, dynamic> data in testDataList) {
          try {
            print('🔍 [PinMessageService] Testing endpoint: $endpoint with data: $data');
            
            final response = await _apiService.post(endpoint, data, headers: headers);
            
            print('✅ [PinMessageService] SUCCESS! Endpoint: $endpoint, Data: $data');
            print('📌 [PinMessageService] API Response Status: ${response.statusCode}');
            print('📌 [PinMessageService] API Response Body: ${response.data}');

            if (response.statusCode == 200 || response.statusCode == 201) {
              final responseData = response.data;
              
              // API response'undan pin durumunu al
              bool isPinned = false;
              if (responseData is Map<String, dynamic>) {
                if (responseData.containsKey('is_pinned')) {
                  isPinned = responseData['is_pinned'] ?? false;
                } else if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
                  isPinned = responseData['data']['is_pinned'] ?? false;
                }
              }
              
              print('✅ [PinMessageService] Group message pinned/unpinned successfully');
              print('📌 [PinMessageService] Final pin status: $isPinned');
              print('📌 [PinMessageService] Working endpoint: $endpoint');
              print('📌 [PinMessageService] Working data: $data');

              // Send socket event for real-time updates
              _socketService.sendMessage('group:pin_message', {
                'message_id': messageId,
                'group_id': groupId,
                'is_pinned': isPinned,
                'action': isPinned ? 'pin' : 'unpin',
              });

              return true;
            }
          } catch (e) {
            print('❌ [PinMessageService] Failed - Endpoint: $endpoint, Data: $data, Error: $e');
            continue; // Sonraki kombinasyonu dene
          }
        }
      }

      print('❌ [PinMessageService] All endpoint and data combinations failed');
      return false;
      
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
