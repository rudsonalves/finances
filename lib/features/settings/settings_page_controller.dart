import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'settings_page_state.dart';

class SettingsPageController extends ChangeNotifier {
  late PackageInfo _packageInfo;

  PackageInfo get packageInfo => _packageInfo;

  SettingsPageState _state = SettingsPageStateInitial();

  SettingsPageState get state => _state;

  void _changeState(SettingsPageState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> init() async {
    _changeState(SettingsPageStateLoading());
    _packageInfo = await PackageInfo.fromPlatform();
    _changeState(SettingsPageStateSuccess());
  }
}
