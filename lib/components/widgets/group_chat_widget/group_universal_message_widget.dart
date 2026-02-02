import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/chat_models/group_message_model.dart';
import '../../../services/language_service.dart';
import '../../../controllers/chat_controllers/group_chat_detail_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../dialogs/image_preview_dialog.dart';
import '../verification_badge.dart';

class GroupUniversalMessageWidget extends StatelessWidget {
  final GroupMessageModel message;
  final GroupChatDetailController controller;

  const GroupUniversalMessageWidget({
    super.key, 
    required this.message,
    required this.controller,
  });

  // URL'leri tespit et
  List<String> extractUrls(String text) {
    final urlRegex = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );
    return urlRegex.allMatches(text).map((match) => match.group(0)!).toList();
  }

  // Pin/Unpin mesaj işlemi
  void _handlePinMessage() async {
    try {
      
      final messageId = int.tryParse(message.id);
      if (messageId == null) {
        debugPrint('❌ [GroupUniversalMessageWidget] Invalid message ID: ${message.id}');
        return;
      }
      
      // Controller üzerinden pin message metodunu çağır
      await controller.pinMessage(messageId);
      
    } catch (e) {
      debugPrint('❌ [GroupUniversalMessageWidget] Pin/Unpin işlemi hatası: $e');
      
      // Hata bildirimi göster
      Get.snackbar(
        '❌ Error',
        'An error occurred during pin/unpin operation',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.find<LanguageService>();
    
    
    // Mesaj içeriğini analiz et
    final hasText = message.content.isNotEmpty && !_isImageUrl(message.content);
    final hasImage = _isImageUrl(message.content) || (message.media?.isNotEmpty ?? false);
    final hasLinks = message.links?.isNotEmpty ?? false;
    
    
    
    // Text içindeki URL'leri çıkar (eğer ayrı links alanı varsa)
    String displayText = message.content;
    List<String> allLinks = [];
    
    if (hasLinks) {
      allLinks = message.links!;
    } else if (hasText) {
      allLinks = extractUrls(message.content);
      // URL'leri text'ten çıkar
      for (String link in allLinks) {
        displayText = displayText.replaceAll(link, '');
      }
      displayText = displayText.trim();
    }
    
    
    return Column(
      crossAxisAlignment: message.isSentByMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // 🔹 Kullanıcı Bilgileri ve Pin İkonu
        Row(
          mainAxisAlignment: message.isSentByMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!message.isSentByMe)
              InkWell(
                onTap: () {
                  final ProfileController profileController = Get.find<ProfileController>();
                  profileController.getToPeopleProfileScreen(message.username);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 6.0),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: (message.profileImage.isNotEmpty &&
                            !message.profileImage.endsWith('/0'))
                        ? NetworkImage(message.profileImage)
                        : null,
                    child: (message.profileImage.isEmpty ||
                            message.profileImage.endsWith('/0'))
                        ? const Icon(Icons.person, color: Colors.white, size: 14)
                        : null,
                  ),
                ),
              ),
            
            InkWell(
              onTap: () {
                final ProfileController profileController = Get.find<ProfileController>();
                profileController.getToPeopleProfileScreen(message.username);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '@${message.username}',
                    style: const TextStyle(fontSize: 10, color: Color(0xff414751)),
                  ),
                  const SizedBox(width: 4),
                  VerificationBadge(
                    isVerified: message.isVerified,
                    size: 12,
                  ),
                ],
              ),
            ),
            
            // Pin iconu - mesaj pinlendiğinde göster (admin olmayan kullanıcılar için)
            if (message.isPinned && !controller.isCurrentUserAdmin)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  Icons.push_pin,
                  size: 14,
                  color: Color(0xFFff7c7c),
                ),
              ),
            
            if (message.isSentByMe)
              InkWell(
                onTap: () {
                  final ProfileController profileController = Get.find<ProfileController>();
                  profileController.getToPeopleProfileScreen(message.username);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 6.0, right: 8.0),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: (message.profileImage.isNotEmpty &&
                            !message.profileImage.endsWith('/0'))
                        ? NetworkImage(message.profileImage)
                        : null,
                    child: (message.profileImage.isEmpty ||
                            message.profileImage.endsWith('/0'))
                        ? const Icon(Icons.person, color: Colors.white, size: 14)
                        : null,
                  ),
                ),
              ),
          ],
        ),
        // 🔹 Mesaj Balonu (Private Chat Tasarımı)
        Padding(
          padding: EdgeInsets.only(
            left: message.isSentByMe ? 48.0 : 30.0,
            right: message.isSentByMe ? 30.0 : 48.0,
            top: 2.0,
            bottom: 4.0,
          ),
          child: Align(
            alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Builder(
              builder: (builderContext) => GestureDetector(
                onLongPress: () => _showMessageMenu(builderContext),
                child: Stack(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isSentByMe 
                        ? const Color(0xFFff7c7c) // Kırmızı
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(18),
                      bottomRight: const Radius.circular(18),
                      topLeft: message.isSentByMe 
                          ? const Radius.circular(18) 
                          : const Radius.circular(4),
                      topRight: message.isSentByMe 
                          ? const Radius.circular(4) 
                          : const Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Yanıtlanan mesaj önizlemesi (reply)
                      if (message.replyId != null || (message.replyMessageText?.isNotEmpty ?? false) || message.replyHasImageMedia || message.replyHasLinkMedia) ...[
                        Builder(
                          builder: (ctx) {
                            final lang = Get.find<LanguageService>();
                            final replyPreview = message.replyHasImageMedia
                                ? '📸 ${lang.tr("chat.replyPhoto")}'
                                : message.replyHasLinkMedia
                                    ? '🔗 ${lang.tr("chat.replyLink")}'
                                    : () {
                                        final replyText = message.replyMessageText?.trim() ?? '';
                                        return replyText.isEmpty
                                            ? (message.replyId != null ? '📷 Media' : '-')
                                            : (replyText.length > 50 ? '${replyText.substring(0, 50)}...' : replyText);
                                      }();
                            final senderName = message.replyMessageSenderName;
                            final replyId = message.replyId;
                            return GestureDetector(
                              onTap: replyId != null && replyId.isNotEmpty
                                  ? () => controller.navigateToMessage(replyId)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: message.isSentByMe ? Colors.white.withAlpha(40) : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border(left: BorderSide(color: const Color(0xffef5050), width: 3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      senderName != null ? '$senderName · ${lang.tr("comments.reply.replyTo")}' : lang.tr("comments.reply.replyTo"),
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: message.isSentByMe ? Colors.white.withAlpha(200) : Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      replyPreview,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: message.isSentByMe ? Colors.white.withAlpha(230) : const Color(0xff374151),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                      // Text içeriği (varsa)
                      if (hasText && displayText.isNotEmpty) ...[
                        Text(
                          displayText,
                          style: GoogleFonts.inter(
                            color: message.isSentByMe ? Colors.white : const Color(0xff000000),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      
                      // Image içeriği (varsa)
                      if (hasImage) ...[
                        _buildImageContent(),
                        const SizedBox(height: 8),
                      ],
                      
                      // Link içeriği (varsa)
                      if (allLinks.isNotEmpty) ...[
                        _buildLinkContent(allLinks),
                      ],
                      
                      const SizedBox(height: 4),
                      // Saat bilgisi mesaj balonunun içinde sağ altta
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(message.timestamp),
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              color: message.isSentByMe 
                                  ? Colors.white.withAlpha(80)
                                  : const Color(0xff8E8E93),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    // Önce media alanından image al, yoksa content'ten al
    final imageUrl = message.media?.isNotEmpty == true 
        ? message.media!.first 
        : message.content;
    final heroTag = 'group_universal_image_${message.id}';
    
    return GestureDetector(
      onTap: () => _openImagePreview(imageUrl, heroTag),
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                width: 200,
                height: 150,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 200,
                    height: 150,
                    color: Colors.grey[100],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        color: const Color(0xFFff7c7c),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('GroupUniversalMessageWidget image error: $error');
                  return Container(
                    width: 200,
                    height: 150,
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.grey),
                        const SizedBox(height: 4),
                        Text(
                          'Resim yüklenemedi',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Overlay hint for tap to view
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkContent(List<String> links) {
    if (links.isEmpty) return const SizedBox.shrink();
    
    final linkUrl = links.first;
    final domainName = _extractDomainName(linkUrl);
    
    return GestureDetector(
      onTap: () => _showLinkPreview(linkUrl),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isSentByMe 
              ? Colors.white.withAlpha(30)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: message.isSentByMe 
                ? Colors.white.withAlpha(40)
                : Colors.grey.withAlpha(100),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Domain name - büyük ve beyaz
            Text(
              domainName,
              style: GoogleFonts.inter(
                fontSize: 13.78,
                fontWeight: FontWeight.w600,
                color: message.isSentByMe ? Colors.white : const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 4),
            // Full URL - mavi ve altı çizili
            Text(
              linkUrl,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF007AFF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openImagePreview(String imageUrl, String heroTag) {
    showImagePreview(
      imageUrl: imageUrl,
      heroTag: heroTag,
      userName: '${message.name} ${message.surname}',
      timestamp: message.timestamp,
    );
  }

  void _showLinkPreview(String url) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              Text(
                'Link Önizleme',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              
              // Link bilgileri
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withAlpha(100),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _extractDomainName(url),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      url,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF007AFF),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Butonlar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // İptal butonu
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'İptal',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Aç butonu
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _launchUrl(url);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Aç',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractDomainName(String url) {
    try {
      final uri = Uri.parse(url);
      String domain = uri.host;
      
      // www. prefix'ini kaldır
      if (domain.startsWith('www.')) {
        domain = domain.substring(4);
      }
      
      return domain;
    } catch (e) {
      // URL parse edilemezse, basit bir domain extraction dene
      if (url.contains('://')) {
        final parts = url.split('://');
        if (parts.length > 1) {
          String domain = parts[1].split('/')[0];
          if (domain.startsWith('www.')) {
            domain = domain.substring(4);
          }
          return domain;
        }
      }
      return 'link';
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // URL açılamazsa kullanıcıya bilgi ver
        Get.snackbar(
          'Hata',
          'Link açılamadı',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withAlpha(200),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Geçersiz link',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(200),
        colorText: Colors.white,
      );
    }
  }

  bool _isImageUrl(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final lowerUrl = url.toLowerCase();
    return imageExtensions.any((ext) => lowerUrl.endsWith(ext)) || 
           lowerUrl.startsWith('http') && lowerUrl.contains('image');
  }

  String _formatTime(DateTime dateTime) {
    try {
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  void _showMessageMenu(BuildContext context) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    
    if (renderBox == null) return;
    
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;
    
    final menuWidth = 200.0;
    final menuHeight = controller.isCurrentUserAdmin ? 112.0 : 56.0; // Pin + Reply veya sadece Reply
    
    final left = position.dx + size.width / 2 - menuWidth / 2;
    final top = position.dy + size.height + 8;
    
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: 'Message menu',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (BuildContext dialogContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return Stack(
          children: [
            // Tıklanabilir arka plan - menüyü kapatmak için
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(dialogContext),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Menü widget'ı
            Positioned(
              left: left.clamp(8.0, screenSize.width - menuWidth - 8),
              top: top.clamp(8.0, screenSize.height - menuHeight - 8),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: menuWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: Colors.black.withAlpha(2),
                        blurRadius: 4,
                        spreadRadius: 0.5,
                        offset: const Offset(0, -1),
                      ),
                      BoxShadow(
                        color: Colors.black.withAlpha(2),
                        blurRadius: 4,
                        spreadRadius: 0.5,
                        offset: const Offset(2, 0),
                      ),
                      BoxShadow(
                        color: Colors.black.withAlpha(2),
                        blurRadius: 4,
                        spreadRadius: 0.5,
                        offset: const Offset(-2, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.isCurrentUserAdmin)
                        InkWell(
                          onTap: () {
                            Navigator.pop(dialogContext);
                            _handlePinMessage();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                  message.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                                  size: 20,
                                  color: message.isPinned
                                      ? const Color(0xff414751)
                                      : const Color(0xff9ca3ae),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  message.isPinned ? 'Remove Pin' : 'Pin Message',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff000000),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(dialogContext);
                          controller.setReplyingTo(message);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.reply,
                                size: 20,
                                color: const Color(0xff9ca3ae),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                Get.find<LanguageService>().tr("comments.reply.replyButton"),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff000000),
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
            ),
          ],
        );
      },
    );
  }
}
