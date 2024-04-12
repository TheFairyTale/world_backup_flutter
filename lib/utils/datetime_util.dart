import 'dart:math';

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

  static String writeDateTimeStr(int format) {
    DateTime currentTime = DateTime.now();

    var year = currentTime.year; // 当前年
    var month = currentTime.month; // 当前月
    var day = currentTime.day; // 当前日
    var hour = currentTime.hour; // 当前时
    var minute = currentTime.minute; // 当前分
    var second = currentTime.second; // 当前秒

    switch (format) {
      case 1:
        return year.toString() +
            month.toString() +
            day.toString() +
            hour.toString() +
            minute.toString() +
            second.toString();
      default:
        return year.toString() +
            "-" +
            month.toString() +
            "-" +
            day.toString() +
            "_" +
            hour.toString() +
            "-" +
            minute.toString() +
            "-" +
            second.toString();
    }
  }
}
