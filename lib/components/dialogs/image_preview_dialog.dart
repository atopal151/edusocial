import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ImagePreviewDialog extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;
  final String? userName;
  final DateTime? timestamp;

  const ImagePreviewDialog({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.userName,
    this.timestamp,
  });

  @override
  State<ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<ImagePreviewDialog>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  double _scale = 1.0;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Start entrance animation
    _animationController.forward();

    // Set system UI overlay style for fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _handleDoubleTap() {
    setState(() {
      if (_isZoomed) {
        _transformationController.value = Matrix4.identity();
        _scale = 1.0;
        _isZoomed = false;
      } else {
        _transformationController.value = Matrix4.identity()..scale(2.0);
        _scale = 2.0;
        _isZoomed = true;
      }
    });
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      Get.back();
    });
  }

  Widget _buildImageWidget() {
    if (widget.imageUrl.startsWith('file://')) {
      final file = File(Uri.parse(widget.imageUrl).path);
      return Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else if (widget.imageUrl.startsWith('http')) {
      return Image.network(
        widget.imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget(loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else {
      // Local asset or relative path
      final fullUrl = widget.imageUrl.startsWith('/')
          ? widget.imageUrl
          : 'https://stageapi.edusocial.pl/storage/${widget.imageUrl}';
      
      return Image.network(
        fullUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget(loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }
  }

  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
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
          ),
          const SizedBox(height: 16),
          Text(
            'Loading image...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 64,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load image',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleClose();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Stack(
                children: [
                  // Background tap to close
                  GestureDetector(
                    onTap: _handleClose,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.transparent,
                    ),
                  ),

                  // Image with zoom functionality
                  Center(
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.5,
                      maxScale: 4.0,
                      onInteractionUpdate: (details) {
                        setState(() {
                          _scale = _transformationController.value.getMaxScaleOnAxis();
                          _isZoomed = _scale > 1.1;
                        });
                      },
                      child: GestureDetector(
                        onDoubleTap: _handleDoubleTap,
                        child: widget.heroTag != null
                            ? Hero(
                                tag: widget.heroTag!,
                                child: _buildImageWidget(),
                              )
                            : _buildImageWidget(),
                      ),
                    ),
                  ),

                  // Top overlay with user info and close button
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          // User info
                          if (widget.userName != null) ...[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.userName!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (widget.timestamp != null)
                                    Text(
                                      _formatTimestamp(widget.timestamp!),
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ] else
                            Spacer(),

                          // Close button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _handleClose,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom overlay with zoom info
                  if (_isZoomed)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: MediaQuery.of(context).padding.bottom + 16,
                          top: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black54,
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${(_scale * 100).toInt()}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Helper function to show image preview
void showImagePreview({
  required String imageUrl,
  String? heroTag,
  String? userName,
  DateTime? timestamp,
}) {
  Get.dialog(
    ImagePreviewDialog(
      imageUrl: imageUrl,
      heroTag: heroTag,
      userName: userName,
      timestamp: timestamp,
    ),
    barrierDismissible: true,
    barrierColor: Colors.black87,
    transitionDuration: Duration(milliseconds: 300),
    transitionCurve: Curves.easeOutCubic,
  );
} 