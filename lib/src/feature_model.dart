/// The parsed contents of a `.feature` file.
class FeatureFileModel {
  const FeatureFileModel({
    required this.header,
    required this.tagLines,
    required this.features,
  });

  /// Raw Dart lines written above the first `Feature:`, copied through to the
  /// generated file untouched.
  final List<String> header;

  /// Tags written above a `Feature:` keyword, gathered across every feature in
  /// the file — one entry per tag, e.g. `@integration`. The package's own
  /// `@name: value` tags stand for their whole line and are kept as written,
  /// e.g. `@testMethodName: foo`.
  final List<String> tagLines;

  final List<Feature> features;

  bool get hasDataTable => allSteps.any((step) => step.isDataTable);

  Iterable<Step> get allSteps => features.expand((feature) => feature.allSteps);

  /// Every tag line in the file: the file-level ones plus each scenario's,
  /// rules included.
  Iterable<String> get allTagLines => [
    ...tagLines,
    ...features.expand((feature) => feature.allTagLines),
  ];
}

class Feature {
  const Feature({
    required this.title,
    required this.background,
    required this.after,
    required this.scenarios,
    required this.rules,
  });

  final String title;

  /// Steps of the `Background:` section, run before each scenario — including
  /// the scenarios inside [rules].
  final List<Step> background;

  /// Steps of the `After:` section, run after each scenario even on failure.
  final List<Step> after;

  /// Scenarios written directly under the feature, outside any rule.
  final List<Scenario> scenarios;

  final List<Rule> rules;

  Iterable<Step> get allSteps => [
    ...background,
    ...after,
    ...scenarios.expand((scenario) => scenario.steps),
    ...rules.expand((rule) => rule.allSteps),
  ];

  Iterable<String> get allTagLines => [
    ...scenarios.expand((scenario) => scenario.tagLines),
    ...rules.expand(
      (rule) => rule.scenarios.expand((scenario) => scenario.tagLines),
    ),
  ];
}

/// A `Rule:` — a group of scenarios inside a feature, with a background of its
/// own that applies only to them.
class Rule {
  const Rule({
    required this.title,
    required this.background,
    required this.scenarios,
  });

  final String title;
  final List<Step> background;
  final List<Scenario> scenarios;

  Iterable<Step> get allSteps => [
    ...background,
    ...scenarios.expand((scenario) => scenario.steps),
  ];
}

class Scenario {
  const Scenario({
    required this.tagLines,
    required this.title,
    required this.steps,
    this.examples,
  });

  /// The tags written above this scenario, plus those of the `Rule:` it sits
  /// in, each once. As in [FeatureFileModel.tagLines], a `@name: value` tag
  /// carries the line it was written on.
  final List<String> tagLines;
  final String title;
  final List<Step> steps;

  /// One set of placeholder values per row of the `Examples:` section, in
  /// source order. Non-null exactly when this is a `Scenario Outline:`.
  final List<Map<String, String>>? examples;

  bool get isOutline => examples != null;
}

class Step {
  const Step(this.text, {this.table, this.isDataTable = false});

  /// The step without its keyword, parameters left in place.
  final String text;

  /// Rows of the table written under the step, header row first.
  final List<List<String>>? table;

  /// Whether [table] is a Dart `DataTable` argument rather than an inline
  /// `Examples:` table that repeats the step once per row.
  final bool isDataTable;
}
