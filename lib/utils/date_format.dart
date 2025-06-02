
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


String formatSimpleDate(String rawDateTime) {
  final parsed = DateTime.parse(rawDateTime).toLocal();
  return DateFormat('dd.MM.yyyy').format(parsed); // örnek: 25 05 2025 • 17:20
}