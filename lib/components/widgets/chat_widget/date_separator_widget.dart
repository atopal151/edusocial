import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../services/language_service.dart';

class DateSeparatorWidget extends StatelessWidget {
  final DateTime date;

  const DateSeparatorWidget({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFffffff),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDateForSeparator(date, languageService),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(255, 162, 162, 165),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateForSeparator(DateTime date, LanguageService languageService) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return languageService.tr("chat.dateSeparator.today");
    } else if (messageDate == yesterday) {
      return languageService.tr("chat.dateSeparator.yesterday");
    } else {
      // Türkçe için DD.MM.YYYY, İngilizce için MM/DD/YYYY formatı
      final locale = languageService.currentLanguage.value;
      if (locale == 'tr') {
        return DateFormat('dd.MM.yyyy').format(date);
      } else {
        return DateFormat('dd.MM.yyyy').format(date);
      }
    }
  }
} 