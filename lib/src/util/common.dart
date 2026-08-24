import 'package:collection/collection.dart';

/// [parseCustomTag] Returns custom tag value or empty string if not found.
/// Example: @testerTypeTag: PatrolTester returns `PatrolTester`
String parseCustomTag(String rawLine, String customTag) {
  if (rawLine.startsWith(customTag)) {
    return rawLine.substring(customTag.length).trim();
  }
  return '';
}

/// [parseCustomTagValue] returns the value of [customTag] from [tagLines],
/// or [defaultTagValue] when no line carries that tag.
String parseCustomTagValue(
  Iterable<String> tagLines,
  String defaultTagValue,
  String customTag,
) {
  var tagType = defaultTagValue;

  final customTagLine = tagLines.firstWhereOrNull(
    (line) => line.startsWith(customTag),
  );

  if (customTagLine != null) {
    final tagOverride = parseCustomTag(
      customTagLine,
      customTag,
    );
    if (tagOverride.isNotEmpty) {
      tagType = tagOverride;
    }
  }
  return tagType;
}
