# Changelog

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
