import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app_finances.dart';
import './locator.dart';
import './firebase_options.dart';
import 'repositories/database/abstract_database_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupDependencies();

  var dbRepository = locator<AbstractDatabaseRepository>();
  await dbRepository.init();

  runApp(const AppFinances());
}
