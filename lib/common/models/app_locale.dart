import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppLocale {
  late AppLocalizations _locale;
  bool _started = false;

  bool get started => _started;

  void initializeLocale(BuildContext context) {
    if (_started) return;
    final locale = AppLocalizations.of(context);
    if (locale != null) {
      _locale = locale;
      _started = true;
    }
  }

  AppLocalizations get locale => _locale;

  void reloadContext(BuildContext context) {
    _started = false;
    initializeLocale(context);
  }
}
