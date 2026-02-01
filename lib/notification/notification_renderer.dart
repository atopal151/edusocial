import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationRenderer {
  Future<void> showMessage({
    required String title,
    required String message,
    String? avatar,
  }) async {
    _snackbar(
      title: title,
      message: message,
      icon: Icons.message,
      avatar: avatar,
    );
  }

  Future<void> showGroupMessage({
    required String title,
    required String message,
    String? avatar,
  }) async {
    _snackbar(
      title: title,
      message: message,
      icon: Icons.group,
      avatar: avatar,
    );
  }

  Future<void> showPostLike({
    required String title,
    required String message,
    String? avatar,
  }) async {
    _snackbar(
      title: title,
      message: message,
      icon: Icons.favorite,
      avatar: avatar,
    );
  }

  Future<void> showPostComment({
    required String title,
    required String message,
    String? avatar,
  }) async {
    _snackbar(
      title: title,
      message: message,
      icon: Icons.mode_comment,
      avatar: avatar,
    );
  }

  Future<void> showFollowRequest({
    required String title,
    required String message,
    String? avatar,
  }) async {
    _snackbar(
      title: title,
      message: message,
      icon: Icons.person_add_alt,
      avatar: avatar,
    );
  }

  Future<void> showGeneric({
    required String title,
    required String message,
    String? avatar,
    IconData icon = Icons.notifications,
  }) async {
    _snackbar(title: title, message: message, avatar: avatar, icon: icon);
  }

  void _snackbar({
    required String title,
    required String message,
    String? avatar,
    required IconData icon,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      snackStyle: SnackStyle.FLOATING,
      icon: avatar != null && avatar.isNotEmpty
          ? CircleAvatar(
              backgroundImage: NetworkImage(avatar),
              radius: 16,
            )
          : Icon(icon, color: const Color(0xFFEF5050)),
    );
  }
}

