import 'dart:io';

const excludedPathFragments = <String>[
  '/lib/l10n/',
  '/firebase_options.dart',
  '.g.dart',
  '.freezed.dart',
];

void main(List<String> arguments) {
  final minimum = _minimumCoverage(arguments);
  final coverageFile = File('coverage/lcov.info');

  if (!coverageFile.existsSync()) {
    stderr.writeln(
      'coverage/lcov.info not found. Run flutter test --coverage first.',
    );
    exitCode = 2;
    return;
  }

  var linesFound = 0;
  var linesHit = 0;

  for (final record in coverageFile.readAsStringSync().split('end_of_record')) {
    final source = RegExp(r'^SF:(.+)$', multiLine: true).firstMatch(record);
    if (source == null || _isExcluded(source.group(1)!)) {
      continue;
    }

    linesFound += _summaryValue(record, 'LF');
    linesHit += _summaryValue(record, 'LH');
  }

  final coverage = linesFound == 0 ? 0.0 : linesHit * 100 / linesFound;
  stdout.writeln(
    'Coverage: ${coverage.toStringAsFixed(2)}% '
    '($linesHit/$linesFound lines; minimum ${minimum.toStringAsFixed(2)}%)',
  );

  if (coverage + 0.000001 < minimum) {
    stderr.writeln('Coverage is below the configured baseline.');
    exitCode = 1;
  }
}

double _minimumCoverage(List<String> arguments) {
  final optionIndex = arguments.indexOf('--min');
  final rawValue = optionIndex >= 0 && optionIndex + 1 < arguments.length
      ? arguments[optionIndex + 1]
      : Platform.environment['MIN_COVERAGE'] ?? '2.87';
  final value = double.tryParse(rawValue);
  if (value == null || value < 0 || value > 100) {
    stderr.writeln('Invalid minimum coverage: $rawValue');
    exit(2);
  }
  return value;
}

bool _isExcluded(String source) {
  return excludedPathFragments.any(source.contains);
}

int _summaryValue(String record, String key) {
  final match = RegExp('^$key:(\\d+)\$', multiLine: true).firstMatch(record);
  return match == null ? 0 : int.parse(match.group(1)!);
}
