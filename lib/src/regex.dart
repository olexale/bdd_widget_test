final examplesRegExp = RegExp(r'\<(.*?)\>', caseSensitive: false);
final charactersAndNumbersRegExp = RegExp(r'[^\w\s\d]+');
final repeatingSpacesRegExp = RegExp(r'\s+');

/// A number written as its own word: no letter, digit, `_`, `.`, `+` or `-`
/// touching it, no `,`, `:`, `/`, `'` or `’` between it and another digit
/// (`1,000`, `1,5`, `1:30`, `1/2`, `1'000`), and never a `+` sign or an
/// exponent. `num.tryParse` accepts `42.`, `.5` and
/// `+7`, none of which is a number in a sentence.
final numberRegExp = RegExp(
  r"(?<![\p{L}\p{N}_.+\-]|\d[,:/'’])"
  r'-?\d+(?:\.\d+)?'
  r"(?![\p{L}\p{N}_.+\-]|[,:/'’]\d)",
  // Required: without it Dart reads `\p{L}` as the characters `p{L}`, and a
  // number after a non-ASCII letter (`é3`) matches.
  unicode: true,
);
