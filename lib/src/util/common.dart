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
String escapeDartLiteral(String input) => _strayQuote.hasMatch(input)
    ? escapeDartSingleQuoted(input)
    : input.replaceAll(r'\', r'\\').replaceAll(r'$', r'\$');

/// [escapeDartSingleQuoted] is [escapeDartLiteral] for a `'...'` literal, where
/// *any* apostrophe ends the literal instead of merely one that could merge
/// into a delimiter.
String escapeDartSingleQuoted(String input) => escapeDartString(input, "'");

/// [input] as the text of a Dart string delimited by [quote] — `'`, `"`,
/// `'''` or `"""` — with every character that string would read as Dart
/// (`\`, `$` and the quote) escaped.
String escapeDartString(String input, String quote) => input
    .replaceAll(r'\', r'\\')
    .replaceAll(r'$', r'\$')
    .replaceAll(quote[0], '\\${quote[0]}');

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
