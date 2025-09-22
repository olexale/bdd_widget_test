class BddLine {
  BddLine(this.rawLine)
    : type = _lineTypeFromString(rawLine),
      value = _removeLinePrefix(rawLine);

  BddLine.fromValue(this.type, this.value) : rawLine = '';
  BddLine.fromRawValue(this.type, this.rawLine)
    : value = _removeLinePrefix(rawLine);

  final String rawLine;
  final String value;
  final LineType type;
}

enum LineType {
  feature,
  background,
  tag,
  scenario,
  scenarioOutline,
  step,
  dataTableStep,
  after,
  examples,
  exampleTitle,
  unknown,
}

LineType _lineTypeFromString(String line) {
  if (featureMarkers.any((marker) => line.startsWith(marker))) {
    return LineType.feature;
  }
  if (backgroundMarkers.any((marker) => line.startsWith(marker))) {
    return LineType.background;
  }
  if (afterMarkers.any((marker) => line.startsWith(marker))) {
    return LineType.after;
  }
  if (scenarioMarkers.any((marker) => line.startsWith(marker))) {
    return LineType.scenario;
  }
  if (scenarioOutlineMarkers.any((marker) => line.startsWith(marker))) {
    return LineType.scenarioOutline;
  }
  if (stepMarkers.any((marker) => line.startsWith(marker))) {
    return LineType.step;
  }
  if (examplesMarkers.any((marker) => line.startsWith(marker))) {
    return LineType.examples;
  }
  if (examplesTitleMarkers.any((marker) => line.startsWith(marker))) {
    return LineType.exampleTitle;
  }
  if (tagMarkers.any((marker) => line.startsWith(marker))) {
    return LineType.tag;
  }
  return LineType.unknown;
}

const featureMarkers = ['Feature:'];
const backgroundMarkers = ['Background:'];
const afterMarkers = ['After:'];
const tagMarkers = ['@'];
const scenarioMarkers = ['Scenario:', 'Example:'];
const scenarioOutlineMarkers = ['Scenario Outline:'];
const stepMarkers = ['Given', 'When', 'Then', 'And', 'But'];
const examplesMarkers = ['|'];
const examplesTitleMarkers = ['Examples:', 'Scenarios:'];

String _removeLinePrefix(String rawLine) {
  final lines = rawLine.split(' ');
  return lines.skip(1).join(' ');
}
