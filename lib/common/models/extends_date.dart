import 'package:intl/intl.dart';

class ExtendedDate extends DateTime {
  ExtendedDate(
    super.year, [
    super.month = 1,
    super.day = 1,
    super.hour = 0,
    super.minute = 0,
    super.second = 0,
    super.millisecond = 0,
    super.microsecond = 0,
  ]);

  /// Return the a ExtendedDate of current date only (hours = 0, minutes = 0,
  /// and seconds = 0).
  factory ExtendedDate.nowDate() {
    DateTime now = DateTime.now();
    return ExtendedDate(
      now.year,
      now.month,
      now.day,
    );
  }

  static ExtendedDate _copyDateTime(DateTime date) {
    return ExtendedDate(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  static ExtendedDate parse(String formattedString) {
    var date = DateTime.parse(formattedString);
    return _copyDateTime(date);
  }

  factory ExtendedDate.now() {
    DateTime now = DateTime.now();
    return _copyDateTime(now);
  }

  factory ExtendedDate.fromMillisecondsSinceEpoch(int millisecondsSinceEpoch) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    return _copyDateTime(date);
  }

  // factory ExtendsDate.fromMicrosecondsSinceEpoch(int microsecondsSinceEpoch) {
  //   DateTime date = DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);
  //   return _copyDateTime(date);
  // }

  static (int, int) getMillisecondsIntervalOfMonth(ExtendedDate date) {
    // get the first day ot the month
    ExtendedDate firstDayOfMonth =
        ExtendedDate(date.year, date.month, 1, 0, 0, 1);
    // get the last day of the month
    ExtendedDate lastDayOfMonth = ExtendedDate(
        date.year, date.month, _lastDayOfMonth(date), 23, 59, 59, 999);

    int firstMillisecondOfMonth = firstDayOfMonth.millisecondsSinceEpoch;
    int lastMillisecondOfMonth = lastDayOfMonth.millisecondsSinceEpoch;

    return (firstMillisecondOfMonth, lastMillisecondOfMonth);
  }

  static bool _isLeapYear(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  static int _lastDayOfMonth(ExtendedDate date) {
    if (date.month == 2) {
      return (_isLeapYear(date.year)) ? 29 : 28;
    }
    return ([4, 6, 9, 11].contains(date.month)) ? 30 : 31;
  }

  ExtendedDate get lastDayOfTheMonth {
    ExtendedDate lasDayOfMoth = month < 12
        ? ExtendedDate(year, month + 1, 1)
        : ExtendedDate(year + 1, 1, 1);

    return lasDayOfMoth.subtract(const Duration(seconds: 1));
  }

  ExtendedDate get onlyDate => ExtendedDate(
        super.year,
        super.month,
        super.day,
      );

  /// Return the next day ExtendedDate
  ExtendedDate nextDay() {
    return add(const Duration(days: 1));
  }

  /// Return the previus day ExtendedDate
  ExtendedDate previusDay() {
    return add(const Duration(days: -1));
  }

  /// Return the next week ExtendedDate
  ExtendedDate nextWeek() {
    return add(const Duration(days: 7));
  }

  /// Return the next year ExtendedDate
  ExtendedDate nextYear() {
    return ExtendedDate(year + 1, month, day, hour, minute, second);
  }

  /// Return the next month ExtendedDate
  ExtendedDate nextMonth() {
    int addDays = 31;
    if ([4, 6, 9, 11].contains(month)) {
      addDays = 30;
    } else if (month == 2) {
      addDays = _isLeapYear(year) ? 29 : 28;
    }
    return add(Duration(days: addDays));
  }

  /// Return the previus month ExtendedDate
  ExtendedDate previousMonth() {
    int previousMonth = month == 1 ? 12 : month - 1;

    int addDays = 31;
    if ([4, 6, 9, 11].contains(previousMonth)) {
      addDays = 30;
    } else if (month == 2) {
      addDays = _isLeapYear(year) ? 29 : 28;
    }
    return subtract(Duration(days: addDays));
  }

  @override
  ExtendedDate add(Duration duration) {
    var date = super.add(duration);
    return _copyDateTime(date);
  }

  @override
  ExtendedDate subtract(Duration duration) {
    var date = super.subtract(duration);
    return _copyDateTime(date);
  }

  @override
  String toString() {
    return DateFormat.yMMMEd().add_Hm().format(this);
  }

  bool operator >(ExtendedDate other) =>
      millisecondsSinceEpoch > other.millisecondsSinceEpoch;

  bool operator >=(ExtendedDate other) =>
      millisecondsSinceEpoch >= other.millisecondsSinceEpoch;

  bool operator <(ExtendedDate other) =>
      millisecondsSinceEpoch < other.millisecondsSinceEpoch;

  bool operator <=(ExtendedDate other) =>
      millisecondsSinceEpoch <= other.millisecondsSinceEpoch;

  @override
  bool operator ==(other) {
    if (other is ExtendedDate) {
      return millisecondsSinceEpoch == other.millisecondsSinceEpoch;
    }
    return false;
  }

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}
