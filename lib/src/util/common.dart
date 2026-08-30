import 'package:collection/collection.dart';

/// [escapeDartLiteral] escapes text taken verbatim from a feature file - a
/// feature, rule or scenario title - before it is written into a Dart `'''`
/// string literal.
///
/// An unescaped `$` opens an interpolation, so `Feature: Price is $100` emits
/// `group('''Price is $100''')`, where Dart reads `$1`; an unescaped run of
/// three quotes closes the literal. Both leave the generated file
/// uncompilable, and the `FormatterException` then names lines of a file the
/// user never wrote rather than the `.feature` file that caused it.
///
/// Apostrophes are escaped only where they could reach a delimiter, so an
/// ordinary `Test's scenario` - and the `eating (12, '5')` title an outline
/// builds out of its `Examples:` cells - stays readable in generated code.
///
/// Use [escapeDartSingleQuoted] for `'...'` literals, such as the tag lists.
String escapeDartLiteral(String input) => _escape(input, always: false);

/// [escapeDartSingleQuoted] is [escapeDartLiteral] for a `'...'` literal, where
/// *any* apostrophe ends the literal instead of merely one that could merge
/// into a delimiter.
String escapeDartSingleQuoted(String input) => _escape(input, always: true);

String _escape(String input, {required bool always}) {
  var result = input.replaceAll(r'\', r'\\').replaceAll(r'$', r'\$');
  if (always || _strayQuote.hasMatch(result)) {
    result = result.replaceAll("'", r"\'");
  }
  return result;
}

/// A quote threatens a `'''` literal only when it can merge into a delimiter:
/// in a run of two or more, or as the last character, where it runs into the
/// closing `'''`. A leading quote is safe: `''''x'''` still reads as the
/// opening `'''` followed by the content `'x`.
final _strayQuote = RegExp(r"''|'$");

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
