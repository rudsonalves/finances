import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app_finances.dart';
import './locator.dart';
import './firebase_options.dart';
import './services/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupDependencies();

  var helper = locator.get<DatabaseHelper>();
  await helper.init();

  runApp(const AppFinances());
}
