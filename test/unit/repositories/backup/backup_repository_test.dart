import 'package:finances/repositories/backup/backup_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockDatabaseBackuper databaseBackuper;
  late MockDatabaseProvider databaseProvider;
  late MockAbstractUserRepository userRepository;
  late BackupRepository repository;

  setUp(() {
    databaseBackuper = MockDatabaseBackuper();
    databaseProvider = MockDatabaseProvider();
    userRepository = MockAbstractUserRepository();

    repository = BackupRepository(
      databaseBackuper: databaseBackuper,
      databaseProvider: databaseProvider,
      userRepository: userRepository,
    );
  });

  group('BackupRepository', () {
    test('migra o banco antes de reiniciar os repositórios', () async {
      when(
        () => databaseBackuper.restoreDatabase('/backup.db'),
      ).thenAnswer((_) async => true);

      when(
        () => databaseProvider.init(),
      ).thenAnswer((_) async {});

      when(
        () => userRepository.restart(),
      ).thenAnswer((_) async {});

      final restored = await repository.restoreBackup('/backup.db');

      expect(restored, isTrue);

      verifyInOrder(<void Function()>[
        () => databaseBackuper.restoreDatabase('/backup.db'),
        () => databaseProvider.init(),
        () => userRepository.restart(),
      ]);
    });

    test('não migra nem reinicia repositórios quando a restauração falha',
        () async {
      when(
        () => databaseBackuper.restoreDatabase('/invalid.db'),
      ).thenAnswer((_) async => false);

      final restored = await repository.restoreBackup('/invalid.db');

      expect(restored, isFalse);
      verifyNever(() => databaseProvider.init());
      verifyNever(() => userRepository.restart());
    });

    test('propaga falha de migração sem reiniciar os repositórios', () async {
      when(
        () => databaseBackuper.restoreDatabase('/legacy.db'),
      ).thenAnswer((_) async => true);

      when(
        () => databaseProvider.init(),
      ).thenThrow(Exception('Falha na migração'));

      final operation = repository.restoreBackup('/legacy.db');

      await expectLater(
        operation,
        throwsA(isA<Exception>()),
      );

      verifyNever(() => userRepository.restart());
    });
  });
}
