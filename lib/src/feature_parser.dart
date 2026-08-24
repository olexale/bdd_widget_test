import 'package:bdd_widget_test/src/data_table_parser.dart';
import 'package:bdd_widget_test/src/feature_model.dart';
import 'package:collection/collection.dart';
import 'package:cucumber_gherkin/cucumber_gherkin.dart';
// The dialect table is the parser's own keyword data. Duplicating it here
// would mean the pre-pass only understood English.
// ignore: implementation_imports
import 'package:cucumber_gherkin/src/language/dialects_builtin.g.dart';
// The keyword class the dialect table is built from.
// ignore: implementation_imports
import 'package:cucumber_gherkin/src/language/gherkin_language_keywords.dart';
import 'package:cucumber_messages/cucumber_messages.dart' as messages;

/// `After:` is a bdd_widget_test keyword, so unlike everything else the
/// pre-pass looks for, it is not translated.
const _afterMarker = 'After:';

/// Gherkin's own `# language: xx` header.
final _languagePattern = RegExp(r'^\s*#\s*language\s*:\s*([a-zA-Z\-_]+)\s*$');

/// The dialect the file declares, or English.
GherkinLanguageKeywords _dialectOf(List<String> source) {
  for (final line in source) {
    final match = _languagePattern.firstMatch(line);
    final dialect = match == null ? null : builtinDialects[match.group(1)];
    if (dialect != null) {
      return dialect;
    }
  }
  return builtinDialects['en']!;
}

/// `After:` is not a Gherkin keyword. It is rewritten into a scenario with
/// this reserved name so the official parser handles its steps (and their data
/// tables) natively, then mapped back into [Feature.after].
const _afterScenarioName = '__bdd_after__';

/// Parses [input] with the official Gherkin parser and maps the resulting AST
/// into the [FeatureFileModel] the generators consume.
///
/// A pre-pass keeps the package's non-standard extensions working: raw Dart
/// lines above `Feature:` are passed through, tags such as
/// `@testMethodName: foo` are normalised to a whitespace-free form, `After:`
/// blocks are rewritten, and files holding several features are parsed once
/// per feature. The pre-pass only ever replaces a line with another line of
/// its own, so reported error positions match the original file.
FeatureFileModel parseFeatureFile(String input, [String uri = 'feature']) {
  final source = input.split('\n').map((line) => line.trim()).toList();
  final dialect = _dialectOf(source);
  final featureMarkers = dialect.feature.map((keyword) => '$keyword:');
  final stepMarkers = [
    ...dialect.given,
    ...dialect.when,
    ...dialect.then,
    ...dialect.and,
    ...dialect.but,
  ];
  final featureLines = [
    for (var i = 0; i < source.length; i++)
      if (featureMarkers.any(source[i].startsWith)) i,
  ];
  // The language header sits above the first feature, so every chunk needs it.
  final languageLines = {
    for (var i = 0; i < source.length; i++)
      if (_languagePattern.hasMatch(source[i])) i,
  };

  // Raw Dart lines above the first feature are copied into the generated file
  // and hidden from the parser, which only allows comments and tags there.
  final headerEnd = featureLines.isEmpty ? source.length : featureLines.first;
  final headerIndices = {
    for (var i = 0; i < headerEnd; i++)
      if (!source[i].startsWith('@') && !source[i].startsWith('#')) i,
  };

  final tagLines = <String>[];
  final features = <Feature>[];

  final normalised = [
    for (var i = 0; i < source.length; i++)
      if (headerIndices.contains(i)) '' else _normalise(source[i]),
  ];

  final starts = _chunkStarts(source, featureLines);
  for (var i = 0; i < starts.length; i++) {
    final end = i + 1 < starts.length ? starts[i + 1] : source.length;
    final parsed = _parse(normalised, starts[i], end, languageLines, uri);
    if (parsed != null) {
      _rejectStepsInDescriptions(parsed, source, uri, stepMarkers);
      tagLines.addAll(_tagLines(parsed.tags, source));
      features.add(_toFeature(parsed, source));
    }
  }
  return FeatureFileModel(
    header: _headerLines(headerIndices.map((i) => source[i])),
    tagLines: tagLines,
    features: features,
  );
}

/// Where each feature's chunk begins. The first one owns everything above it,
/// so tags separated from `Feature:` by header lines still belong to it; later
/// ones start at the run of tag lines directly above their keyword.
List<int> _chunkStarts(List<String> source, List<int> featureLines) {
  final starts = <int>[];
  for (var i = 0; i < featureLines.length; i++) {
    var start = i == 0 ? 0 : featureLines[i];
    while (start > 0 && source[start - 1].startsWith('@')) {
      start--;
    }
    starts.add(start);
  }
  return starts;
}

/// Parses the lines in `[start, end)` as one feature.
///
/// Anything the Gherkin parser rejects is an error. The lexer this replaced
/// silently dropped every line it did not recognise, which turned a typo like
/// `Scenrio:` into a test file quietly missing a scenario.
messages.Feature? _parse(
  List<String> normalised,
  int start,
  int end,
  Set<int> keep,
  String uri,
) {
  final source = [
    for (var i = 0; i < normalised.length; i++)
      if ((i >= start && i < end) || keep.contains(i)) normalised[i] else '',
  ].join('\n');

  final envelopes = generateMessages(
    source,
    uri,
    const GherkinOptions(includeSource: false, includePickles: false),
  );
  final errors = envelopes
      .map((envelope) => envelope.parseError)
      .nonNulls
      .toList();
  if (errors.isNotEmpty) {
    throw FormatException(
      'Failed to parse $uri:\n'
      '${errors.map((error) => '  ${error.message}').join('\n')}',
    );
  }
  return envelopes
      .map((envelope) => envelope.gherkinDocument?.feature)
      .nonNulls
      .firstOrNull;
}

/// Gherkin lets a description block absorb every line that is not a keyword
/// line — steps included. So a mistyped `Scenrio:` parses cleanly and quietly
/// turns the steps under it into prose. A step inside a description is always
/// a mistake, so it is reported here rather than dropped.
void _rejectStepsInDescriptions(
  messages.Feature feature,
  List<String> source,
  String uri,
  List<String> stepMarkers,
) {
  for (final description in _descriptions(feature)) {
    for (final line in description.split('\n')) {
      final step = line.trim();
      if (!stepMarkers.any(step.startsWith)) {
        continue;
      }
      final index = source.indexOf(step);
      throw FormatException(
        'Failed to parse $uri:\n'
        '  ${index == -1 ? '' : '(${index + 1}:1): '}'
        "step '$step' is not part of a scenario — "
        'check the keyword above it',
      );
    }
  }
}

/// Every description block in the feature, rules and their children included.
Iterable<String> _descriptions(messages.Feature feature) sync* {
  yield feature.description;
  for (final child in feature.children) {
    yield child.background?.description ?? '';
    yield child.scenario?.description ?? '';
    final rule = child.rule;
    if (rule != null) {
      yield rule.description;
      for (final ruleChild in rule.children) {
        yield ruleChild.background?.description ?? '';
        yield ruleChild.scenario?.description ?? '';
      }
    }
  }
}

String _normalise(String line) {
  if (line.startsWith('@')) {
    // A tag may not contain whitespace, so `@testMethodName: testGoldens`
    // becomes `@testMethodName:testGoldens`. The original line is what ends up
    // in `BddLine.rawLine`, so this stays invisible to the generators.
    return line
        .split('@')
        .map((tag) => tag.replaceAll(RegExp(r'\s+'), ''))
        .where((tag) => tag.isNotEmpty)
        .map((tag) => '@$tag')
        .join(' ');
  }
  if (line.startsWith(_afterMarker)) {
    return 'Scenario: $_afterScenarioName';
  }
  return line;
}

/// Raw lines above the first feature, copied into the generated file verbatim.
/// Consecutive duplicates (blank lines, mostly) collapse into one.
List<String> _headerLines(Iterable<String> lines) {
  final headers = <String>[];
  for (final line in lines) {
    if (line.startsWith('@') || line.startsWith('#')) {
      continue;
    }
    // Drop leading blanks, and collapse runs of identical lines into one.
    if (headers.isEmpty ? line.isNotEmpty : headers.last != line) {
      headers.add(line);
    }
  }
  return headers;
}

Feature _toFeature(messages.Feature feature, List<String> source) {
  final children = feature.children;
  final rules = children.map((child) => child.rule).nonNulls.toList();
  return Feature(
    title: feature.name,
    background: _backgroundSteps(children.map((child) => child.background)),
    // `After:` applies to the whole feature wherever it was written, so a
    // block inside a rule is hoisted out of it.
    after: [
      ..._afterSteps(children.map((child) => child.scenario)),
      for (final rule in rules)
        ..._afterSteps(rule.children.map((child) => child.scenario)),
    ],
    scenarios: _scenarios(
      children.map((child) => child.scenario),
      const [],
      source,
    ),
    rules: [
      for (final rule in rules)
        Rule(
          title: rule.name,
          background: _backgroundSteps(
            rule.children.map((child) => child.background),
          ),
          // Gherkin hands a rule's tags down to the scenarios inside it.
          scenarios: _scenarios(
            rule.children.map((child) => child.scenario),
            _tagLines(rule.tags, source),
            source,
          ),
        ),
    ],
  );
}

List<Step> _backgroundSteps(Iterable<messages.Background?> backgrounds) => [
  for (final background in backgrounds.nonNulls)
    ...background.steps.map(_toStep),
];

List<Step> _afterSteps(Iterable<messages.Scenario?> scenarios) => [
  for (final scenario in scenarios.nonNulls.where(_isAfter))
    ...scenario.steps.map(_toStep),
];

List<Scenario> _scenarios(
  Iterable<messages.Scenario?> scenarios,
  List<String> inheritedTags,
  List<String> source,
) => [
  for (final scenario in scenarios.nonNulls.where((s) => !_isAfter(s)))
    Scenario(
      tagLines: [...inheritedTags, ..._tagLines(scenario.tags, source)],
      title: scenario.name,
      steps: scenario.steps.map(_toStep).toList(),
      examples: _examples(scenario.examples),
    ),
];

Step _toStep(messages.Step step) {
  final table = step.dataTable?.rows
      .map((row) => row.cells.map((cell) => cell.value).toList())
      .toList();
  return Step(
    step.text,
    table: table,
    // A table whose headers cover every `<placeholder>` in the step repeats the
    // step once per row; any other table is a Dart `DataTable` argument.
    isDataTable: table != null && !isExamplesTable(step.text, table),
  );
}

bool _isAfter(messages.Scenario scenario) =>
    scenario.name == _afterScenarioName;

/// Tags are collected one line at a time, not one tag at a time, because a
/// custom tag such as `@scenarioParams: skip: false` occupies a whole line.
List<String> _tagLines(List<messages.Tag> tags, List<String> source) {
  final seen = <int>{};
  return [
    for (final tag in tags)
      if (seen.add(tag.location.line)) source[tag.location.line - 1],
  ];
}

/// Zips each `Examples:` block's header row with its body rows. Blocks are
/// independent, so a scenario outline with two of them expands correctly.
List<Map<String, String>>? _examples(List<messages.Examples> examples) {
  if (examples.isEmpty) {
    return null;
  }
  return [
    for (final example in examples)
      if (example.tableHeader != null)
        for (final row in example.tableBody)
          Map.fromIterables(
            example.tableHeader!.cells.map((cell) => cell.value),
            row.cells.map((cell) => cell.value),
          ),
  ];
}
