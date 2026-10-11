import 'dart:io';

import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

/// The package ships an agent skill under `skills/`. Prose like it rots
/// quietly: the generator changes, the markdown does not, and an agent reading
/// it becomes more confident, not less. These tests tie the skill to the code
/// it describes, so that drift fails a build instead of teaching agents a lie.
void main() {
  test('skill folders follow the package skills convention', () {
    final name =
        (loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap)['name']
            as String;
    final prefixes = ['$name-', '${name.replaceAll('_', '-')}-'];
    for (final dir in _skillDirs) {
      final folder = _folderOf(dir);
      // The install tool skips a skill whose folder carries no package
      // prefix, and it skips it silently: nothing is installed, nothing
      // is reported.
      expect(
        prefixes.any(folder.startsWith),
        isTrue,
        reason: '$folder must start with one of $prefixes',
      );
      expect(
        RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$').hasMatch(folder),
        isTrue,
        reason: '$folder must be lowercase words joined by hyphens',
      );
      expect(
        folder.length,
        lessThanOrEqualTo(64),
        reason: '$folder is longer than the Agent Skills spec allows',
      );
      expect(
        _file(dir, 'SKILL.md').existsSync(),
        isTrue,
        reason: '$folder needs a SKILL.md',
      );
    }
  });

  test('frontmatter names the skill after its own folder', () {
    for (final dir in _skillDirs) {
      final folder = _folderOf(dir);
      final meta = _frontmatter(dir);
      expect(meta['name'], folder);
      final description = meta['description'] ?? '';
      expect(description.trim().length, greaterThan(20));
      expect(
        description.length,
        lessThanOrEqualTo(1024),
        reason: 'the description alone may not pass the spec limit',
      );
    }
  });

  test('SKILL.md stays inside the context budget', () {
    for (final dir in _skillDirs) {
      final lines = _file(dir, 'SKILL.md').readAsLinesSync();
      expect(
        lines.length,
        lessThanOrEqualTo(500),
        reason:
            'SKILL.md is loaded into context on every trigger, so the '
            'overflow belongs in references/',
      );
    }
  });

  test('every link in a skill file points at a file that exists', () {
    for (final dir in _skillDirs) {
      for (final file in _skillFiles(dir)) {
        for (final match in RegExp(r'\[[^\]]*\]\(([^)]+)\)').allMatches(
          file.readAsStringSync(),
        )) {
          final target = match.group(1)!;
          if (target.startsWith('http') ||
              target.startsWith('#') ||
              target.startsWith('mailto:')) {
            continue;
          }
          expect(
            File(p.join(file.parent.path, target)).existsSync(),
            isTrue,
            reason: '${file.path} links to the missing $target',
          );
        }
      }
    }
  });

  test('the predefined steps table matches the generator', () {
    expect(
      _predefinedStepRows().values.toSet(),
      predefinedSteps.keys.toSet(),
      reason:
          'references/predefined-steps.md and predefinedSteps in '
          'step_generator.dart must list the same steps',
    );
  });

  test('each documented step text really generates its function', () {
    for (final row in _predefinedStepRows().entries) {
      expect(
        stepIdentifier(row.key),
        row.value,
        reason: 'the table claims "${row.key}" generates ${row.value}',
      );
    }
  });

  test('README lists the same predefined steps as the generator', () {
    final readme = File('README.md').readAsLinesSync();
    final start = readme.indexWhere(
      (line) => line.startsWith('List of predefined steps:'),
    );
    expect(start, greaterThanOrEqualTo(0), reason: 'README lost its list');
    final steps = <String>[];
    for (final line in readme.skip(start + 1)) {
      if (!line.startsWith('* ')) {
        break;
      }
      steps.add(line.substring('* '.length));
    }
    expect(
      steps.map(stepIdentifier).nonNulls.toSet(),
      predefinedSteps.keys.toSet(),
      reason: 'README and predefinedSteps must list the same steps',
    );
    expect(steps, hasLength(predefinedSteps.length));
  });

  test('every documented option exists in GeneratorOptions', () {
    final source = File('lib/src/generator_options.dart').readAsStringSync();
    final reference = _file(
      _referenceDir,
      'references/configuration.md',
    ).readAsStringSync();
    for (final option in _tableFirstColumn(reference)) {
      expect(
        source,
        contains(option),
        reason:
            'configuration.md documents $option, which '
            'generator_options.dart does not know about',
      );
    }
  });
}

List<Directory> get _skillDirs =>
    _directory('skills').listSync().whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));

Directory get _referenceDir => _skillDirs.single;

Directory _directory(String path) {
  final dir = Directory(path);
  expect(
    dir.existsSync(),
    isTrue,
    reason: '$path/ is missing - tests run from the package root',
  );
  return dir;
}

File _file(Directory dir, String path) => File(p.join(dir.path, path));

String _folderOf(Directory dir) =>
    p.split(dir.path).lastWhere((part) => part.isNotEmpty);

List<File> _skillFiles(Directory dir) => dir
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('.md'))
    .toList();

/// The YAML frontmatter of a `SKILL.md`, folded scalars joined into one line.
Map<String, String> _frontmatter(Directory dir) {
  final lines = _file(dir, 'SKILL.md').readAsLinesSync();
  expect(lines.first.trim(), '---', reason: 'SKILL.md needs frontmatter');
  final end = lines.indexWhere((line) => line.trim() == '---', 1);
  expect(end, greaterThan(0), reason: 'the frontmatter is never closed');
  final meta = <String, String>{};
  String? key;
  final value = StringBuffer();
  void flush() {
    if (key != null) {
      meta[key] = value.toString().trim();
    }
  }

  for (final line in lines.sublist(1, end)) {
    final match = RegExp(r'^([A-Za-z_-]+):(.*)$').firstMatch(line);
    if (match != null) {
      flush();
      key = match.group(1);
      value.clear();
      final inline = match.group(2)!.trim();
      // A `>` or `|` block scalar keeps its content on the following lines.
      if (!inline.startsWith('>')) value.write(inline);
    } else if (key != null && line.trim().isNotEmpty) {
      value.write(' ${line.trim()}');
    }
  }
  flush();
  return meta;
}

/// Step text to function name, read out of the table in
/// `references/predefined-steps.md`.
Map<String, String> _predefinedStepRows() {
  final rows = <String, String>{};
  for (final line in _file(
    _referenceDir,
    'references/predefined-steps.md',
  ).readAsLinesSync()) {
    if (!line.startsWith('|')) continue;
    final cells = RegExp(
      '`([^`]+)`',
    ).allMatches(line).map((match) => match.group(1)!).toList();
    if (cells.length >= 2) rows[cells.first] = cells[1];
  }
  return rows;
}

/// The backticked first cell of every table row in [markdown].
List<String> _tableFirstColumn(String markdown) => [
  for (final line in markdown.split('\n'))
    if (line.startsWith('| `'))
      RegExp(r'^\|\s*`([^`]+)`').firstMatch(line)!.group(1)!,
];
