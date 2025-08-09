
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

// Event card için daha temiz tarih formatı
String formatEventDate(String dateString) {
  try {
    // Mikrosaniyeleri at (örnek: 2025-05-13T21:25:22.000000Z => 2025-05-13T21:25:22Z)
    if (dateString.contains('.')) {
      dateString = dateString.split('.').first + 'Z';
    }
    
    DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy • HH:mm', 'tr_TR').format(parsedDate);
  } catch (e) {
    try {
      // Fallback: sadece tarih kısmını al
      DateTime parsedDate = DateTime.parse(dateString.split('T').first);
      return DateFormat('dd MMM yyyy', 'tr_TR').format(parsedDate);
    } catch (e2) {
      return '';
    }
  }
}
