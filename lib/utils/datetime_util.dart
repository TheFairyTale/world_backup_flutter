import 'package:intl/intl.dart';

class DateTimeUtil {
  static DateTime parseDateString({String inputDateTime = ''}) {
    if (inputDateTime.isEmpty) {
      return DateTime.now();
    } else {
      try {
        return DateFormat('yyyy-MM-dd HH:mm:ss').parse(inputDateTime);
      } catch (e) {
        print('Error parsing date string: $e');
        return DateTime.now();
      }
    }
  }
}