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

  ExtendedDate.utc(
    super.year, [
    super.month,
    super.day,
    super.hour,
    super.minute,
    super.second,
    super.millisecond,
    super.microsecond,
  ]) : super.utc();

  factory ExtendedDate.nowDate() {
    DateTime now = DateTime.now();
    return ExtendedDate(
      now.year,
      now.month,
      now.day,
    );
  }

  factory ExtendedDate.fromDateTime(DateTime date) {
    return _copyDateTime(date);
  }

  String formatYMD(dynamic locale) {
    return DateFormat.yMMMd(locale).format(this);
  }

  ExtendedDate get onlyDate => ExtendedDate(
        super.year,
        super.month,
        super.day,
      );

  static ExtendedDate _copyDateTime(DateTime date) {
    if (date.isUtc) {
      return ExtendedDate.utc(
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

  static (int, int) getMillisecondsIntervalOfMonth(ExtendedDate date) {
    ExtendedDate firstDayOfMonth = ExtendedDate(date.year, date.month, 1);

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

    return lasDayOfMoth.subtract(const Duration(milliseconds: 1));
  }

  ExtendedDate nextDay() {
    return add(const Duration(days: 1));
  }

  ExtendedDate previusDay() {
    return add(const Duration(days: -1));
  }

  ExtendedDate nextWeek() {
    return add(const Duration(days: 7));
  }

  ExtendedDate nextYear() {
    final int newYear = year + 1;
    final int newDay = _adjustDay(day, month, newYear);

    return ExtendedDate(
      newYear,
      month,
      newDay,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  ExtendedDate nextMonth() {
    int newDay = day;
    int newMonth = month + 1;
    int newYear = year;

    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    }

    newDay = _adjustDay(newDay, newMonth, newYear);

    return ExtendedDate(
      newYear,
      newMonth,
      newDay,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  ExtendedDate previousMonth() {
    int newDay = day;
    int newMonth = month - 1;
    int newYear = year;

    if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }

    newDay = _adjustDay(newDay, newMonth, newYear);

    return ExtendedDate(
      newYear,
      newMonth,
      newDay,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  int _adjustDay(int day, int month, int year) {
    if (month == 2 && day > 28) {
      day = _isLeapYear(year) ? 29 : 28;
    } else if ([4, 6, 9, 11].contains(month) && day > 30) {
      day = 30;
    }

    return day;
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
  int get hashCode => millisecondsSinceEpoch.hashCode;
}
