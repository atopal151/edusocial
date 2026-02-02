import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/chat_models/chat_detail_model.dart';
import '../../../controllers/chat_controllers/chat_detail_controller.dart';
import '../../../services/language_service.dart';
import '../../dialogs/image_preview_dialog.dart';

class UniversalMessageWidget extends StatelessWidget {
  final MessageModel message;
  final ChatDetailController controller;

  const UniversalMessageWidget({
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

  @override
  Widget build(BuildContext context) {
    // Debug bilgisi
    
    // Mesaj içeriğini analiz et
    final hasText = message.message.isNotEmpty;
    final hasMedia = message.messageMedia.isNotEmpty;
    final hasLinks = message.messageLink.isNotEmpty;
    final hasDocuments = message.messageDocument?.isNotEmpty ?? false;
    
    // Media içinde document vs image ayrımı
    bool hasDocumentInMedia = false;
    bool hasImageInMedia = false;
    
    if (hasMedia) {
      for (var media in message.messageMedia) {
        if (media.isDocument) {
          hasDocumentInMedia = true;
        } else if (media.isImage) {
          hasImageInMedia = true;
        }
      }
    }
    
    // Text içindeki URL'leri çıkar (eğer ayrı messageLink alanı varsa)
    String displayText = message.message;
    List<String> allLinks = [];
    
    if (hasLinks) {
      allLinks = message.messageLink.map((link) => link.link).toList();
    } else if (hasText) {
      allLinks = extractUrls(message.message);
      // URL'leri text'ten çıkar
      for (String link in allLinks) {
        displayText = displayText.replaceAll(link, '');
      }
      displayText = displayText.trim();
    }
    
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Builder(
              builder: (builderContext) => GestureDetector(
                onLongPress: () {
                  _showMessageMenu(builderContext);
                },
                child: Stack(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: message.isMe 
                          ? const Color(0xFFff7c7c) // Kırmızı
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: message.isMe 
                            ? const Radius.circular(18) 
                            : const Radius.circular(4),
                        bottomRight: message.isMe 
                            ? const Radius.circular(4) 
                            : const Radius.circular(18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Yanıtlanan mesaj önizlemesi (reply) — tüm tipler; tıklanınca o mesaja gider
                        if (message.replyId != null || (message.replyMessageText?.isNotEmpty ?? false) || message.replyHasImageMedia || message.replyHasLinkMedia) ...[
                          Builder(
                            builder: (ctx) {
                              final lang = Get.find<LanguageService>();
                              // Görsel / link içeren mesaja yanıt: "Fotoğraf" veya "Link" göster
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
                                onTap: replyId != null
                                    ? () => controller.navigateToMessage(replyId)
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: message.isMe ? Colors.white.withAlpha(40) : Colors.grey.shade200,
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
                                          color: message.isMe ? Colors.white.withAlpha(200) : Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        replyPreview,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: message.isMe ? Colors.white.withAlpha(230) : const Color(0xff374151),
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
                              color: message.isMe ? Colors.white : const Color(0xff000000),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        // Document içeriği (varsa) - önce document göster
                        if (hasDocuments || hasDocumentInMedia) ...[
                          _buildDocumentContent(),
                          const SizedBox(height: 8),
                        ],
                        
                        // Image içeriği (varsa) - document yoksa image göster
                        if (hasImageInMedia && !hasDocumentInMedia) ...[
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
                              _formatTime(message.createdAt),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: message.isMe 
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
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentContent() {
    // Önce messageDocument alanından al, yoksa messageMedia'dan al
    if (message.messageDocument?.isNotEmpty == true) {
      final document = message.messageDocument!.first;
      return _buildDocumentItem(document.name, document.url, '');
    } else if (message.messageMedia.isNotEmpty) {
      // Media'dan document bul
      for (var media in message.messageMedia) {
        if (media.isDocument) {
          return _buildDocumentItem('Document', media.fullPath, media.fileSize);
        }
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildDocumentItem(String title, String path, String fileSize) {
    return GestureDetector(
      onTap: () {
        // Burada document açma işlemi yapılabilir
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isMe 
              ? Colors.white.withAlpha(30)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: message.isMe 
                ? Colors.white.withAlpha(40)
                : Colors.grey.withAlpha(100),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file, 
              color: message.isMe ? Colors.white : const Color(0xff000000),
              size: 24,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isNotEmpty ? title : 'Document',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: message.isMe ? Colors.white : const Color(0xff000000),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    fileSize.isNotEmpty ? fileSize : 'Click to download',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: message.isMe 
                          ? Colors.white.withAlpha(80)
                          : const Color(0xff8E8E93),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    // İlk image'ı al
    final imageMedia = message.messageMedia.firstWhere(
      (media) => media.isImage,
      orElse: () => message.messageMedia.first,
    );
    
    final imageUrl = imageMedia.fullPath;
    final heroTag = 'universal_image_${message.id}';
    
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
          color: message.isMe 
              ? Colors.white.withAlpha(30)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: message.isMe 
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
                color: message.isMe ? Colors.white : const Color(0xFF333333),
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
      userName: '${message.sender.name} ${message.sender.surname}',
      timestamp: DateTime.parse(message.createdAt),
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

  String _formatTime(String dateTimeString) {
    try {
      return DateFormat('HH:mm').format(DateTime.parse(dateTimeString));
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
    final menuHeight = 112.0; // 2 items: Reply, Pin
    final languageService = Get.find<LanguageService>();

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
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(dialogContext),
                child: Container(color: Colors.transparent),
              ),
            ),
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
                      // Yanıtla (Reply)
                      InkWell(
                        onTap: () {
                          Navigator.pop(dialogContext);
                          controller.setReplyingTo(message);
                        },
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                                languageService.tr("comments.reply.replyButton"),
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
                      Divider(height: 1, color: Colors.grey.shade200),
                      // Pin
                      InkWell(
                        onTap: () {
                          Navigator.pop(dialogContext);
                          controller.pinMessage(message.id);
                        },
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
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
                                message.isPinned ? 'Remove Pin' : 'Pin the message',
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
