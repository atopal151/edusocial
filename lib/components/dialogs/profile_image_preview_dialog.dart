import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileImagePreviewDialog extends StatefulWidget {
  final String imageUrl;
  final String? title;
  final double initialSize;
  final Offset initialPosition;

  const ProfileImagePreviewDialog({
    super.key,
    required this.imageUrl,
    this.title,
    required this.initialSize,
    required this.initialPosition,
  });

  @override
  State<ProfileImagePreviewDialog> createState() => _ProfileImagePreviewDialogState();
}

class _ProfileImagePreviewDialogState extends State<ProfileImagePreviewDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _positionAnimation;
  
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _closeDialog() {
    _fadeController.reverse().then((_) {
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Container(
            color: Colors.black.withOpacity(0.8 * _fadeAnimation.value),
            child: Stack(
              children: [
                // Background tap to close
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeDialog,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),

                // Main image container
                Center(
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: MediaQuery.of(context).size.height * 0.75,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Stack(
                              children: [
                                // Image
                                Positioned.fill(
                                  child: _buildImage(),
                                ),

                                // Gradient overlay for better text visibility
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.3),
                                          Colors.transparent,
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.4),
                                        ],
                                        stops: const [0.0, 0.2, 0.8, 1.0],
                                      ),
                                    ),
                                  ),
                                ),

                                // Top controls
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).padding.top + 20,
                                      left: 20,
                                      right: 20,
                                      bottom: 20,
                                    ),
                                    child: Row(
                                      children: [
                                       

                                        // Close button
                                        GestureDetector(
                                          onTap: _closeDialog,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.6),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Bottom controls
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                      bottom: MediaQuery.of(context).padding.bottom + 20,
                                      top: 20,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Zoom info
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.zoom_in,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage() {
    // Check if it's a network image or asset image
    if (widget.imageUrl.startsWith('http://') || widget.imageUrl.startsWith('https://')) {
      return Image.network(
        widget.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Yükleniyor...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Görsel yüklenemedi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lütfen internet bağlantınızı kontrol edin',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Asset image
      return Image.asset(
        widget.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Görsel bulunamadı',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}

// Helper function to show the dialog
void showProfileImagePreviewDialog({
  required String imageUrl,
  String? title,
  required BuildContext context,
  required RenderBox renderBox,
}) {
  final size = renderBox.size;
  final position = renderBox.localToGlobal(Offset.zero);
  
  Get.dialog(
    ProfileImagePreviewDialog(
      imageUrl: imageUrl,
      title: title,
      initialSize: size.width,
      initialPosition: position,
    ),
    barrierDismissible: true,
    barrierColor: Colors.transparent,
  );
} 