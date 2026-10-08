import 'package:bdd_widget_test/src/data_table_parser.dart';
import 'package:bdd_widget_test/src/feature_model.dart';
import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:bdd_widget_test/src/util/constants.dart';
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

/// `After:` is a bdd_widget_test keyword of our own, so it has no dialect
/// equivalent and is looked for in this spelling in every language. What does
/// change with the dialect is the keyword it gets rewritten to — see
/// [_scenarioKeyword].
const _afterMarker = 'After:';

/// Gherkin's own `# language: xx` header.
final _languagePattern = RegExp(r'^\s*#\s*language\s*:\s*([a-zA-Z\-_]+)\s*$');

/// The dialect a file that declares none is read in.
final GherkinLanguageKeywords _english = builtinDialects['en']!;

/// The language the file declares, and the line it declares it on, or null
/// when it declares none. The code is whatever was written: resolving it to a
/// dialect is the caller's job, because a code no dialect answers to is a
/// mistake to report, not a dialect to use.
({int line, String code})? _declaredLanguage(List<String> source) {
  for (var i = 0; i < source.length; i++) {
    final code = _languagePattern.firstMatch(source[i])?.group(1);
    if (code != null) {
      return (line: i, code: code);
    }
  }
  return null;
}

/// The lines the file titles a feature with, in [dialect].
List<int> _featureLines(
  List<String> source,
  GherkinLanguageKeywords dialect,
) => [
  for (var i = 0; i < source.length; i++)
    if (dialect.feature.any((keyword) => source[i].startsWith('$keyword:'))) i,
];

/// The keyword `After:` is rewritten into. Gherkin matches a dialect's own
/// keywords and nothing else, so the English `Scenario:` would read as prose in
/// a French file, and the `After:` steps would be lost.
///
/// The keyword the file already titles its scenarios with is preferred, so the
/// substitute reads like the rest of the file; a file that writes no plain
/// scenario title (outlines only, or an `After:` block alone) gets the
/// dialect's first one, which parses just as well.
String _scenarioKeyword(
  List<String> source,
  GherkinLanguageKeywords dialect,
) {
  for (final keyword in dialect.scenario) {
    if (source.any((line) => line.startsWith('$keyword:'))) {
      return keyword;
    }
  }
  return dialect.scenario.first;
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
/// per feature — rewritten with the file's own scenario keyword, since Gherkin
/// accepts no other. The pre-pass only ever replaces a line with another line
/// of its own, and leaves indentation alone, so reported error positions match
/// the original file.
FeatureFileModel parseFeatureFile(String input, [String uri = 'feature']) {
  final raw = input.split('\n');
  // Keyword detection, header lines and tag lines all work off the trimmed
  // text; only the lines handed to the parser keep their original indentation.
  final source = raw.map((line) => line.trim()).toList();

  var dialect = _english;
  var featureLines = _featureLines(source, dialect);
  GherkinLanguageKeywords? ignoredDialect;
  final declared = _declaredLanguage(source);
  final declaredDialect = declared == null
      ? null
      : builtinDialects[declared.code];
  if (declared != null && declaredDialect != null) {
    dialect = declaredDialect;
    featureLines = _featureLines(source, dialect);
    // Gherkin honours a language declaration only above the first feature
    // keyword. Below it — in a description, say — it reads an ordinary comment
    // and stays in English, and so must this pre-pass: hunting for keywords in
    // a dialect nobody wrote the file in finds none, after which the whole file
    // reads as raw Dart sitting above the feature.
    if (featureLines.isEmpty || declared.line > featureLines.first) {
      ignoredDialect = dialect;
      dialect = _english;
      featureLines = _featureLines(source, dialect);
    }
  }

  // The honoured header sits above the first feature, so every chunk needs it.
  // A declaration this pre-pass dismissed is not carried: re-injected into a
  // later chunk it would land above that chunk's feature keyword, which is
  // exactly where Gherkin does honour one, and the chunk would fail to parse.
  final languageLines = {
    if (declaredDialect != null && ignoredDialect == null) declared!.line,
  };

  if (featureLines.isEmpty) {
    // A code no dialect answers to is Gherkin's error to report, and it does —
    // but only once a feature keyword has carried the file as far as the
    // parser. Without one it would be rejected for the missing feature, which
    // is not the mistake that was made.
    if (declared != null && declaredDialect == null) {
      throw FormatException(
        'Failed to parse $uri:\n'
        '  (${declared.line + 1}:'
        '${raw[declared.line].indexOf(source[declared.line]) + 1}): '
        'Language not supported: ${declared.code}',
      );
    }
    // No feature keyword means nothing was found to parse, and — unlike every
    // other mistake in the file — nothing was rejected either. The keyword
    // named is the one the file's own declaration asks for.
    final unchecked = _firstUncheckedLine(source);
    if (unchecked != null) {
      _rejectMissingFeature(
        source,
        raw,
        unchecked,
        ignoredDialect ?? dialect,
        uri,
      );
    }
  }

  final afterKeyword = _scenarioKeyword(source, dialect);
  final stepMarkers = [
    ..._stepKeywords(dialect),
    // A dialect the parser dismissed is still the dialect the lines under it
    // were written in, so their step spellings stay step-shaped to
    // [_rejectStepsInDescriptions]. Otherwise a scenario written in that
    // dialect lands in a description, and a group with no tests in it, quietly.
    if (ignoredDialect != null) ..._stepKeywords(ignoredDialect),
  ];

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
    for (var i = 0; i < raw.length; i++)
      if (headerIndices.contains(i)) '' else _normalise(raw[i], afterKeyword),
  ];

  final starts = _chunkStarts(source, featureLines);
  for (var i = 0; i < starts.length; i++) {
    final end = i + 1 < starts.length ? starts[i + 1] : source.length;
    final afterLines = _afterBlockLines(source, starts[i], end, dialect);
    final parsed = _parse(normalised, {
      for (var line = starts[i]; line < end; line++)
        if (!afterLines.contains(line)) line,
      ...languageLines,
    }, uri);
    // The `After:` blocks are parsed on their own, under the feature's
    // keyword line, so that a `Background:` written below one is not a
    // background following a scenario — which Gherkin rejects, and which the
    // block, rewritten into a scenario, would otherwise be.
    final after = afterLines.isEmpty
        ? null
        : _parse(normalised, {
            featureLines[i],
            ...afterLines,
            ...languageLines,
          }, uri);
    if (parsed != null) {
      final afterHasSteps = after != null && _hasSteps(after.children);
      for (final feature in [parsed, ?after]) {
        _rejectStepsInDescriptions(
          feature,
          source,
          raw,
          uri,
          stepMarkers,
          afterHasSteps: afterHasSteps,
        );
        _rejectUnnamedSteps(feature, uri);
      }
      tagLines.addAll(_tagLines(parsed.tags, source));
      features.add(_toFeature(parsed, after, source, raw));
    }
  }
  return FeatureFileModel(
    header: _headerLines(headerIndices.map((i) => source[i])),
    tagLines: _unique(tagLines),
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

/// Parses the [lines] of [normalised] as one feature. Every other line is
/// blanked rather than dropped, so positions the parser reports are positions
/// in the file.
///
/// Anything the Gherkin parser rejects is an error. The lexer this replaced
/// silently dropped every line it did not recognise, which turned a typo like
/// `Scenrio:` into a test file quietly missing a scenario.
messages.Feature? _parse(
  List<String> normalised,
  Set<int> lines,
  String uri,
) {
  final source = [
    for (var i = 0; i < normalised.length; i++)
      if (lines.contains(i)) normalised[i] else '',
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

/// The lines in `[start, end)` that make up `After:` blocks: each `After:` line
/// and what follows it, up to the next line that opens something else — a
/// feature, rule, background or scenario keyword, a tag, or another `After:`.
/// Inside a doc string nothing opens anything, so a `@` or a `Scenario:` there
/// is still the block's.
///
/// The tag lines directly above an `After:` are the block's too. Gherkin
/// attaches tags to the keyword below them, so left in the main parse they
/// would land on whatever follows the blanked block — the next scenario, which
/// a `@scenarioParams: skip: true` meant for the teardown would then skip — or,
/// with nothing below, be a tag with no keyword to attach to, which Gherkin
/// rejects.
Set<int> _afterBlockLines(
  List<String> source,
  int start,
  int end,
  GherkinLanguageKeywords dialect,
) {
  final openers = [
    for (final keyword in [
      ...dialect.feature,
      ...dialect.rule,
      ...dialect.background,
      ...dialect.scenario,
      ...dialect.scenarioOutline,
    ])
      '$keyword:',
    '@',
    _afterMarker,
  ];
  final lines = <int>{};
  final tags = <int>[];
  var inBlock = false;
  String? docString;
  for (var i = start; i < end; i++) {
    final line = source[i];
    if (docString == null && openers.any(line.startsWith)) {
      inBlock = line.startsWith(_afterMarker);
      if (line.startsWith('@')) {
        tags.add(i);
        continue;
      }
      if (inBlock) {
        lines.addAll(tags);
      }
      tags.clear();
    } else if (docString == null && _docStringFences.any(line.startsWith)) {
      docString = line.substring(0, 3);
    } else if (docString != null && line.startsWith(docString)) {
      docString = null;
    }
    if (inBlock) {
      lines.add(i);
    }
  }
  return lines;
}

/// The two delimiters Gherkin opens and closes a doc string with.
const List<String> _docStringFences = ['"""', '```'];

/// The keywords a dialect spells a step with.
List<String> _stepKeywords(GherkinLanguageKeywords dialect) => [
  ...dialect.given,
  ...dialect.when,
  ...dialect.then,
  ...dialect.and,
  ...dialect.but,
];

/// The first line of a file with no feature keyword that would be copied out
/// as Dart, or null when there is none.
///
/// A `#` comment, a tag line or a blank is what Gherkin allows above
/// `Feature:`, so a file holding nothing but those declares nothing and is left
/// alone. `//` is Dart, and Dart sitting over a feature that never arrived is a
/// commented-out feature: a green run, testing nothing.
int? _firstUncheckedLine(List<String> source) {
  for (var i = 0; i < source.length; i++) {
    final line = source[i];
    if (line.isNotEmpty && !line.startsWith('#') && !line.startsWith('@')) {
      return i;
    }
  }
  return null;
}

/// Rejects a file that holds text but names no feature.
///
/// Without a feature keyword there is nothing for the parser to chew on, and
/// the region above the first feature — the only region that goes unchecked —
/// is the whole file. Every line of it lands in the generated Dart, so a
/// `Featur:` typo or a dropped `Feature:` line leaves either a
/// `FormatterException` quoting Dart line numbers, or, when the lines happen to
/// read as Dart, a `main()` holding no tests at all. Both pass unnoticed, which
/// is the hole this closes.
Never _rejectMissingFeature(
  List<String> source,
  List<String> raw,
  int index,
  GherkinLanguageKeywords dialect,
  String uri,
) {
  final line = source[index];
  throw FormatException(
    'Failed to parse $uri:\n'
    '  (${index + 1}:${raw[index].indexOf(line) + 1}): '
    "the file holds no '${dialect.feature.first}:' keyword, so no feature "
    "was found and no tests would be generated. '$line' was read as Dart — "
    'check for a missing or mistyped feature keyword',
  );
}

/// Gherkin lets a description block absorb every line that is not a keyword
/// line — steps included. So a mistyped `Scenrio:` parses cleanly and quietly
/// turns the steps under it into prose.
///
/// The parser cannot tell that prose apart from a real orphaned step: a bullet
/// like `* adds a counter` is legitimate Gherkin in a description, and the same
/// spelling is a symptom of a mistyped keyword one line later. What it can tell
/// is the consequence — steps that were swallowed by a description leave the
/// block they were meant for with no steps at all, and that is the case where a
/// test file gets built running less than it looks like. So only step-looking
/// lines in a block that ends up step-less are reported; a block with steps of
/// its own keeps its prose, however keyword-shaped a line of it looks.
///
/// The residual false positive is a step-less block whose description reads
/// like steps. Such a block generates a test that asserts nothing — or, for a
/// feature, a group with no tests in it — which is the failure this check
/// exists to catch. The matching blind spot is a mistyped `Background:`
/// (`Backround:`, say) in a feature that has steps elsewhere: those steps are
/// still lost, but the block has steps and the lines read as prose. The test
/// then fails on the missing step rather than the build failing on the typo.
///
/// A step keyword written with a colon — `Given: the app is running` — is the
/// exception to the exception. Prose under a scenario or a background has no
/// reason to read like that, so there it is reported even when the block has
/// steps: it is a step Gherkin does not recognise, sitting above the ones it
/// does, and would otherwise be dropped from a test that still runs the rest.
/// A feature or rule description is free text above everything, and keeps it.
void _rejectStepsInDescriptions(
  messages.Feature feature,
  List<String> source,
  List<String> raw,
  String uri,
  List<String> stepMarkers, {
  required bool afterHasSteps,
}) {
  for (final description in _descriptions(feature, afterHasSteps)) {
    for (final line in description.text.split('\n')) {
      final step = line.trim();
      final colon = _colonKeyword(step, stepMarkers);
      if (colon == null && !stepMarkers.any(step.startsWith)) {
        continue;
      }
      if (description.hasSteps && (colon == null || !description.holdsSteps)) {
        continue;
      }
      // A description starts on the line after the keyword that owns it, so
      // the search starts there. Searching the whole file would report an
      // identical step written earlier — a legitimate one, in a scenario that
      // parsed fine.
      final index = source.indexOf(step, description.keywordLine);
      final column = index == -1 ? 0 : raw[index].indexOf(step) + 1;
      final problem = colon == null
          ? 'is not part of a scenario — check the keyword above it'
          : 'is not read as a step — a step keyword takes no colon, so write '
                "'$colon${step.substring(colon.trimRight().length + 1).trimLeft()}'";
      throw FormatException(
        'Failed to parse $uri:\n'
        '  ${index == -1 ? '' : '(${index + 1}:$column): '}'
        "step '$step' $problem",
      );
    }
  }
}

/// The step keyword [step] opens with when it is written with a colon, the
/// way `Feature:` and `Scenario:` are — `Given: the app is running` — or null
/// when it is not. Gherkin's step keywords take no colon, so such a line is
/// not a step to it: under a scenario it reads as description, and the
/// scenario runs nothing at all.
String? _colonKeyword(String step, List<String> stepMarkers) =>
    stepMarkers.firstWhereOrNull(
      (keyword) =>
          keyword.endsWith(' ') && step.startsWith('${keyword.trimRight()}:'),
    );

/// Rejects a step whose text names nothing a generated file can be built
/// around.
///
/// Step text becomes a Dart identifier by dropping everything that is not an
/// ASCII word character, so a step written in another script leaves no name
/// behind: `Given アプリが起動している` generated `import './step/.dart';` and an
/// `await (tester);` sitting in nothing, two files that do not compile. The
/// keywords localise — that is the dialect table working — only this one mapping
/// from step text to identifier has never been able to leave ASCII, so the file
/// reads perfectly right up to the line that breaks the build.
///
/// Renaming the step is the advice, and the position comes free: unlike a
/// description, the parser reports a location for every step.
void _rejectUnnamedSteps(messages.Feature feature, String uri) {
  for (final step in _allSteps(feature)) {
    if (stepIdentifier(step.text) != null) {
      continue;
    }
    throw FormatException(
      'Failed to parse $uri:\n'
      '  (${step.location.line}:${step.location.column}): '
      '${unnamedStepError(step.text)}',
    );
  }
}

/// Every step of the feature, wherever it was written: backgrounds, scenarios,
/// the `After:` block (a scenario under its reserved name), and everything
/// inside the rules. An outline yields its steps once, not once per row.
Iterable<messages.Step> _allSteps(messages.Feature feature) sync* {
  for (final child in feature.children) {
    yield* child.background?.steps ?? const <messages.Step>[];
    yield* child.scenario?.steps ?? const <messages.Step>[];
    final rule = child.rule;
    if (rule != null) {
      for (final ruleChild in rule.children) {
        yield* ruleChild.background?.steps ?? const <messages.Step>[];
        yield* ruleChild.scenario?.steps ?? const <messages.Step>[];
      }
    }
  }
}

/// Every description block in the feature, rules and their children included,
/// each paired with the 1-based line of the keyword it hangs off and whether
/// the block it belongs to has any steps. The line is what makes a
/// description's position in the file recoverable — the parser reports a
/// location for every keyword, but not for the description text.
typedef _Description = ({
  String text,
  int keywordLine,
  bool hasSteps,
  // Whether steps are written directly under the keyword — a scenario or a
  // background — rather than under blocks nested in it, as for a feature or a
  // rule.
  bool holdsSteps,
});

Iterable<_Description> _descriptions(
  messages.Feature feature,
  bool afterHasSteps,
) sync* {
  yield (
    text: feature.description,
    keywordLine: feature.location.line,
    // `After:` blocks are parsed apart from the feature, so their steps are
    // not among its children, but they are steps of the feature all the same.
    hasSteps: afterHasSteps || _hasSteps(feature.children),
    holdsSteps: false,
  );
  for (final child in feature.children) {
    final background = child.background;
    if (background != null) {
      yield (
        text: background.description,
        keywordLine: background.location.line,
        hasSteps: background.steps.isNotEmpty,
        holdsSteps: true,
      );
    }
    final scenario = child.scenario;
    if (scenario != null) {
      yield (
        text: scenario.description,
        keywordLine: scenario.location.line,
        hasSteps: scenario.steps.isNotEmpty,
        holdsSteps: true,
      );
    }
    final rule = child.rule;
    if (rule != null) {
      yield (
        text: rule.description,
        keywordLine: rule.location.line,
        hasSteps: _ruleHasSteps(rule),
        holdsSteps: false,
      );
      for (final ruleChild in rule.children) {
        final ruleBackground = ruleChild.background;
        if (ruleBackground != null) {
          yield (
            text: ruleBackground.description,
            keywordLine: ruleBackground.location.line,
            hasSteps: ruleBackground.steps.isNotEmpty,
            holdsSteps: true,
          );
        }
        final ruleScenario = ruleChild.scenario;
        if (ruleScenario != null) {
          yield (
            text: ruleScenario.description,
            keywordLine: ruleScenario.location.line,
            hasSteps: ruleScenario.steps.isNotEmpty,
            holdsSteps: true,
          );
        }
      }
    }
  }
}

/// Whether any scenario or background under these feature children has a step,
/// rules included. A feature whose steps all ended up in a description has
/// none, which is what makes those steps worth reporting.
bool _hasSteps(Iterable<messages.FeatureChild> children) {
  for (final child in children) {
    if ((child.background?.steps.isNotEmpty ?? false) ||
        (child.scenario?.steps.isNotEmpty ?? false)) {
      return true;
    }
    final rule = child.rule;
    if (rule != null && _ruleHasSteps(rule)) {
      return true;
    }
  }
  return false;
}

/// The same for one rule. Gherkin nests rules no deeper than this, so there is
/// nothing below a rule's own children to walk into.
bool _ruleHasSteps(messages.Rule rule) => rule.children.any(
  (child) =>
      (child.background?.steps.isNotEmpty ?? false) ||
      (child.scenario?.steps.isNotEmpty ?? false),
);

/// Rewrites one line into something the official parser accepts. Leading
/// whitespace is preserved so error positions still point at the original
/// column.
String _normalise(String line, String afterKeyword) {
  final trimmed = line.trim();
  final indent = line.substring(0, line.length - line.trimLeft().length);
  if (trimmed.startsWith('@')) {
    // A tag may not contain whitespace, so `@testMethodName: goldenTest`
    // becomes `@testMethodName:goldenTest`. Ordinary tags are reported back to
    // the generators in this form; the custom ones the rewrite is named after
    // are not, and [_tagLines] reads those out of the untouched source.
    final tags = trimmed
        .split('@')
        .map((tag) => tag.replaceAll(RegExp(r'\s+'), ''))
        .where((tag) => tag.isNotEmpty)
        .map((tag) => '@$tag')
        .join(' ');
    return '$indent$tags';
  }
  if (trimmed.startsWith(_afterMarker)) {
    return '$indent$afterKeyword: $_afterScenarioName';
  }
  return line;
}

/// Raw lines above the first feature, copied into the generated file verbatim.
/// Leading blanks are dropped and runs of blanks collapse into one, so a
/// feature file may separate its header lines from `Feature:` by any number of
/// blank lines. Non-blank lines are never dropped or merged: they are raw Dart,
/// and Dart lines repeat all the time (`}` closing nested blocks, `});` closing
/// nested callbacks), so collapsing identical lines would emit broken code.
List<String> _headerLines(Iterable<String> lines) {
  final headers = <String>[];
  for (final line in lines) {
    if (line.startsWith('@') || line.startsWith('#')) {
      continue;
    }
    if (line.isEmpty) {
      // Keep at most one blank, and never a leading one.
      if (headers.isNotEmpty && headers.last.isNotEmpty) {
        headers.add(line);
      }
    } else {
      headers.add(line);
    }
  }
  return headers;
}

/// Maps the parsed [feature] into the model. [after] is the parse of the
/// feature's `After:` blocks alone — see [_afterBlockLines] — or null when it
/// has none. [raw] is the file as written, which table cells are read back out
/// of; see [_cellText].
Feature _toFeature(
  messages.Feature feature,
  messages.Feature? after,
  List<String> source,
  List<String> raw,
) {
  final children = feature.children;
  final rules = children.map((child) => child.rule).nonNulls.toList();
  return Feature(
    title: feature.name,
    background: _backgroundSteps(
      children.map((child) => child.background),
      raw,
    ),
    // `After:` applies to the whole feature wherever it was written, so a
    // block inside a rule is hoisted out of it — which the separate parse does
    // by itself, since it holds no `Rule:` line to nest the block under.
    after: [
      for (final scenario in (after?.children ?? const []).map(
        (child) => child.scenario,
      ))
        ...?scenario?.steps.map((step) => _toStep(step, raw)),
    ],
    scenarios: _scenarios(
      children.map((child) => child.scenario),
      const [],
      source,
      raw,
    ),
    rules: [
      for (final rule in rules)
        Rule(
          title: rule.name,
          background: _backgroundSteps(
            rule.children.map((child) => child.background),
            raw,
          ),
          // Gherkin hands a rule's tags down to the scenarios inside it.
          scenarios: _scenarios(
            rule.children.map((child) => child.scenario),
            _tagLines(rule.tags, source),
            source,
            raw,
          ),
        ),
    ],
  );
}

List<Step> _backgroundSteps(
  Iterable<messages.Background?> backgrounds,
  List<String> raw,
) => [
  for (final background in backgrounds.nonNulls)
    ...background.steps.map((step) => _toStep(step, raw)),
];

List<Scenario> _scenarios(
  Iterable<messages.Scenario?> scenarios,
  List<String> inheritedTags,
  List<String> source,
  List<String> raw,
) => [
  for (final scenario in scenarios.nonNulls)
    Scenario(
      // A tag written on both the rule and the scenario reaches this point
      // twice — once inherited, once parsed — and would be generated twice.
      tagLines: _unique([
        ...inheritedTags,
        ..._tagLines(scenario.tags, source),
      ]),
      title: scenario.name,
      steps: scenario.steps.map((step) => _toStep(step, raw)).toList(),
      examples: _examples(scenario.examples, raw),
    ),
];

Step _toStep(messages.Step step, List<String> raw) {
  final table = step.dataTable?.rows
      .map((row) => row.cells.map((cell) => _cellText(cell, raw)).toList())
      .toList();
  return Step(
    step.text,
    table: table,
    // A table whose headers cover every `<placeholder>` in the step repeats the
    // step once per row; any other table is a Dart `DataTable` argument.
    isDataTable: table != null && !isExamplesTable(step.text, table),
  );
}

/// A table cell's text as it was written, with only `\|` unescaped.
///
/// Gherkin unescapes cells: `\n` becomes a line break, `\\` a single
/// backslash, `\|` a pipe. A cell here holds Dart, though, where `\n` and
/// `\\` are escapes of Dart's own, so the unescaped value is the wrong text
/// to generate: `"a\nb"` came out as a string literal broken over two lines,
/// which does not compile, and `'C:\\temp'` as `'C:\temp'`, which compiles to
/// a tab. Nor can the value be escaped back — Gherkin keeps a backslash it has
/// no escape for, so `\t` and `\\t` both arrive as `\t`. So the cell is read
/// back from the line at the position the parser reports for it. Only the
/// pipe stays unescaped, because a bare one would end the cell.
///
/// The column counts runes, not UTF-16 code units — an emoji earlier on the
/// line moves it by one, not two — and the trailing whitespace is the same the
/// parser trims.
String _cellText(messages.TableCell cell, List<String> raw) {
  final line = raw[cell.location.line - 1].runes.toList();
  final text = StringBuffer();
  for (var i = cell.location.column! - 1; i < line.length; i++) {
    final char = String.fromCharCode(line[i]);
    if (char == '|') {
      break;
    }
    if (char == r'\' && i + 1 < line.length) {
      final next = String.fromCharCode(line[++i]);
      text.write(next == '|' ? next : '$char$next');
    } else {
      text.write(char);
    }
  }
  return text.toString().replaceAll(_trailingCellWhitespace, '');
}

/// The whitespace Gherkin trims off the end of a table cell.
final RegExp _trailingCellWhitespace = RegExp(r'[ \t\x0B\f\r\x85\xA0]+$');

/// Tags, one entry per tag rather than one per line.
///
/// Gherkin allows several tags on a line and reports each of them separately,
/// so the split need not be re-derived from the text: `tag.name` is still the
/// tag as written, `@` and all, which is what the generators cut out of it.
///
/// Repeats are dropped, the first one winning, so a tag named twice for the
/// same scenario — a `Rule:` tag and the same tag on a scenario inside it — is
/// still written out once.
List<String> _tagLines(List<messages.Tag> tags, List<String> source) {
  // Whether a line can be taken tag by tag is a question about the whole line,
  // so its tags are grouped before they are read.
  final byLine = <int, List<messages.Tag>>{};
  for (final tag in tags) {
    byLine.putIfAbsent(tag.location.line, () => []).add(tag);
  }
  return _unique([
    for (final entry in byLine.entries)
      ..._lineTags(entry.value, source[entry.key - 1]),
  ]);
}

/// The tags the parser found as [tags] were written on [line].
///
/// The package's own tags — `@scenarioParams: skip: false`, `@testerName: $` —
/// are the reason a line cannot always be taken tag by tag. Their value holds
/// whitespace, which [_normalise] has squeezed out of the name the parser
/// reports, leaving `@scenarioParams:skip:false`, which is no longer the form
/// the generators read. From such a tag to the end of the line the text is one
/// value as far as this package is concerned, so it is handed over untouched.
/// What stands before it was read as ordinary tags by Gherkin and is emitted one
/// by one — which is what a line like `@smoke @testMethodName: goldenTest`,
/// whose `@smoke` used to be lost along with the line it sat on, needs.
///
/// What a custom tag swallows after its value — a second custom tag, or a plain
/// tag — goes with it, as it always has: an `@` inside a value, as in
/// `@scenarioParams: tags: ['a@b.com']`, is indistinguishable from a tag, and
/// the value wins.
List<String> _lineTags(List<messages.Tag> tags, String line) {
  final custom = _customTagStart(line);
  if (custom == null) {
    return tags.map((tag) => tag.name).toList();
  }
  return [
    for (final tag in tags.takeWhile((tag) => !_isCustomTag(tag.name)))
      tag.name,
    line.substring(custom),
  ];
}

/// The package's tags, spelled `@name: value` rather than as a Gherkin tag, so
/// that the name the parser reports has their value's whitespace flattened out.
const List<String> _customTags = [
  testMethodNameTag,
  testerTypeTag,
  testerNameTag,
  scenarioParamsTag,
];

/// Whether [name], as the parser reports it, is one of [_customTags] — and so
/// one whose value is no longer readable from the name.
bool _isCustomTag(String name) => _customTags.any(name.startsWith);

/// Where the first of [_customTags] begins in [line], or null when the line
/// holds none. A tag begins the line or follows whitespace, so one mentioned
/// inside another tag's value — `@scenarioParams: name: '@testerType: x'` —
/// stays part of that value.
int? _customTagStart(String line) {
  var start = line.length;
  for (final tag in _customTags) {
    for (var at = line.indexOf(tag); at >= 0; at = line.indexOf(tag, at + 1)) {
      if (at > 0 && !_whitespace.hasMatch(line[at - 1])) {
        continue;
      }
      if (at < start) {
        start = at;
      }
      break;
    }
  }
  return start == line.length ? null : start;
}

final RegExp _whitespace = RegExp(r'\s');

/// [values] without repeats, in the order they were first seen.
List<String> _unique(Iterable<String> values) => values.toSet().toList();

/// Zips each `Examples:` block's header row with its body rows. Blocks are
/// independent, so a scenario outline with two of them expands correctly.
List<Map<String, String>>? _examples(
  List<messages.Examples> examples,
  List<String> raw,
) {
  if (examples.isEmpty) {
    return null;
  }
  return [
    for (final example in examples)
      if (example.tableHeader != null)
        for (final row in example.tableBody)
          Map.fromIterables(
            example.tableHeader!.cells.map((cell) => _cellText(cell, raw)),
            row.cells.map((cell) => _cellText(cell, raw)),
          ),
  ];
}
