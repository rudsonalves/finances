# Changelog

## 2026/09/02 - revision/ajustes-02

1. **Database recovery**
   - Check the backup repository result before reporting a successful restoration.
   - Display the localized retrieval error with the selected filename when restoration fails.
   - Prevent application restart and success messaging after an unsuccessful restore attempt.

### Conclusion

Database recovery now accurately communicates failed restore operations and continues only after a confirmed successful restoration.

## 2026/09/02 - revision/ajustes-01

1. **Application entry points and configuration (`lib/app_finances.dart`, `lib/main.dart`, `lib/firebase_options.dart`)**
   - Removed copyright, license, generated-file, and usage comments to reduce source-file boilerplate.
   - Reorganized imports for consistent grouping and ordering.
   - Removed redundant comments from dynamic color selection while preserving harmonized system colors and fallback theme behavior.
   - Simplified Firebase options documentation without changing platform-specific configuration behavior.

2. **Dependency lifecycle (`lib/locator.dart`)**
   - Removed obsolete commented-out disposal calls, leaving only the active controller and database repository cleanup operations.

### Conclusion

This revision streamlines application bootstrap, Firebase configuration, theme setup, and dependency disposal sources by removing outdated comments and organizing imports.

No functional behavior was changed.

## 2026/09/02 - revision/task-08

1. **Project testing guidelines**
   - Added `AGENTS.md` with guidance to automate deterministic unit, widget, SQLite, migration, repository, controller, parser, and controlled-dependency tests.
   - Defined device-, emulator-, Firebase-, platform-, permission-, restart-, and process-persistence-dependent E2E scenarios as manual tests requiring reproducible instructions and user-recorded evidence.

2. **Database and monetary precision**
   - Updated transaction insert and delete triggers to round opening and closing balances to two decimal places, preventing accumulated floating-point drift.
   - Advanced the database schema to version `1014` and added a migration that replaces existing transaction triggers with their rounded versions while preserving stored data.
   - Added an injectable schema creator to `DatabaseManager`, enabling deterministic schema-initialization failure testing without suppressing errors.

3. **Database regression tests**
   - Added coverage confirming schema creation failures propagate to callers.
   - Added migration coverage verifying that version `1014` preserves transactions, installs both rounded triggers, maintains transaction counts, and restores exact balances after repeated cent operations are removed.
   - Added repository coverage proving that 100 one-cent transfers produce exact `-1.00` and `1.00` balances.
   - Added aggregation coverage ensuring monthly income, expense, and category totals do not expose monetary drift.

4. **E2E infrastructure and dependencies**
   - Removed the dedicated Firebase Auth Emulator E2E entry point.
   - Disabled the `integration_test` development dependency and removed its related transitive packages from the lockfile, aligning the project with the documented manual-testing policy for environment-dependent E2E scenarios.

5. **Backlog documentation**
   - Moved the master testing plan and critical widget-flow backlog into the closed backlog directory.
   - Marked all Task 7 widget, smoke, and E2E items as completed.
   - Replaced the original Task 8 checklist with a closed, detailed regression inventory covering atomic transfers, atomic transaction updates, schema error propagation, foreign-key restoration after migration failures, and monetary precision.
   - Documented severity, reproduction, impact, fixes, regression tests, acceptance criteria, validation evidence, and residual precision risk for each recorded bug.

6. **Gradle diagnostics**
   - Added the generated Android Gradle problems report documenting eight deprecation warnings for Groovy property assignment syntax scheduled for removal in Gradle 10.

### Conclusion

This revision closes the testing and bug-regression backlogs, strengthens deterministic database validation, and prevents two-decimal monetary balances from accumulating floating-point drift.

It also removes automated E2E infrastructure that depends on external runtime environments and records current Gradle compatibility warnings for future remediation.

## 2026/09/01 - revision/task-07a

1. **Home balance card**
   - Added a visibility control that masks and restores the current balance while preserving positive and negative color behavior.
   - Enabled injection of currency formatting, current balance, and current account dependencies to improve isolation and testability.
   - Updated income and expense rendering to receive its currency formatter explicitly.

2. **Home page**
   - Extracted the empty-transactions presentation into the reusable `EmptyTransactions` widget.
   - Reused the component for both empty and error states.

3. **Home page navigation**
   - Added optional controller and page injection to `HomePageView`, allowing navigation flows to run with controlled dependencies and custom page content.

4. **Transaction dialog**
   - Added injectable transaction, home-page, and category controllers.
   - Ensured externally supplied transaction controllers are not disposed by the dialog.
   - Reused the injected category controller for initialization and category refresh operations.

5. **Dependency configuration**
   - Extended `setupDependencies` to accept optional authentication and database manager implementations while retaining production defaults.

6. **Database lifecycle**
   - Added database path access and centralized close-and-delete behavior in `DatabaseManager`.
   - Updated the database provider to delegate deletion to the configured manager, supporting custom database locations.

7. **End-to-end runtime**
   - Added a dedicated E2E entry point that requires the Firebase Authentication emulator and prevents accidental production authentication use.
   - Configured an isolated E2E database file, initialized application dependencies, and prepared the database before startup.

8. **Tests**
   - Added widget coverage for balance colors, balance visibility toggling, and the empty-transactions state.
   - Added transaction-dialog tests for validation, category selection, and switching between expense and income modes.
   - Added flow tests covering transaction creation and OFX file selection, confirmation, import, and displayed result updates.

9. **Dependencies**
   - Added Flutter’s `integration_test` development dependency and its required transitive driver packages.

10. **Documentation**
    - Moved the persistence, migrations, and backup backlog document into the closed backlog directory to record its completion.

### Conclusion

This revision improves privacy controls on the balance card and extracts reusable empty-state UI.

It also introduces dependency injection points and an isolated E2E runtime, enabling broader widget and workflow test coverage without coupling tests to production services.

## 2026/09/01 - revision/task-06b

1. **Database backup and restoration**
   - Added injectable database, factory, path, and clock dependencies for isolated testing.
   - Validated backup integrity, application schema, and supported versions before restoration.
   - Preserved existing backups during failed exports and restored the current database after replacement failures.
   - Migrated restored databases before restarting user repositories and propagated failures without continuing from partial state.

2. **Schema and migrations**
   - Advanced the schema version to `1013`.
   - Added a composite transaction index on account and date for account-scoped pagination.
   - Included the new index in fresh database creation and migration paths.

3. **Statistics**
   - Scoped category totals to the current account, preventing transactions from other accounts from affecting results.

4. **Tests**
   - Added SQLite integration coverage for backup export, restoration, corrupted or incompatible files, future schema versions, legacy backups, and backup preservation.
   - Added migration-provider tests for safety backup requirements, restoration after migration failures, and avoiding unnecessary backups.
   - Extended migration tests through version `1013`, including data preservation, constraints, OFX uniqueness, rollback behavior, and the composite index.
   - Added real repository integration tests for transaction pagination, monthly totals, balances, and account-scoped statistics.
   - Added unit tests for backup repository restoration sequencing and failure handling.

5. **Documentation**
   - Marked persistence, migration, backup, and repository integration tasks as completed.
   - Documented the delivered behavior and verification results, including 370 passing tests and clean analysis and diff checks.

### Conclusion

Database persistence is now more resilient through validated backups, safe migration recovery, and explicit failure propagation.

Account-specific queries are correctly isolated and supported by an optimized composite index, with comprehensive SQLite integration coverage.

## 2026/08/31 - revision/task-06a

1. `lib/store/database/database_manager.dart`
   - Refactored database initialization to accept injectable factories and path providers, enabling isolated in-memory testing.
   - Replaced the global database connection with an instance-managed connection that is reused while open and recreated after closing.
   - Opened databases through configurable `OpenDatabaseOptions`.
   - Simplified schema creation and allowed creation failures to propagate instead of being silently logged.
   - Optimized schema batch creation by committing without returning individual results.

2. `lib/store/database/database_migrations.dart`
   - Removed explicit transaction statements from migration scripts so each version is handled atomically by its batch.
   - Added validation that every requested schema version has a migration script, raising a clear error when one is missing.
   - Ensured foreign-key enforcement is always restored after migration success or failure.
   - Preserved the version-specific cleanup of empty balances after migration 1008.

3. `test/integration/database/database_manager_test.dart`
   - Added integration coverage for complete schema creation, foreign-key activation, connection reuse, and reopening after closure.

4. `test/integration/database/database_migrations_test.dart`
   - Added coverage for continuous migration history and alignment with the current schema version.
   - Verified data preservation, schema evolution, OFX structures, indexes, and balance triggers across migrations 1000 through 1010.
   - Confirmed failed migrations roll back the affected version and restore foreign-key enforcement.

5. `test/integration/database/tables_creators_test.dart`
   - Added comprehensive validation of current tables, indexes, columns, defaults, primary keys, and required fields.
   - Verified compound uniqueness for imported OFX transactions and enforcement of foreign-key relationships.
   - Covered constraint failures and balance propagation when transactions are inserted or removed.

### Conclusion

Database creation and migration handling are now injectable, atomic, and safer during failures.

New integration tests validate schema integrity, migration compatibility, connection lifecycle, constraints, and financial balance triggers.

## 2026/08/31 - revision/task-05

1. **Account controller**
   - Made initialization await balance loading so callers receive the final state only after completion.
   - Builds balances atomically, preventing partial or previously valid data from being overwritten when a refresh fails.

2. **Home and balance card controllers**
   - Made initialization, account changes, filtering, period navigation, balance recalculation, and future-transaction updates await their dependent asynchronous operations.
   - Ensures success states and UI updates occur only after transactions and balances finish reloading.

3. **Authentication and password recovery**
   - Added loading, completion, and error handling to password recovery.
   - Introduced a dedicated password-recovery completion state so recovery is not mistaken for successful login.
   - Updated the sign-in page to close the recovery dialog when the operation completes.

4. **Transaction controller**
   - Hardened initialization by validating existing origin accounts and linked transfers, restoring transaction category and account data, and reporting failures through the error state.
   - Made transaction persistence awaitable with explicit loading, success, and error transitions.
   - Keeps the transaction screen open after failed saves and closes it only after successful persistence.
   - Validates recurring installment counts and supports awaited creation or updates of transactions and transfers, including monthly repetitions.
   - Simplified obsolete comments and normalized imports.

5. **Controller test coverage**
   - Added unit tests for account balance loading, totals, notifications, awaited initialization, refresh failures, and preservation of valid balances.
   - Added home and balance card tests covering initialization, repository errors, account switching, filters, pagination, month changes, display toggles, future periods, and recalculation.
   - Added sign-in and sign-up tests covering success paths, local-data initialization, missing identifiers, Firebase failures, password recovery, and state notifications.
   - Added comprehensive transaction tests for initialization, account and category selection, transfers, recurring entries, creation, editing, validation, navigation, and failure handling using mocked repositories and services.

6. **Backlog documentation**
   - Marked all controller-testing tasks as complete and moved the backlog document into `docs/backlogs/closed`.
   - Recorded the implemented asynchronous-state improvements, test scope, and reported validation results of 329 passing tests with no analyzer findings.

### Conclusion

Controller workflows now expose reliable asynchronous completion and clearer success and failure states.

The new isolated test suites verify state notifications and the main account, authentication, home, balance, and transaction behaviors.

## 2026/08/31 - revision/task-04

### Validation

1. `SignValidator` now trims names and emails, validates complete accented names, and requires passwords with at least eight non-whitespace characters, one uppercase letter, and one digit.
2. `AccountValidator` and `TransactionValidator` now ignore surrounding whitespace when checking required fields and minimum lengths.
3. Transaction amount validation now rejects negative, zero, and nonnumeric values while accepting masked currency input.
4. Transaction dates now require the form’s timestamp format and reject invalid calendar values.
5. Transfer account validation now requires a positive identifier and uses the localized error message.
6. `TransactionDialog` now applies date validation to the date-time field.

### Currency and localization

1. Currency separators were corrected for Portuguese, Spanish, Italian, German, and French locales, including locale-appropriate nonbreaking spaces.
2. `MoneyMaskedText` now formats absolute values directly, supports configurable precision, rounds correctly, groups thousands, and consistently positions or suppresses negative signs.
3. `MoneyMaskedTextController` now supports zero precision, normalizes negative input, rejects non-finite or oversized initial values, and preserves the last valid value when later updates exceed the 12-digit limit.

### Dates and responsive sizing

1. `ExtendedDate` now preserves UTC state and full subsecond precision when copying, parsing, adding, or subtracting dates.
2. Month and year navigation now clamps invalid days, handles leap years, preserves time precision, and returns the final millisecond of a month.
3. Date equality and hashing now consistently use the represented instant.
4. Monthly intervals now begin at midnight and end at `23:59:59.999`.
5. `AppScale` now refreshes whenever the media width changes.
6. `Sizes` now accepts and retains a custom design size and recalculates dimensions from the current media context.

### Model serialization

1. Account and category serialization now reports explicit state errors when their icons lack identifiers.
2. Balance serialization now requires an account and date, while balance, category, and transaction deserialization accept both integer and floating-point numeric values.
3. Category mapping now uses one shared payload and includes its identifier only when available.
4. Transfer deserialization now preserves nullable transaction and account relationships.
5. User copying now creates independent category and OFX exclusion lists instead of sharing mutable references.

### Tests

1. Added unit coverage for responsive scale and sizing behavior, including screen changes and custom design dimensions.
2. Added currency formatter and controller tests covering supported locales, signs, precision, rounding, editing, limits, and configuration errors.
3. Added model tests for account, balance, category, icon, transaction, transfer, and user serialization, JSON round trips, nullable data, copy behavior, and invalid state handling.
4. Added comprehensive `ExtendedDate` tests for UTC preservation, precision, month boundaries, leap years, navigation, comparisons, and hashing.
5. Added validator tests for names, emails, passwords, account fields, transaction amounts, descriptions, categories, dates, and destination accounts.

### Documentation

1. Marked validator, extension, utility, and model serialization testing tasks as complete in backlog 04.
2. Moved completed backlog documents 01, 02, and 03 into `docs/backlogs/closed/`.

### Conclusion

This revision strengthens validation, localized currency handling, date calculations, responsive sizing, and model serialization.

The new unit suites document these behaviors and protect their boundary cases, while completed backlog work is archived accordingly.

## 2026/08/31 - revision/task-03b

1. **OFX parser**
   - Added support for legacy OFX 1.02 SGML by normalizing unclosed tags, compact or indented markup, empty optional fields, and special characters into valid XML.
   - Added byte-based parsing with UTF-8 decoding and ISO-8859-1 fallback.
   - Improved validation to report malformed documents or missing OFX roots with `FormatException`.
   - Added credit-card statement support when `BANKID` and `ACCTTYPE` are absent.
   - Removed the obsolete duplicate `OfxTransaction` model.

2. **OFX import workflow**
   - Updated file processing to parse raw bytes through the centralized OFX parser.
   - Added duplicate prevention using the composite institution, bank account, and `FITID` identity.
   - Added atomic import claims before transaction creation, including conflict-safe concurrent imports and claim release when persistence fails.
   - Preserved template updates and routing between regular transactions and transfers.

3. **Managers and repositories**
   - Added `OfxImportManager` and repository abstractions for checking, claiming, and releasing imported transaction identities.
   - Made account, relationship, and transaction-template managers accept injectable repositories for isolated testing.
   - Added validation that newly persisted templates return an identifier.

4. **Database**
   - Upgraded the schema to version `1012`.
   - Added an imported-transaction tracking table linked to OFX accounts with cascading deletion.
   - Added a unique composite index over institution, bank account, and `FITID`.
   - Included the new table and index in fresh database creation and migration paths.

5. **Tests and fixtures**
   - Added synthetic fixtures for SGML 1.02, credit-card XML, truncated XML, and documents without an OFX root.
   - Expanded parser tests for SGML normalization, encodings, timezone-aware dates, optional fields, credit cards, and invalid documents.
   - Added manager unit tests using repository mocks.
   - Added repository integration tests covering reimports, overlapping identifiers, concurrent claims, and retry after release.

6. **Documentation**
   - Marked OFX fixture, parser, and manager testing tasks as complete.
   - Documented supported formats, encoding coverage, repository decoupling, duplicate protection, and the migration limitation for imports created before `FITID` tracking.

### Conclusion

OFX imports now support modern XML and legacy SGML statements with broader encoding and account-type compatibility.

Persistent composite-key claims prevent duplicate and concurrent transaction imports while allowing safe retries after failures. Test coverage and backlog documentation were updated accordingly.

## 2026/08/31 - revision/task-03a

1. `DateTimeAdapter`
   - Added strict validation of parsed OFX date components, rejecting normalized invalid dates with a `FormatException`.
   - Simplified timezone conversion by deriving the UTC instant from the embedded offset and converting it to local time.
   - Expanded timezone parsing to accept explicit positive or negative offsets and identifiers beyond `GMT`, while defaulting to UTC when no valid offset exists.
   - Removed outdated inline documentation and comments.

2. `Ofx` DTO
   - Restored local `DateTime` values when deserializing `serverLocal`, `startLocal`, and `endLocal` timestamps instead of incorrectly marking them as UTC.

3. `OfxTransaction`
   - Added contextual validation for `DTPOSTED`, reporting the invalid source value when date parsing fails.
   - Restored local `DateTime` semantics when deserializing `postedLocal`.

4. OFX test fixtures
   - Added a bank statement fixture containing a transaction with an invalid month in `DTPOSTED`.

5. OFX tests
   - Added unit coverage for UTC date parsing, invalid date rejection, local timezone conversion, signed offsets, `BRT` identifiers, and missing timezone information.
   - Added parser coverage verifying that invalid `DTPOSTED` values produce the expected contextual `FormatException`.

### Conclusion

OFX date handling now validates malformed calendar values, interprets timezone offsets more broadly, and preserves local timestamp semantics during deserialization.

The added tests and fixture protect valid timezone conversions and invalid transaction-date reporting.

## 2026/08/31 - revision/task-03

### OFX parsing

1. `lib/packages/ofx/lib/src/dto/ofx.dart`
   - Added shared transaction normalization for bank and credit-card statements, supporting a transaction list, a single transaction object, and statements without transactions.
   - Added a format error for unsupported `STMTTRN` structures.
   - Corrected internal map reconstruction to use the appropriate model deserializers and consistently restore timestamps as UTC.
   - Removed obsolete API and license comments without changing the public interface.

2. `lib/packages/ofx/lib/src/models/ofx_transaction.dart`
   - Added validation for required transaction identifiers, amounts, and posting dates, with explicit format errors for missing or invalid values.
   - Preserved valid positive and negative amounts while rejecting non-numeric or non-finite values.
   - Made `REFNUM` optional, falling back to an empty string.
   - Added transaction-description fallback from `MEMO` to `NAME`, then to an empty string.
   - Restored serialized transaction timestamps as UTC.

### Test coverage

3. `test/unit/packages/ofx/ofx_parser_test.dart`
   - Added OFX 2.x parser coverage for institution, account, statement-period, debit, and credit data.
   - Verified parsing of multiple transactions, a single `STMTTRN` object, and empty statements.
   - Added round-trip coverage for `Ofx.toMap` and `Ofx.fromMap`.
   - Covered optional descriptions and reference numbers, including fallback behavior.
   - Verified failures for missing `FITID`, missing or invalid `TRNAMT`, and missing or truncated `DTPOSTED`.

4. `test/helpers/fixtures/ofx/`
   - Added valid fixtures for multi-transaction, single-transaction, empty, and optional-field statements.
   - Added invalid fixtures for missing identifiers, amounts, posting dates, malformed amounts, and truncated dates.

### Conclusion

OFX imports now handle common transaction-shape variations and optional metadata more reliably while rejecting malformed required fields with clear errors.

Serialization round trips also preserve UTC timestamps and reconstruct nested models correctly.

## 2026/08/31 - revision/task-02

### Financial Operations

1. Added a dedicated financial-operation repository that performs transfer creation, removal, replacement, and transaction updates within SQLite transactions.
2. Made paired transfer entries and their balance changes atomic, with rollback on partial failures to prevent orphaned transactions, transfers, or balances.
3. Updated transaction edits to atomically remove and reinsert records while cleaning up empty balances.
4. Added validation against same-account transfers, duplicate persistence, and concurrent operations on the same transaction object.
5. Propagated financial-operation errors to callers instead of converting failures into logs or sentinel values.
6. Preserved transfer associations when the transaction controller rebuilds an existing transaction.

### Managers and Dependency Injection

1. Updated balance creation to copy the previous closing value into a new model without mutating the historical balance.
2. Changed manager and user-model repository access to resolve dependencies dynamically, preventing stale service-locator instances between tests.
3. Registered the financial-operation repository in the application dependency locator.
4. Simplified transaction and transfer managers to delegate atomic persistence to the new repository.

### Test Infrastructure and Coverage

1. Added shared mocks, deterministic model fixtures, asynchronous locator setup and teardown, and in-memory SQLite FFI initialization.
2. Added unit tests for balance, transaction, and transfer managers, including validation, error propagation, duplicate and concurrent operations, and dependency replacement.
3. Added integration tests for SQLite transfer and transaction atomicity, rollback behavior, balance cleanup, and transfer replacement.
4. Added monetary invariant tests that normalize floating-point values to cents and cover accumulation, negative zero, and large values.
5. Added fixture and isolated in-memory database tests, plus a placeholder for future widget tests.
6. Added a coverage checker that excludes generated sources and enforces a minimum filtered coverage of 2.87%.

### Continuous Integration and Dependencies

1. Added a GitHub Actions workflow for pull requests and pushes to `main`, enforcing formatting, static analysis, tests with coverage, and the coverage baseline.
2. Added `sqflite_common_ffi` as a development dependency with its required transitive packages.
3. Ignored generated coverage output in Git.

### Documentation

1. Updated the architecture documentation to describe atomic financial operations and corrected Mermaid syntax and labels.
2. Reordered and reformatted the test roadmap phases and prioritization matrix.
3. Marked the test-infrastructure and financial-manager backlog tasks as completed, documenting delivered safeguards and the coverage increase from 0.16% to 2.87%.
4. Removed the temporary test note from the project changelog.

### Conclusion

Financial transaction and transfer updates are now backed by atomic SQLite operations with rollback and concurrency safeguards.

The change also establishes reusable test infrastructure, coverage enforcement, and CI validation for the financial core.

## 2026/08/30 - docs/planning-01

1. **Architecture and test-planning documentation**
   - Added a comprehensive architecture guide covering application layers, data flow, persistence, dependency injection, authentication, OFX processing, localization, and theming.
   - Added a prioritized test-coverage master plan focused on financial integrity, persistence, state management, widgets, and critical user flows.
   - Split the plan into actionable backlogs for test infrastructure, financial managers, OFX imports, validation and models, controllers, database reliability, UI flows, and bug regression.
   - Added a backlog index with priorities and a recommended implementation order.

2. **Changelog workflow**
   - Added an initial `CHANGELOG.md` describing its role in recording generated release entries, including a temporary placeholder entry.
   - Added a reusable commit prompt defining the required changelog format for staged changes.

3. **Analyzer and formatter configuration**
   - Simplified `analysis_options.yaml` while retaining Flutter’s recommended lint configuration and platform/build exclusions.
   - Configured the Dart formatter to preserve existing trailing-comma choices.

4. **Project housekeeping**
   - Added `.commit/` to `.gitignore` to exclude local commit-workflow artifacts.
   - Normalized the final newline in `.gitignore`.
   - Removed obsolete dependency-version comments from `pubspec.yaml` without changing dependency constraints.

5. **Application metadata**
   - Incremented the application build version from `1.2.00+105` to `1.2.00+106`.

### Conclusion

This change establishes the project’s architecture reference, test strategy, prioritized implementation backlogs, and changelog-generation workflow.

No production behavior, dependencies, or automated tests were changed beyond the application build metadata and development configuration cleanup.

This file records release workflow entries generated from the staged changes.
