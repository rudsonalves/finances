import 'package:finances/common/admob/admob_google.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app_finances.dart';
import './locator.dart';
import './firebase_options.dart';
import './services/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (adMobEnable) {
    MobileAds.instance.initialize();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupDependencies();

  var helper = locator<DatabaseHelper>();
  await helper.init();

  runApp(const AppFinances());
}
