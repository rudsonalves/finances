import 'package:intl/intl.dart';

/// ExtendedDate extends the functionality of Dart's DateTime class, providing
/// convenient methods for common date manipulations and calculations. It includes
/// features such as getting the start and end of a month in milliseconds, checking
/// for leap years, and easily moving to the next or previous day, month, or year.
///
/// Constructors:
///   - `ExtendedDate(year, [month, day, hour, minute, second, millisecond, microsecond])`:
///     Initializes a new ExtendedDate object with the specified date and time.
///   - `ExtendedDate.nowDate()`: Creates an ExtendedDate for the current date with time set to midnight.
///   - `ExtendedDate.now()`: Creates an ExtendedDate for the current date and time.
///   - `ExtendedDate.fromMillisecondsSinceEpoch(millisecondsSinceEpoch)`: Creates an ExtendedDate from milliseconds since the Unix epoch.
///   - `ExtendedDate.parse(formattedString)`: Parses a string and returns an ExtendedDate.
///
/// Methods:
///   - `onlyDate`: Returns a new ExtendedDate with time set to midnight.
///   - `getMillisecondsIntervalOfMonth(date)`: Calculates the start and end milliseconds of the month for the given date.
///   - `nextDay`, `previusDay`: Returns an ExtendedDate moved by one day forward or backward.
///   - `nextWeek`: Returns an ExtendedDate moved by a week forward.
///   - `nextYear`, `nextMonth`, `previousMonth`: Moves the ExtendedDate to the next or previous year or month.
///   - `add`, `subtract`: Overrides DateTime's add and subtract methods to return an ExtendedDate.
///
/// Operators:
///   - Overloads comparison operators (`>`, `>=`, `<`, `<=`) for comparing ExtendedDate objects.
///
/// Note:
///   This class is particularly useful for applications that require detailed date
///   manipulation beyond the capabilities of the standard DateTime class, such as
///   financial applications, scheduling, and calendar functionalities.
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

  /// Creates an ExtendedDate instance representing the current date with the time set to midnight.
  ///
  /// This factory constructor initializes an ExtendedDate object for today's date,
  /// explicitly setting the hour, minute, second, and fractional second fields to zero.
  /// It is particularly useful for scenarios where only the date part is relevant,
  /// ignoring the time component.
  ///
  /// Returns:
  ///   An ExtendedDate instance representing the current date at 00:00:00.000.
  ///
  /// Note:
  ///   This method is ideal for applications requiring date comparisons or calculations
  ///   that are time-agnostic, such as date-based filtering or reporting features.
  factory ExtendedDate.nowDate() {
    DateTime now = DateTime.now();
    return ExtendedDate(
      now.year,
      now.month,
      now.day,
    );
  }

  factory ExtendedDate.fromDateTime(DateTime date) {
    return ExtendedDate(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
    );
  }

  /// Retrieves an ExtendedDate instance representing only the date part of the current instance,
  /// with the time set to midnight.
  ///
  /// This getter returns a new ExtendedDate object derived from the current instance but
  /// with the hour, minute, second, and fractional second fields set to zero. It allows
  /// for operations and comparisons that focus solely on the date component, ignoring
  /// the time.
  ///
  /// Returns:
  ///   An ExtendedDate instance corresponding to the date of the current instance, at 00:00:00.000.
  ///
  /// Note:
  ///   Useful in contexts where time is irrelevant, ensuring consistent handling of dates
  ///   across various functionalities that require date-only values.
  ExtendedDate get onlyDate => ExtendedDate(
        super.year,
        super.month,
        super.day,
      );

  /// Creates an ExtendedDate instance that is a copy of the provided DateTime object.
  ///
  /// This static method constructs an ExtendedDate from a given DateTime, preserving
  /// the year, month, day, hour, minute, second, millisecond, and microsecond components.
  /// It is used internally to convert DateTime objects into ExtendedDate objects,
  /// maintaining the exact date and time values.
  ///
  /// Parameters:
  ///   - date: The DateTime object to be copied.
  ///
  /// Returns:
  ///   An ExtendedDate instance mirroring the specified DateTime's values.
  ///
  /// Note:
  ///   This method facilitates the interaction between standard DateTime objects and
  ///   ExtendedDate, allowing for seamless conversions that retain full datetime
  ///   precision.
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

  /// Parses a string into an ExtendedDate object.
  ///
  /// This static method converts a date string into an ExtendedDate instance,
  /// using DateTime.parse to interpret the string and then converting the result
  /// to an ExtendedDate, preserving all date and time components.
  ///
  /// Parameters:
  ///   - formattedString: A string representing a date and time.
  ///
  /// Returns:
  ///   An ExtendedDate instance corresponding to the date and time specified in
  ///   the string.
  ///
  /// Note:
  ///   The string format should comply with ISO 8601 to ensure correct parsing.
  static ExtendedDate parse(String formattedString) {
    var date = DateTime.parse(formattedString);
    return _copyDateTime(date);
  }

  /// Creates an ExtendedDate instance for the current date and time.
  ///
  /// This factory constructor generates an ExtendedDate representing the current
  /// moment, down to the microseconds, by utilizing DateTime.now and then converting
  /// the result to an ExtendedDate.
  ///
  /// Returns:
  ///   An ExtendedDate instance representing the current date and time.
  ///
  /// Note:
  ///   Useful for operations requiring the current date and time with the extended
  ///   capabilities of ExtendedDate.
  factory ExtendedDate.now() {
    DateTime now = DateTime.now();
    return _copyDateTime(now);
  }

  /// Creates an ExtendedDate instance from milliseconds since the Unix epoch.
  ///
  /// This factory constructor generates an ExtendedDate based on the number of
  /// milliseconds since the Unix epoch (00:00:00 UTC on 1 January 1970), converting
  /// a DateTime object to ExtendedDate to maintain precision.
  ///
  /// Parameters:
  ///   - millisecondsSinceEpoch: The number of milliseconds since the Unix epoch.
  ///
  /// Returns:
  ///   An ExtendedDate instance representing the specified point in time.
  ///
  /// Note:
  ///   Enables easy conversion from timestamps to ExtendedDate objects, facilitating
  ///   interactions with databases or APIs that use epoch timestamps.
  factory ExtendedDate.fromMillisecondsSinceEpoch(int millisecondsSinceEpoch) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    return _copyDateTime(date);
  }

  /// Calculates the start and end milliseconds of a given month.
  ///
  /// This static method determines the first and last milliseconds of the month
  /// for a specified ExtendedDate. It calculates the exact range that encompasses
  /// the entire month, from the first millisecond of the first day to the last
  /// millisecond of the last day.
  ///
  /// Parameters:
  ///   - date: An ExtendedDate instance to calculate the month's interval for.
  ///
  /// Returns:
  ///   A tuple containing the first and last milliseconds since the Unix epoch
  ///   for the month of the given date.
  ///
  /// Note:
  ///   Useful for time range calculations that require precise month boundaries.
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

  /// Determines if a given year is a leap year.
  ///
  /// This static method checks if the specified year qualifies as a leap year,
  /// following the leap year rules (divisible by 4, not divisible by 100 unless
  /// also divisible by 400).
  ///
  /// Parameters:
  ///   - year: The year to check for leap year status.
  ///
  /// Returns:
  ///   `true` if the year is a leap year, `false` otherwise.
  ///
  /// Note:
  ///   Essential for accurate date calculations, especially for February dates.
  static bool _isLeapYear(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  /// Calculates the last day of the month for a given date.
  ///
  /// This static method returns the numeric day (e.g., 28, 30, 31) that corresponds
  /// to the last day of the month for the specified ExtendedDate.
  ///
  /// Parameters:
  ///   - date: An ExtendedDate instance to find the last day of its month.
  ///
  /// Returns:
  ///   The day number of the last day of the month.
  ///
  /// Note:
  ///   Accounts for leap years when calculating February's last day.
  static int _lastDayOfMonth(ExtendedDate date) {
    if (date.month == 2) {
      return (_isLeapYear(date.year)) ? 29 : 28;
    }
    return ([4, 6, 9, 11].contains(date.month)) ? 30 : 31;
  }

  /// Retrieves the last day of the month for the current ExtendedDate.
  ///
  /// This getter calculates the last moment just before the next month begins,
  /// effectively giving the last day of the current month with time set to the
  /// very end of the day.
  ///
  /// Returns:
  ///   An ExtendedDate instance representing the last day of the current month,
  ///   at the last possible millisecond.
  ///
  /// Note:
  ///   Useful for operations that require the end date of a month, such as
  ///   monthly reporting or billing cycles.
  ExtendedDate get lastDayOfTheMonth {
    ExtendedDate lasDayOfMoth = month < 12
        ? ExtendedDate(year, month + 1, 1)
        : ExtendedDate(year + 1, 1, 1);

    return lasDayOfMoth.subtract(const Duration(seconds: 1));
  }

  /// Calculates the ExtendedDate for the day following the current date.
  ///
  /// Returns:
  ///   An ExtendedDate instance representing the day after the current date.
  ///
  /// Note:
  ///   Useful for daily scheduling or next-day calculations.
  ExtendedDate nextDay() {
    return add(const Duration(days: 1));
  }

  /// Calculates the ExtendedDate for the day preceding the current date.
  ///
  /// Returns:
  ///   An ExtendedDate instance representing the day before the current date.
  ///
  /// Note:
  ///   Ideal for operations that require access to the previous day's date, such
  ///   as data backtracking or historical comparisons.
  ExtendedDate previusDay() {
    return add(const Duration(days: -1));
  }

  /// Calculates the ExtendedDate one week after the current date.
  ///
  /// Returns:
  ///   An ExtendedDate instance representing the date seven days after the current date.
  ///
  /// Note:
  ///   Facilitates weekly planning or the calculation of future dates by week intervals.
  ExtendedDate nextWeek() {
    return add(const Duration(days: 7));
  }

  /// Calculates the ExtendedDate one week after the current date.
  ///
  /// Returns:
  ///   An ExtendedDate instance representing the date seven days after the current date.
  ///
  /// Note:
  ///   Facilitates weekly planning or the calculation of future dates by week intervals.
  ExtendedDate nextYear() {
    return ExtendedDate(year + 1, month, day, hour, minute, second);
  }

  /// Calculates the ExtendedDate approximately one month after the current date.
  ///
  /// This method adds a number of days to the current date to approximate the same day
  /// in the next month, accounting for variations in month lengths and leap years.
  ///
  /// Returns:
  ///   An ExtendedDate instance representing an approximate date one month after the current date.
  ///
  /// Note:
  ///   Since months vary in length, the actual day might not correspond exactly to "one month later,"
  ///   especially for dates towards the end of months with more days than the subsequent month.
  ExtendedDate nextMonth() {
    int newDay = day;
    int newMonth = month + 1;
    int newYear = year;

    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    }

    newDay = _adjustDay(newDay, newMonth, newYear);

    return ExtendedDate(newYear, newMonth, newDay, hour, minute, second);
  }

  /// Calculates the ExtendedDate approximately one month before the current date.
  ///
  /// This method subtracts a number of days to approximate the same day in the previous month,
  /// accounting for variations in month lengths and leap years.
  ///
  /// Returns:
  ///   An ExtendedDate instance representing an approximate date one month before the current date.
  ///
  /// Note:
  ///   Since months vary in length, this approximation might not precisely match "one month earlier,"
  ///   especially for dates at the start of months following shorter months.
  ExtendedDate previousMonth() {
    int newDay = day;
    int newMonth = month - 1;
    int newYear = year;

    if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }

    newDay = _adjustDay(newDay, newMonth, newYear);

    return ExtendedDate(newYear, newMonth, newDay, hour, minute, second);
  }

  int _adjustDay(int day, int month, int year) {
    if (month == 2 && day > 28) {
      day = _isLeapYear(year) ? 29 : 28;
    } else if ([4, 6, 9, 11].contains(month) && day > 30) {
      day = 30;
    }

    return day;
  }

  /// Adds a specified duration to the current date, returning a new ExtendedDate.
  ///
  /// Parameters:
  ///   - duration: The Duration to add to the current date.
  ///
  /// Returns:
  ///   A new ExtendedDate instance representing the date and time after adding the specified duration.

  /// Subtracts a specified duration from the current date, returning a new ExtendedDate.
  ///
  /// Parameters:
  ///   - duration: The Duration to subtract from the current date.
  ///
  /// Returns:
  ///   A new ExtendedDate instance representing the date and time after subtracting the specified duration.
  @override
  ExtendedDate add(Duration duration) {
    var date = super.add(duration);
    return _copyDateTime(date);
  }

  /// Returns a string representation of the ExtendedDate in a human-readable format.
  ///
  /// Returns:
  ///   A string formatted as `Year Month Day, Hour:Minute`, using the system's locale.
  @override
  ExtendedDate subtract(Duration duration) {
    var date = super.subtract(duration);
    return _copyDateTime(date);
  }

  /// Returns a string representation of the ExtendedDate in a human-readable format.
  ///
  /// Returns:
  ///   A string formatted as `Year Month Day, Hour:Minute`, using the system's locale.
  @override
  String toString() {
    return DateFormat.yMMMEd().add_Hm().format(this);
  }

  /// Comparison operators for ExtendedDate, allowing for direct comparison between two ExtendedDate instances.
  ///
  /// Operator `>` compare the millisecondsSinceEpoch values of two ExtendedDate instances,
  /// facilitating chronological comparisons.
  bool operator >(ExtendedDate other) =>
      millisecondsSinceEpoch > other.millisecondsSinceEpoch;

  /// Comparison operators for ExtendedDate, allowing for direct comparison between two ExtendedDate instances.
  ///
  /// Operator `>=` compare the millisecondsSinceEpoch values of two ExtendedDate instances,
  /// facilitating chronological comparisons.
  bool operator >=(ExtendedDate other) =>
      millisecondsSinceEpoch >= other.millisecondsSinceEpoch;

  /// Comparison operators for ExtendedDate, allowing for direct comparison between two ExtendedDate instances.
  ///
  /// Operator `<` compare the millisecondsSinceEpoch values of two ExtendedDate instances,
  /// facilitating chronological comparisons.
  bool operator <(ExtendedDate other) =>
      millisecondsSinceEpoch < other.millisecondsSinceEpoch;

  /// Comparison operators for ExtendedDate, allowing for direct comparison between two ExtendedDate instances.
  ///
  /// Operator `<=` compare the millisecondsSinceEpoch values of two ExtendedDate instances,
  /// facilitating chronological comparisons.
  bool operator <=(ExtendedDate other) =>
      millisecondsSinceEpoch <= other.millisecondsSinceEpoch;

  /// Comparison operators for ExtendedDate, allowing for direct comparison between two ExtendedDate instances.
  ///
  /// The `==` operator checks for equality in millisecondsSinceEpoch between two ExtendedDate instances or
  /// an ExtendedDate and a DateTime, ensuring precise time point comparison.
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
