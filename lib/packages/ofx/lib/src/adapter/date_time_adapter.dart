sealed class DateTimeAdapter {
  static DateTime stringToDateTime(String dateString) {
    var year = int.parse(dateString.substring(00, 04));
    var month = int.parse(dateString.substring(04, 06));
    var day = int.parse(dateString.substring(06, 08));

    var hour = int.parse(dateString.substring(08, 10));
    var minute = int.parse(dateString.substring(10, 12));
    var second = int.parse(dateString.substring(12, 14));

    final date = DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second,
    );

    if (date.year != year ||
        date.month != month ||
        date.day != day ||
        date.hour != hour ||
        date.minute != minute ||
        date.second != second) {
      throw FormatException(
        'Data OFX inválida: $dateString.',
      );
    }

    return date;
  }

  static DateTime stringDateTimeInTimeZoneLocal(String dateString) {
    final date = stringToDateTime(dateString);
    final timeZone = _getTimeZone(dateString);

    final utcInstant = date.subtract(
      Duration(hours: timeZone),
    );

    return utcInstant.toLocal();
  }

  static int _getTimeZone(String dateTime) {
    final match = RegExp(
      r'\[([+-]?\d+):[^\]]+\]',
    ).firstMatch(dateTime.trim());

    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }
}
