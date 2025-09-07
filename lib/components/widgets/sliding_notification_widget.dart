import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/global_sliding_notification_controller.dart';

class SlidingNotificationWidget extends StatelessWidget {
  const SlidingNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GlobalSlidingNotificationController>();
    
    return Obx(() {
      if (!controller.showSlidingNotification.value) {
        return const SizedBox.shrink();
      }
      
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon container with background
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getIconBackgroundColor(controller.slidingNotificationType.value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getNotificationIcon(controller.slidingNotificationType.value),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.slidingNotificationTitle.value,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff272727),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.slidingNotificationMessage.value,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff9ca3ae),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Close button
                  GestureDetector(
                    onTap: () {
                      controller.showSlidingNotification.value = false;
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xfff5f5f5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xff9ca3ae),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Color _getIconBackgroundColor(String type) {
    switch (type) {
      case 'like':
      case 'post-like':
        return const Color(0xFFEF5050); // Red for likes
      case 'comment':
      case 'post-comment':
        return const Color(0xFF4CAF50); // Green for comments
      case 'follow':
      case 'follow-request':
        return const Color(0xFF2196F3); // Blue for follows
      case 'message':
        return const Color(0xFF9C27B0); // Purple for messages
      case 'group':
      case 'group-message':
        return const Color(0xFFFF9800); // Orange for group messages
      case 'event':
      case 'event-invitation':
        return const Color(0xFF607D8B); // Blue grey for events
      default:
        return const Color(0xFFEF5050); // Default red
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'like':
      case 'post-like':
        return Icons.favorite; // Heart for likes
      case 'comment':
      case 'post-comment':
        return Icons.comment; // Comment icon
      case 'follow':
      case 'follow-request':
        return Icons.person_add; // Person add for follows
      case 'message':
        return Icons.message; // Message icon
      case 'group':
      case 'group-message':
        return Icons.group; // Group icon
      case 'event':
      case 'event-invitation':
        return Icons.event; // Event icon
      default:
        return Icons.notifications; // Default notification icon
    }
  }
}
