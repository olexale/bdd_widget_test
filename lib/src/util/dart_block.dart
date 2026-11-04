/// The `{}` block opening at [open] in [text]: `end`, the index just past its
/// closing `}`, and `strings`, the text of every string literal inside it.
///
/// A brace inside a string is text, so `{'a{b'}` is one block and `{'}'}`
/// does not end at its first `}`. Strings are read as Dart reads them: `'…'`,
/// `"…"`, `'''…'''` and `"""…"""`, raw (`r'C:\'`, where `\` escapes nothing)
/// or not (where `\` escapes the next character). In a string that is not
/// raw, a `${…}` interpolation is Dart again: it is not part of the string's
/// text, and a string inside it is a string of its own. A string's text is
/// therefore listed as one [DartString] per run between interpolations.
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

/// A run of a string literal's text, from `start` up to `end`. `quote` is the
/// literal's delimiter (`'`, `"`, `'''` or `"""`), and `prefix` is the index
/// of its `r` when it is raw, or null when it is not.
typedef DartString = ({int start, int end, String quote, int? prefix});

/// The index just past the `}` closing the block at [open], or null. With
/// [strings], quotes are read and each string's text is added to it; a string
/// that never closes returns null. Without, braces are only counted.
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
      final end = _stringEnd(text, i, strings);
      if (end == null) {
        return null;
      }
      i = end;
      continue;
    }
    i++;
  }
  return null;
}

/// The index just past the string literal whose opening quote is at [open],
/// or null when nothing closes it. Its text is added to [strings].
int? _stringEnd(String text, int open, List<DartString> strings) {
  final c = text[open];
  final quote = text.startsWith(c * 3, open) ? c * 3 : c;
  final prefix = _rawPrefix(text, open);
  var start = open + quote.length;
  var i = start;
  while (i < text.length) {
    if (text.startsWith(quote, i)) {
      strings.add((start: start, end: i, quote: quote, prefix: prefix));
      return i + quote.length;
    }
    if (prefix == null && text[i] == r'\') {
      i += 2;
    } else if (prefix == null && text.startsWith(r'${', i)) {
      strings.add((start: start, end: i, quote: quote, prefix: null));
      final end = _blockEnd(text, i + 1, strings);
      if (end == null) {
        return null;
      }
      i = start = end;
    } else {
      i++;
    }
  }
  return null;
}

/// The index of the `r` making the string that opens at [open] raw, or null
/// when it is not raw: an `r` is a prefix only when it is not the end of a
/// longer name, as in `bar'…'`.
int? _rawPrefix(String text, int open) {
  final r = open - 1;
  if (r < 0 || (text[r] != 'r' && text[r] != 'R')) {
    return null;
  }
  return r > 0 && _identifierPart.hasMatch(text[r - 1]) ? null : r;
}

final _identifierPart = RegExp(r'[\w$]');
