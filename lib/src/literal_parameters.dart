import 'package:bdd_widget_test/src/regex.dart';
import 'package:bdd_widget_test/src/util/common.dart';
import 'package:bdd_widget_test/src/util/dart_block.dart';

/// [stepText] with every `"quoted string"` and whole-word number written as a
/// `{}` parameter, which is the only parameter syntax the rest of the
/// generator knows. `Then I see "Hello" text` becomes
/// `Then I see {'Hello'} text`, and `Given the counter is 42` becomes
/// `Given the counter is {42}`.
///
/// Left as written:
/// * `{}` blocks, read by [readDartBlock]: a `"` inside one is not a
///   delimiter (`I see {get("a")} text`), and a brace inside a string in one
///   does not end it. A block nothing closes runs to the end of the line;
/// * `<placeholder>`s outside quotes, so `<item1>` keeps its digit. Inside
///   quotes they stay too, and the outline puts its value there later;
/// * apostrophes: only `"` opens a string, so `I don't see "Hello" text` is
///   still `iDontSeeText`.
///
/// A quoted token is text, not Dart. It knows two escapes, `\"` and `\\`; any
/// other backslash is kept as a backslash. The decoded text is re-encoded as a
/// single-quoted Dart literal, so `$` and `\` in it compile to themselves.
/// `{` and `}` need nothing: the step is split by [readDartBlock], which knows
/// that a brace inside a string is text.
///
/// Returns null when a `"` has nothing to close it: read as prose it would
/// silently rename the step, so the parser reports it.
String? rewriteLiteralParameters(
  String stepText,
) {
  final result = StringBuffer();
  var i = 0;

  while (i < stepText.length) {
    final c = stepText[i];
    if (c == '{') {
      final end = readDartBlock(stepText, i)?.end ?? stepText.length;
      result.write(stepText.substring(i, end));
      i = end;
      continue;
    }
    if (c == '"') {
      final token = _readQuoted(stepText, i);
      if (token == null) {
        return null;
      }
      result.write("{'${escapeDartSingleQuoted(token.value)}'}");
      i = token.end + 1;
      continue;
    }
    final placeholder = examplesRegExp.matchAsPrefix(stepText, i);
    if (placeholder != null) {
      result.write(placeholder.group(0));
      i = placeholder.end;
      continue;
    }
    final number = numberRegExp.matchAsPrefix(stepText, i);
    if (number != null) {
      result.write('{${number.group(0)}}');
      i = number.end;
      continue;
    }
    result.write(c);
    i++;
  }

  return result.toString();
}

/// The quoted token [line] opens at [start]: the index of the `"` closing it
/// and the text between the quotes, or null when no `"` closes it.
///
/// Without `\\` a string could not end in a backslash: `"C:\"` would read as
/// an escaped quote and never close.
({int end, String value})? _readQuoted(String line, int start) {
  final value = StringBuffer();
  for (var i = start + 1; i < line.length; i++) {
    final c = line[i];
    if (c == '"') {
      return (end: i, value: value.toString());
    }
    if (c == r'\' && i + 1 < line.length) {
      final next = line[i + 1];
      if (next == '"' || next == r'\') {
        value.write(next);
        i++;
        continue;
      }
    }
    value.write(c);
  }
  return null;
}
