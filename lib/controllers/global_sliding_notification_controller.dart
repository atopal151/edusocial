import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Global kayan bildirim controller'ı
class GlobalSlidingNotificationController extends GetxController {
  final RxBool showSlidingNotification = false.obs;
  final RxString slidingNotificationTitle = ''.obs;
  final RxString slidingNotificationMessage = ''.obs;
  final RxString slidingNotificationAvatar = ''.obs;
  final RxString slidingNotificationType = ''.obs;
  Timer? slidingNotificationTimer;

  void showNotification({
    required String title,
    required String message,
    required String avatar,
    required String type,
  }) {
    // Önceki timer'ı iptal et
    slidingNotificationTimer?.cancel();
    
    // Bildirim verilerini ayarla
    slidingNotificationTitle.value = title;
    slidingNotificationMessage.value = message;
    slidingNotificationAvatar.value = avatar;
    slidingNotificationType.value = type;
    
    // Bildirimi göster
    showSlidingNotification.value = true;
    
    // 3 saniye sonra gizle
    slidingNotificationTimer = Timer(const Duration(seconds: 3), () {
      showSlidingNotification.value = false;
    });
    
    debugPrint('📱 Global kayan bildirim gösterildi: $title - $message');
  }

  @override
  void onClose() {
    slidingNotificationTimer?.cancel();
    super.onClose();
  }
} 