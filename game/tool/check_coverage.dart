import 'dart:io';

void main(List<String> args) {
  final path = args.isNotEmpty ? args[0] : 'coverage/lcov.info';
  final minCoverage = args.length > 1 ? double.parse(args[1]) : 30.0;
  final minFiles = args.length > 2 ? int.parse(args[2]) : 10;

  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('Coverage file not found: $path');
    exitCode = 1;
    return;
  }

  var files = 0;
  var linesFound = 0;
  var linesHit = 0;

  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      files += 1;
    } else if (line.startsWith('LF:')) {
      linesFound += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      linesHit += int.parse(line.substring(3));
    }
  }

  final coverage = linesFound == 0 ? 0.0 : linesHit * 100 / linesFound;
  final coverageText = coverage.toStringAsFixed(2);
  stdout.writeln(
    'Coverage: $coverageText% ($linesHit/$linesFound lines, $files files)',
  );

  if (files < minFiles) {
    stderr.writeln(
      'Coverage includes $files files; expected at least $minFiles.',
    );
    exitCode = 1;
    return;
  }

  if (coverage < minCoverage) {
    stderr.writeln(
      'Coverage $coverageText% is below required ${minCoverage.toStringAsFixed(2)}%.',
    );
    exitCode = 1;
  }
}
