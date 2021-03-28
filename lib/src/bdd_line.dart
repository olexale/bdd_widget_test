class BddLine {
  BddLine(this.rawLine)
      : type = _lineTypeFromString(rawLine),
        value = _removeLinePrefix(rawLine);

  final String rawLine;
  final String value;
  final LineType type;
}

enum LineType {
  feature,
  background,
  tag,
  scenario,
  step,
  after,
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
  if (stepMarkers.any((marker) => line.startsWith(marker))) {
    return LineType.step;
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
const stepMarkers = ['Given', 'When', 'Then', 'And', 'But'];

String _removeLinePrefix(String rawLine) {
  final lines = rawLine.split(' ');
  return lines.skip(1).join(' ');
}
