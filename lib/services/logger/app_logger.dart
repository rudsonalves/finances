import 'package:logger/logger.dart';

class AppLogger {
  final logger = Logger(
    filter: AppLogFilter(),
  );
}

class AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (event.level == Level.error || event.level == Level.warning) {
      return true;
    }

    return false;
  }
}
