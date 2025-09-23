import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:collection/collection.dart';

/// [parseCustomTag] Returns custom tag value or empty string if not found.
/// Example: @testerTypeTag: PatrolTester returns `PatrolTester`
String parseCustomTag(String rawLine, String customTag) {
  if (rawLine.startsWith(customTag)) {
    return rawLine.substring(customTag.length).trim();
  }
  return '';
}

/// [parseCustomTagFromFeatureTagLine] returns tags of [customTag] from the feature tag lines
String parseCustomTagFromFeatureTagLine(
  List<BddLine> featureTagLines,
  String defaultTagValue,
  String customTag,
) {
  var tagType = defaultTagValue;

  final customTagLine = featureTagLines.firstWhereOrNull(
    (line) => line.rawLine.startsWith(customTag),
  );

  if (customTagLine != null) {
    final tagOverride = parseCustomTag(
      customTagLine.rawLine,
      customTag,
    );
    if (tagOverride.isNotEmpty) {
      tagType = tagOverride;
    }
  }
  return tagType;
}
