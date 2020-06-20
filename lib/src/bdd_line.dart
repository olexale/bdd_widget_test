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
  scenario,
  step,
  unknown,
}

LineType _lineTypeFromString(String line) {
  if (featureMarkers.any((marker) => line.startsWith(marker))) {
    return LineType.feature;
  }
  if (scenarioMarkers.any((marker) => line.startsWith(marker))) {
    return LineType.scenario;
  }
  if (stepMarkers.any((marker) => line.startsWith(marker))) {
    return LineType.step;
  }
  return LineType.unknown;
}

const featureMarkers = ['Feature:'];
const scenarioMarkers = ['Scenario:'];
const stepMarkers = ['Given', 'When', 'Then', 'And', 'Or'];

String _removeLinePrefix(String rawLine) {
  final lines = rawLine.split(' ');
  return lines.skip(1).join(' ');
}
