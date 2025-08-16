
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';



String formatSimpleDateClock(String dateString) {
  try {
    // Mikrosaniyeleri at (örnek: 2025-05-13T21:25:22.000000Z => 2025-05-13T21:25:22)
    if (dateString.contains('.')) {
      dateString = dateString.split('.').first;
    }
    return DateFormat('dd MM yyyy • HH:mm').format(DateTime.parse(dateString));
  } catch (e) {
    //debugPrint("Tarih parse hatası: $e");
    return '';
  }
}


String formatSimpleDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';
  try {
    DateTime parsedDate = DateTime.parse(dateStr);
    return DateFormat('dd.MM.yyyy').format(parsedDate);
  } catch (e) {
    return ''; // veya "Geçersiz Tarih"
  }
}

// Event card için başlangıç ve bitiş tarihi formatı
String formatEventDate(String startDateString, String endDateString) {
  try {
    debugPrint("🔍 formatEventDate start: $startDateString, end: $endDateString");
    
    // Mikrosaniyeleri at
    String cleanStartDate = startDateString;
    String cleanEndDate = endDateString;
    
    if (startDateString.contains('.')) {
      cleanStartDate = startDateString.split('.').first + 'Z';
    }
    if (endDateString.contains('.')) {
      cleanEndDate = endDateString.split('.').first + 'Z';
    }
    
    DateTime startDate = DateTime.parse(cleanStartDate);
    DateTime endDate = DateTime.parse(cleanEndDate);
    
    // Aynı gün ise sadece tarih ve saat aralığı
    if (startDate.year == endDate.year && 
        startDate.month == endDate.month && 
        startDate.day == endDate.day) {
      final datePart = DateFormat('dd MMM yyyy', 'en_US').format(startDate);
      final startTime = DateFormat('HH:mm', 'en_US').format(startDate);
      final endTime = DateFormat('HH:mm', 'en_US').format(endDate);
      final result = '$datePart • $startTime - $endTime';
      debugPrint("🔍 formatEventDate same day result: $result");
      return result;
    } else {
      // Farklı günler ise tarih aralığı
      final startFormatted = DateFormat('dd MMM', 'en_US').format(startDate);
      final endFormatted = DateFormat('dd MMM yyyy', 'en_US').format(endDate);
      final result = '$startFormatted - $endFormatted';
      debugPrint("🔍 formatEventDate range result: $result");
      return result;
    }
  } catch (e) {
    debugPrint("❌ formatEventDate error: $e");
    try {
      // Fallback: sadece başlangıç tarihi
      DateTime startDate = DateTime.parse(startDateString.split('T').first);
      final fallbackResult = DateFormat('dd MMM yyyy', 'en_US').format(startDate);
      debugPrint("🔍 formatEventDate fallback result: $fallbackResult");
      return fallbackResult;
    } catch (e2) {
      debugPrint("❌ formatEventDate fallback error: $e2");
      return '';
    }
  }
}
