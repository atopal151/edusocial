import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'services/socket_services.dart';
import 'services/pin_message_service.dart';

class SocketPinTest extends StatefulWidget {
  const SocketPinTest({super.key});

  @override
  State<SocketPinTest> createState() => _SocketPinTestState();
}

class _SocketPinTestState extends State<SocketPinTest> {
  final SocketService _socketService = Get.find<SocketService>();
  final PinMessageService _pinMessageService = Get.find<PinMessageService>();
  
  List<String> pinEvents = [];
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _setupPinListener();
    _setupConnectionListener();
    _checkConnectionStatus();
  }

  void _setupPinListener() {
    _socketService.onPinMessage.listen((data) {
      if (mounted) {
        setState(() {
          pinEvents.add('Pin Event: $data');
        });
      }
      print('📌 Pin event received: $data');
    });
  }

  void _setupConnectionListener() {
    _socketService.isConnected.listen((connected) {
      if (mounted) {
        setState(() {
          isConnected = connected;
        });
      }
    });
  }

  void _checkConnectionStatus() {
    setState(() {
      isConnected = _socketService.isConnected.value;
    });
  }

  void _testPinMessage() async {
    // Test pin message (message ID 241)
    final success = await _pinMessageService.pinGroupMessage(241, '2'); // group ID 2
    if (success) {
      print('✅ Test pin message 241 sent successfully');
      setState(() {
        pinEvents.add('✅ Pin Message 241 - API call successful');
      });
    } else {
      print('❌ Test pin message 241 failed');
      setState(() {
        pinEvents.add('❌ Pin Message 241 - API call failed');
      });
    }
  }

  void _testUnpinMessage() async {
    // Test unpin message (message ID 241)
    final success = await _pinMessageService.pinGroupMessage(241, '2'); // group ID 2
    if (success) {
      print('✅ Test unpin message 241 sent successfully');
      setState(() {
        pinEvents.add('✅ Unpin Message 241 - API call successful');
      });
    } else {
      print('❌ Test unpin message 241 failed');
      setState(() {
        pinEvents.add('❌ Unpin Message 241 - API call failed');
      });
    }
  }

  void _testPinStatus() async {
    // Test pin status check
    print('🔍 Testing pin status check...');
    setState(() {
      pinEvents.add('🔍 Pin Status Check Requested');
    });
    
    // Socket üzerinden pin durumu kontrolü iste
    _socketService.sendMessage('group:get_pinned_messages', {
      'group_id': '2',
    });
    
    print('🔍 Pin status check request sent');
  }

  void _testChatMessageWithPin() async {
    // Test group:chat_message event with pin status
    print('🔍 Testing group:chat_message with pin status...');
    setState(() {
      pinEvents.add('🔍 group:chat_message with pin status test');
    });
    
    // Simulate group:chat_message event with pin status
    final testData = {
      'message': {
        'id': 242,
        'user_id': 1,
        'group_id': 2,
        'is_pinned': false, // Pin kaldırıldı
        'message': 'merhaba',
        'status': 'sent',
        'created_at': '2025-08-27T18:52:47.000000Z',
        'updated_at': '2025-08-27T20:25:00.000000Z',
        'is_me': true,
        'type': 'text',
        'user': {
          'id': 1,
          'name': 'Yasin',
          'surname': 'Timur',
          'username': 'monegon'
        }
      }
    };
    
    // Manually trigger the event
    _socketService.onGroupMessage.listen((data) {
      print('🔍 group:chat_message event received: $data');
    });
    
    print('🔍 group:chat_message test data prepared');
  }

  void _testWebUnpinSimulation() async {
    // Web'den pin kaldırma simülasyonu
    print('🔍 Testing web unpin simulation...');
    setState(() {
      pinEvents.add('🔍 Web unpin simulation test');
    });
    
    // Web'den gelen gerçek event yapısını simüle et (group:chat_message event'i)
    final webUnpinData = {
      'message': {
        'id': 213, // Log'lardan gelen mesaj ID'si
        'user_id': 6,
        'group_id': 2,
        'survey_id': null,
        'is_pinned': false, // Web'den pin kaldırıldı
        'message': null, // Log'lardan gelen mesaj içeriği
        'status': 'sent',
        'deleted_at': null,
        'created_at': '2025-08-23T18:17:17.000000Z',
        'updated_at': '2025-08-27T20:40:10.000000Z',
        'is_me': false,
        'time': '18:17',
        'is_read': true,
        'type': 'text',
        'user': {
          'id': 6,
          'account_type': 'private',
          'language_id': 2,
          'avatar': 'avatars/xkTSXvr06BFYSLYocvZl2nzwXHqSiIxRK73MHChf.jpg',
          'banner': 'banners/zMmP4TdlEI8RuvDFgoOdlXvD7Y34y8ZMbpqpZNrf.jpg',
          'description': 'Lorem ipsum',
          'school_id': 1,
          'school_department_id': 1,
          'name': 'Alaettin',
          'surname': 'Topal',
          'phone': '05333333333',
          'username': 'alaettin',
          'email': 'atopal@gmail.com',
          'email_verified_at': null,
          'birthday': '1996-01-10T00:00:00.000000Z',
          'instagram': 'atopal',
          'tiktok': null,
          'twitter': 'atopal',
          'facebook': null,
          'linkedin': null,
          'notification_email': true,
          'notification_mobile': true,
          'is_active': true,
          'is_online': true,
          'is_verified': false,
          'deleted_at': null,
          'created_at': '2025-05-29T10:01:49.000000Z',
          'updated_at': '2025-08-08T13:13:13.000000Z'
        }
      }
    };
    
    // Bu event'i manuel olarak tetikle
    print('🔍 Web unpin simulation data prepared');
    print('🔍 Message ID: 213, is_pinned: false');
    print('🔍 Bu event group:chat_message olarak gelmeli ve PinnedMessagesWidget\'ı güncellemeli');
    
    setState(() {
      pinEvents.add('🔍 Web unpin simulation: Message 213 pin kaldırıldı');
    });
  }

  // Çıktı alanını kopyalama fonksiyonu
  void _copyOutputToClipboard() {
    if (pinEvents.isEmpty) {
      Get.snackbar(
        'Kopyalama Hatası',
        'Kopyalanacak veri bulunamadı',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
      );
      return;
    }

    final outputText = pinEvents.join('\n');
    Clipboard.setData(ClipboardData(text: outputText));
    
    Get.snackbar(
      'Kopyalandı!',
      '${pinEvents.length} satır panoya kopyalandı',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      duration: const Duration(seconds: 2),
    );
  }

  void _testAdminPinFeature() async {
    // Test admin pin feature
    print('🔍 Testing admin pin feature...');
    setState(() {
      pinEvents.add('🔍 Admin pin feature test');
    });
    
    // Test pin message (message ID 242)
    final success = await _pinMessageService.pinGroupMessage(242, '2'); // group ID 2
    if (success) {
      print('✅ Admin pin feature test successful');
      setState(() {
        pinEvents.add('✅ Admin pin feature test successful');
      });
    } else {
      print('❌ Admin pin feature test failed');
      setState(() {
        pinEvents.add('❌ Admin pin feature test failed');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket Pin Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Socket Connection Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isConnected ? Icons.check_circle : Icons.error,
                          color: isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isConnected ? 'Connected' : 'Disconnected',
                          style: TextStyle(
                            color: isConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Actions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _testPinMessage,
                            child: const Text('Pin Message 241'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _testUnpinMessage,
                            child: const Text('Unpin Message 241'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _testPinStatus,
                        child: const Text('Check Pin Status'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _testChatMessageWithPin,
                        child: const Text('Test Chat Message Pin'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _testAdminPinFeature,
                        child: const Text('Test Admin Pin Feature'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _testWebUnpinSimulation,
                        child: const Text('Test Web Unpin Simulation'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Pin Events List
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Pin Events (${pinEvents.length})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          if (pinEvents.isNotEmpty) ...[
                            IconButton(
                              onPressed: _copyOutputToClipboard,
                              icon: const Icon(Icons.copy, size: 20),
                              tooltip: 'Kopyala',
                              color: Colors.blue,
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  pinEvents.clear();
                                });
                              },
                              child: const Text('Clear'),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: pinEvents.isEmpty
                            ? const Center(
                                child: Text(
                                  'No pin events received yet...',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: SelectableText(
                                  pinEvents.join('\n'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    height: 1.4,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
