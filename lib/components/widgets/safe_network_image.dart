import 'package:flutter/material.dart';

class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? color;
  final BlendMode? colorBlendMode;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.color,
    this.colorBlendMode,
  });

  @override
  Widget build(BuildContext context) {
    // URL null veya boş ise direkt error widget göster
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _buildErrorWidget();
    }

    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return placeholder ??
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: Colors.grey[400],
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('🖼️ Image load error for $imageUrl: $error');
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.grey[400],
            size: (width != null && height != null) 
                ? (width! < height! ? width! * 0.4 : height! * 0.4) 
                : 24,
          ),
        );
  }
}

/// Avatar için özel safe image widget
class SafeAvatarImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Widget? placeholder;

  const SafeAvatarImage({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: (imageUrl != null && imageUrl!.trim().isNotEmpty)
          ? NetworkImage(imageUrl!)
          : null,
      onBackgroundImageError: (exception, stackTrace) {
        debugPrint('🖼️ Avatar image load error: $exception');
      },
      child: (imageUrl == null || imageUrl!.trim().isEmpty)
          ? placeholder ??
              Icon(
                Icons.person_outline,
                color: Colors.grey[400],
                size: radius * 0.8,
              )
          : null,
    );
  }
} 