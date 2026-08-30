# Changelog

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

## Teste

Remover após o primeiro commit.
