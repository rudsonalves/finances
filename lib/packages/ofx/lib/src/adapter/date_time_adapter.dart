/// A sealed class providing methods to work with date and time conversions.
///
/// This class includes static methods for converting date and time strings to
/// `DateTime` objects, taking into account various formats and timezones.
/// It is designed to facilitate the handling of date and time data in formats
/// commonly encountered in financial data, network protocols, and other sources
/// that use string representations of datetime values.
///
/// Methods:
/// - `stringToDateTime`: Converts a date and time string in a specific format
///    to a UTC `DateTime` object.
/// - `stringDateTimeInTimeZoneLocal`: Adjusts a date and time string from a
///    specified timezone to the local timezone.
/// - `_getTimeZone`: Extracts the timezone offset from a date and time string.
///
/// The class is sealed to indicate that it should not be instantiated or
/// extended; it serves purely as a container for the static methods.
sealed class DateTimeAdapter {
  /// Converts a string representation of a date and time to a `DateTime`
  /// object.
  ///
  /// This static method parses a string formatted according to a specific
  /// pattern, usually encountered in financial data or network protocols, into
  /// a `DateTime` object. The expected format of the input string is
  /// "YYYYMMDDHHMMSS", optionally followed by a timezone offset (not processed
  /// by this method).
  ///
  /// Parameters:
  ///   - dateString: A string representing the date and time, formatted as
  ///     "YYYYMMDDHHMMSS[timezone]". The timezone part is ignored by this
  ///     method.
  ///
  /// Returns a `DateTime` object representing the date and time specified in
  /// the input string, adjusted to UTC.
  ///
  /// Example:
  /// ```dart
  /// String input = "20231109163440";
  /// DateTime dateTime = DateTimeAdapter.stringToDateTime(input);
  /// print(dateTime); // Output: 2023-11-09 16:34:40.000Z
  /// ```
  ///
  /// Note:
  /// - The method assumes the input date string is in UTC.
  /// - Timezone information present in the input string is ignored because the
  ///   method constructs a `DateTime` object in UTC directly.
  static DateTime stringToDateTime(String dateString) {
    /*20231109163440[-3:GMT]*/
    var year = int.parse(dateString.substring(00, 04));
    var month = int.parse(dateString.substring(04, 06));
    var day = int.parse(dateString.substring(06, 08));

    var hour = int.parse(dateString.substring(08, 10));
    var minute = int.parse(dateString.substring(10, 12));
    var second = int.parse(dateString.substring(12, 14));

    return DateTime.utc(year, month, day, hour, minute, second);
  }

  /// Converts a string representation of a date and time to a `DateTime` object
  /// adjusted for the local timezone.
  ///
  /// This static method parses a string formatted as "YYYYMMDDHHMMSS[timezone]"
  /// into a `DateTime` object, taking into account the timezone difference
  /// specified in the string and adjusting the result to the local timezone of
  /// the device.
  ///
  /// Parameters:
  ///   - dateString: A string representing the date and time, formatted as
  ///     "YYYYMMDDHHMMSS[timezone]". The timezone is expected to be a part of
  ///     the string in the format "[-/+H:GMT]" immediately following the date
  ///     and time.
  ///
  /// Returns a `DateTime` object representing the local date and time
  /// equivalent of the specified input string.
  ///
  /// Example:
  /// ```dart
  /// String input = "20231109163440[-3:GMT]";
  /// DateTime dateTimeLocal = DateTimeAdapter.stringDateTimeInTimeZoneLocal(input);
  /// print(dateTimeLocal); // Output depends on the local timezone of the device
  /// ```
  ///
  /// Note:
  /// - The method first converts the input string to a UTC `DateTime` object
  ///   using `stringToDateTime`.
  /// - It then calculates the timezone difference between the timezone
  ///   specified in the input string and the local timezone of the device.
  /// - The final `DateTime` object returned is adjusted accordingly to
  ///   represent the equivalent local date and time.
  static DateTime stringDateTimeInTimeZoneLocal(String dateString) {
    /*20231109163440[-3:GMT]*/
    var date = stringToDateTime(dateString);
    var timeZone = _getTimeZone(dateString);
    var timeZoneLocal = DateTime.now().timeZoneOffset.inHours;

    Duration diferenceTimeZone = Duration(hours: timeZone);

    DateTime zero;
    DateTime dateTimeLocal;

    if (timeZone < 0) {
      zero = date.add(diferenceTimeZone.abs());
    } else {
      zero = date.subtract(diferenceTimeZone.abs());
    }

    if (timeZoneLocal < 0) {
      dateTimeLocal = zero.add(Duration(hours: timeZoneLocal));
    } else {
      dateTimeLocal = zero.subtract(Duration(hours: timeZoneLocal));
    }

    return dateTimeLocal;
  }

  /// Extracts the timezone offset from a date string formatted with timezone
  /// information.
  ///
  /// This private static method parses a timezone offset specified in the
  /// format "[-H:GMT]" within a date string. It's designed to support the
  /// extraction of timezone information from strings used in conjunction with
  /// other `DateTimeAdapter` methods.
  ///
  /// Parameters:
  ///   - dateTime: A string containing the date, time, and optional timezone
  ///     information, formatted as "YYYYMMDDHHMMSS[-H:GMT]".
  ///
  /// Returns an integer representing the timezone offset in hours. If the
  /// timezone is specified as "-H", a negative integer is returned. If the
  /// timezone information is absent or cannot be parsed, the method defaults to
  /// returning 0, implying UTC.
  ///
  /// Example:
  /// ```dart
  /// String dateTimeWithTimezone = "20231109163440[-3:GMT]";
  /// int timezoneOffset = DateTimeAdapter._getTimeZone(dateTimeWithTimezone);
  /// print(timezoneOffset); // Output: -3
  /// ```
  ///
  /// Note:
  /// - This method is intended for internal use by `DateTimeAdapter` to process
  ///   timezone information embedded within date strings.
  /// - The method utilizes regular expressions to accurately identify and
  ///   extract the timezone offset from the provided string.
  static int _getTimeZone(String dateTime) {
    RegExp regex = RegExp(r'\[(-?\d+):GMT\]');
    RegExpMatch? match;
    int timeZone = 0;

    if (regex.hasMatch(dateTime.trim())) {
      match = regex.firstMatch(dateTime);

      if (match != null) {
        timeZone = int.parse(match.group(1) ?? '0');
      }
    }

    return timeZone;
  }
}
