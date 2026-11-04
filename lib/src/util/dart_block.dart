/// The `{}` block opening at [open] in [text]: `end`, the index just past its
/// closing `}`, and `strings`, the text of every `'…'` and `"…"` inside it
/// (between the quotes), with the quote that delimits it.
///
/// A brace inside a string is text, so `{'a{b'}` is one block and `{'}'}`
/// does not end at its first `}`. In a string, `\` escapes the next
/// character. Nothing else of Dart is known: raw strings and `${}` read as
/// plain strings, which is all a one-line step parameter needs.
///
/// When a string in the block never closes (`{it's}`), its quotes cannot be
/// trusted, so the block is read by counting braces alone, with no `strings`.
/// Null when no `}` closes the block.
DartBlock? readDartBlock(String text, int open) {
  assert(text[open] == '{', 'no block opens at $open');
  final strings = <DartString>[];
  final end = _blockEnd(text, open, strings);
  if (end != null) {
    return (end: end, strings: strings);
  }
  final counted = _blockEnd(text, open, null);
  return counted == null ? null : (end: counted, strings: const []);
}

typedef DartBlock = ({int end, List<DartString> strings});

/// The text of a string literal, from `start` up to `end`, and its `quote`.
typedef DartString = ({int start, int end, String quote});

/// The index just past the `}` closing the block at [open], or null. With
/// [strings], quotes are read and each string is added to it; a string that
/// never closes returns null. Without, braces are only counted.
int? _blockEnd(String text, int open, List<DartString>? strings) {
  var depth = 0;
  var i = open;
  while (i < text.length) {
    final c = text[i];
    if (c == '{') {
      depth++;
    } else if (c == '}') {
      depth--;
      if (depth == 0) {
        return i + 1;
      }
    } else if (strings != null && (c == "'" || c == '"')) {
      final close = _stringClose(text, i);
      if (close == null) {
        return null;
      }
      strings.add((start: i + 1, end: close, quote: c));
      i = close;
    }
    i++;
  }
  return null;
}

/// The index of the quote closing the string opening at [open], or null.
int? _stringClose(String text, int open) {
  for (var i = open + 1; i < text.length; i++) {
    if (text[i] == r'\') {
      i++;
    } else if (text[i] == text[open]) {
      return i;
    }
  }
  return null;
}
