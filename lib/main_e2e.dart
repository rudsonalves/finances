import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'app_finances.dart';
import 'firebase_options.dart';
import 'locator.dart';
import 'repositories/database/abstract_database_repository.dart';
import 'services/authentication/firebase_auth_service.dart';
import 'store/database/database_manager.dart';

const String _authEmulatorHost = String.fromEnvironment(
  'FIREBASE_AUTH_EMULATOR_HOST',
);

const int _authEmulatorPort = int.fromEnvironment(
  'FIREBASE_AUTH_EMULATOR_PORT',
  defaultValue: 9099,
);

Future<String> _e2eDatabasePath() async {
  final directory = await getApplicationDocumentsDirectory();

  return join(
    directory.path,
    'app_database_e2e.db',
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_authEmulatorHost.trim().isEmpty) {
    throw StateError(
      'FIREBASE_AUTH_EMULATOR_HOST deve ser informado para executar E2E. '
      'O teste não pode usar o Firebase de produção.',
    );
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.useAuthEmulator(
    _authEmulatorHost,
    _authEmulatorPort,
  );

  setupDependencies(
    authService: FirebaseAuthService(),
    databaseManager: DatabaseManager(
      databasePathProvider: _e2eDatabasePath,
    ),
  );

  final databaseRepository = locator<AbstractDatabaseRepository>();

  await databaseRepository.init();

  runApp(const AppFinances());
}
