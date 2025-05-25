import 'package:intl/intl.dart';

String formatSimpleDate(String rawDateTime) {
  final parsed = DateTime.parse(rawDateTime).toLocal();
  return DateFormat('dd MM yyyy • HH:mm').format(parsed); // örnek: 25 05 2025 • 17:20
}
