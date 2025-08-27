import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/chat_models/group_message_model.dart';
import '../../../services/language_service.dart';
import '../../../services/pin_message_service.dart';
import '../../../controllers/chat_controllers/group_chat_detail_controller.dart';
import '../../dialogs/image_preview_dialog.dart';

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
      debugPrint('📌 [GroupUniversalMessageWidget] Pin/Unpin işlemi başlatıldı');
      debugPrint('📌 [GroupUniversalMessageWidget] Message ID: ${message.id}');
      debugPrint('📌 [GroupUniversalMessageWidget] Current Pin Status: ${message.isPinned}');
      
      final messageId = int.tryParse(message.id);
      if (messageId == null) {
        debugPrint('❌ [GroupUniversalMessageWidget] Invalid message ID: ${message.id}');
        return;
      }
      
      final groupId = controller.currentGroupId.value;
      if (groupId.isEmpty) {
        debugPrint('❌ [GroupUniversalMessageWidget] Group ID is empty');
        return;
      }
      
      // PinMessageService'i kullan
      final pinMessageService = Get.find<PinMessageService>();
      final success = await pinMessageService.pinGroupMessage(messageId, groupId);
      
      if (success) {
        debugPrint('✅ [GroupUniversalMessageWidget] Pin/Unpin işlemi başarılı');
      } else {
        debugPrint('❌ [GroupUniversalMessageWidget] Pin/Unpin işlemi başarısız');
        
        // Hata bildirimi göster
        Get.snackbar(
          '❌ Hata',
          'Pin/Unpin işlemi başarısız oldu',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      }
    } catch (e) {
      debugPrint('❌ [GroupUniversalMessageWidget] Pin/Unpin işlemi hatası: $e');
      
      // Hata bildirimi göster
      Get.snackbar(
        '❌ Hata',
        'Pin/Unpin işlemi sırasında hata oluştu: $e',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Get.find<LanguageService>();
    
    // Debug bilgisi
    //debugPrint('GroupUniversalMessageWidget - Content: ${message.content}');
    //debugPrint('GroupUniversalMessageWidget - MessageType: ${message.messageType}');
    //debugPrint('GroupUniversalMessageWidget - IsPinned: ${message.isPinned}');
    //debugPrint('GroupUniversalMessageWidget - Links: ${message.links}');
    
    // Mesaj içeriğini analiz et
    final hasText = message.content.isNotEmpty && !_isImageUrl(message.content);
    final hasImage = _isImageUrl(message.content) || (message.media?.isNotEmpty ?? false);
    final hasLinks = message.links?.isNotEmpty ?? false;
    
    // Debug bilgisi
    //debugPrint('🔍 GroupUniversalMessageWidget Analysis:');
    //debugPrint('🔍 Content: "${message.content}"');
    //debugPrint('🔍 MessageType: ${message.messageType}');
    //debugPrint('🔍 HasText: $hasText');
    //debugPrint('🔍 HasImage: $hasImage');
    //debugPrint('🔍 HasLinks: $hasLinks');
    //debugPrint('🔍 Links: ${message.links}');
    //debugPrint('🔍 Media: ${message.media}');
    
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
    
    // Debug: Final analysis
    debugPrint('🔍 Final Analysis:');
    debugPrint('🔍 DisplayText: "$displayText"');
    debugPrint('🔍 AllLinks: $allLinks');
    debugPrint('🔍 HasText: $hasText');
    debugPrint('🔍 HasImage: $hasImage');
    debugPrint('🔍 HasLinks: $hasLinks');
    
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
              Padding(
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
            
            Text(
              '@${message.username}',
              style: const TextStyle(fontSize: 10, color: Color(0xff414751)),
            ),
            
            // Pin iconu - sadece admin için göster (tüm mesajlar için)
            if (controller.isCurrentUserAdmin)
              GestureDetector(
                onTap: () => _handlePinMessage(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Icon(
                    message.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 14,
                    color: message.isPinned ? Colors.orange : Colors.grey[400],
                  ),
                ),
              ),
            
            if (message.isSentByMe)
              Padding(
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
            child: Container(
              child: Container(
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
                                ? Colors.white.withValues(alpha: 0.8)
                                : const Color(0xff8E8E93),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
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


}
