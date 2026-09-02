import 'package:finances/repositories/account/abstract_account_repository.dart';
import 'package:finances/repositories/balance/abstract_balance_repository.dart';
import 'package:finances/repositories/category/abstract_category_repository.dart';
import 'package:finances/repositories/financial_operation/abstract_financial_operation_repository.dart';
import 'package:finances/repositories/ofx_account/abstract_ofx_account_repository.dart';
import 'package:finances/repositories/ofx_relationship/abstract_ofx_relationship_repository.dart';
import 'package:finances/repositories/ofx_trans_template/abstract_ofx_trans_template_repository.dart';
import 'package:finances/repositories/transaction/abstract_transaction_repository.dart';
import 'package:finances/repositories/transfer/abstract_transfer_repository.dart';
import 'package:finances/repositories/user/abstract_user_repository.dart';
import 'package:finances/services/authentication/auth_service.dart';
import 'package:finances/store/database/database_backup.dart';
import 'package:finances/store/database/database_manager.dart';
import 'package:finances/store/database/database_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';

class MockAbstractBalanceRepository extends Mock
    implements AbstractBalanceRepository {}

class MockAbstractTransactionRepository extends Mock
    implements AbstractTransactionRepository {}

class MockAbstractAccountRepository extends Mock
    implements AbstractAccountRepository {}

class MockAbstractTransferRepository extends Mock
    implements AbstractTransferRepository {}

class MockAbstractCategoryRepository extends Mock
    implements AbstractCategoryRepository {}

class MockAbstractUserRepository extends Mock
    implements AbstractUserRepository {}

class MockAbstractFinancialOperationRepository extends Mock
    implements AbstractFinancialOperationRepository {}

class MockAbstractOfxAccountRepository extends Mock
    implements AbstractOfxAccountRepository {}

class MockAbstractOfxRelationshipRepository extends Mock
    implements AbtractOfxRelationshipRepository {}

class MockAbstractOfxTransTemplateRepository extends Mock
    implements AbstractOfxTransTemplateRepository {}

class MockAuthService extends Mock implements AuthService {}

class MockDatabase extends Mock implements Database {}

class MockDatabaseManager extends Mock implements DatabaseManager {}

class MockDatabaseBackuper extends Mock implements DatabaseBackuper {}

class MockDatabaseProvider extends Mock implements DatabaseProvider {}
